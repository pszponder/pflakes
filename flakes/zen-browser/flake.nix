{
  description = "Zen Browser Beta for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      zenBrowser = pkgs: pkgs.callPackage ./package.nix { };
    in
    {
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: rec {
        zen-browser = zenBrowser nixpkgs.legacyPackages.${system};
        default = zen-browser;
      });

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          options.programs.zen-browser.enable = lib.mkEnableOption "Zen Browser Beta";
          config = lib.mkIf config.programs.zen-browser.enable {
            environment.systemPackages = [ (zenBrowser pkgs) ];
          };
        };
    };
}
