# Zen Browser

This flake packages official Zen Browser Beta releases for x86_64-linux and aarch64-linux directly from [zen-browser/desktop](https://github.com/zen-browser/desktop/releases). The local `package.nix` handles NixOS integration; `release.json` pins official download URLs and checksums. The NixOS module uses the host's nixpkgs and requires no Home Manager setup.

## Use in nixconfig

Once the new module is published, run `nix flake update pflakes` in nixconfig to pick it up. In `modules/hosts/tpx1/default.nix`, add `inputs.pflakes.nixosModules.zen-browser` beside the Helium module in `flake.nixosConfigurations.tpx1`’s `modules` list. Then enable it beside the existing Helium setting in `flake.modules.nixos.tpx1`:

```nix
programs.zen-browser.enable = true;
```

Alternatively, add `inputs.pflakes.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser` to `environment.systemPackages`.

## Run locally

From the pflakes repository:

```sh
nix run path:.#zen-browser -- --version
nix run path:./flakes/zen-browser
```

## Update Zen

The [Update Zen Browser workflow](../../.github/workflows/update-zen-browser.yml) runs daily at 06:47 UTC and supports manual runs. When the official release changes, it tests both x86-64 launchers and commits the verified release metadata.

Run `just update-zen-browser` locally to fetch the latest official release and test the candidate before writing `release.json`.
