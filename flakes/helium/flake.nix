{
  description = "Helium browser for NixOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }: {
    # Each Linux architecture has its own upstream Debian package and checksum.
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: rec {
      helium = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
      default = helium;
    });

    # Build with the host's package set when imported into a NixOS configuration.
    nixosModules.default =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        options.programs.helium.enable = lib.mkEnableOption "the Helium browser";
        config = lib.mkIf config.programs.helium.enable {
          environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];
        };
      };
  };
}
