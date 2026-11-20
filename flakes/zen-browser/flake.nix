{
  description = "Zen Browser Beta for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zen-packaging = {
      url = "github:0xc000022070/zen-browser-flake";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, zen-packaging, ... }:
    let
      zenBrowser = pkgs: (import zen-packaging { inherit pkgs; }).beta;
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
