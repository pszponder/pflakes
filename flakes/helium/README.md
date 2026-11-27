# Helium for NixOS

This flake packages the official x86-64 and ARM64 Debian binaries from [Helium's Linux releases](https://github.com/imputnet/helium-linux/releases). The version and per-architecture SHA-256 checksums live in `release.json`. The package extracts the browser and desktop launcher and patches the binaries to find their libraries in the Nix store.

## Test locally before publishing

From the root of `pflakes`, run the smoke test. It builds the local package as needed and runs its launcher with `--version`. The recipe uses a `path:` input so it includes untracked flake files.

```sh
just test-helium
```

To check the browser window as well, run this in a desktop session.

```sh
just test-helium --launch
```

After the version check passes, the recipe opens the local build with a temporary profile initialized with the NixOS module’s default preferences, including vertical tabs, zen mode, and the light or dark accent color. Helium skips first-run setup. The test window loads the module’s policies in a private mount namespace, uses Google for address-bar searches, and downloads Bitwarden through Helium’s extension service. Visit `chrome://extensions` to check the install. On the version page, check **Executable Path** for the Nix store build and **Profile Path** for the test profile. Close Helium to finish the test and remove the temporary profile.

## Install in nixconfig

Once the Helium flake is on the default branch of `pszponder/pflakes`, make these edits in your `nixconfig` checkout.

1. In `flake.nix`, add this entry inside the existing `inputs` block. The collection shares your system’s Nixpkgs pin.

   ```nix
   pflakes = {
     url = "github:pszponder/pflakes";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. In `modules/hosts/tpx1/default.nix`, extend the `modules` list inside `flake.nixosConfigurations.tpx1`. The file already receives `inputs` from flake-parts.

   ```nix
   modules = [
     self.modules.nixos.tpx1
     inputs.pflakes.nixosModules.helium
   ];
   ```

3. In the same file, add this setting inside `flake.modules.nixos.tpx1`, alongside `boot` and `networking`.

   ```nix
   programs.helium.enable = true;
   ```

4. From the root of `nixconfig`, lock the new input, activate the configuration, and verify the installed browser.

   ```sh
   nix flake lock
   just switch tpx1
   helium --version
   ```

Commit `flake.nix`, `flake.lock`, and the host module together in `nixconfig`. Launch Helium from the application menu or run `helium`. To try the package directly from the published flake, run `nix run 'github:pszponder/pflakes#helium'`.

## Updates

Run `just update-helium` from `pflakes` to check upstream locally. It uses the same release metadata as CI and skips the build when the pin is current. For a changed release, it builds and runs `helium --version` on your architecture before writing `release.json`. Review and commit that file to publish the update. `just update` runs all package updaters.

The [daily GitHub workflow](../../README.md#set-up-github-actions) tracks the Linux binary release tag and updates the pin in `pflakes`. Your system uses the revision recorded in `nixconfig/flake.lock`. To install a published update, run these commands from `nixconfig`, then commit the updated lock file.

```sh
nix flake update pflakes
just switch tpx1
helium --version
```
