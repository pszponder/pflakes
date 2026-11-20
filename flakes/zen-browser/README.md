# Zen Browser

This flake packages the official Zen Browser Beta for x86_64-linux and aarch64-linux using the [community packaging](https://github.com/0xc000022070/zen-browser-flake). Its lock file pins the package recipe and release. The NixOS module builds with the host's nixpkgs and requires no Home Manager setup.

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

The [Update Zen Browser workflow](../../.github/workflows/update-zen-browser.yml) runs daily at 06:47 UTC and supports manual runs. When the community packaging pin changes, it tests both x86-64 launchers and commits the verified lock files.

Run `just update-zen-browser` locally to refresh both pins and test the candidate before writing the lock files.
