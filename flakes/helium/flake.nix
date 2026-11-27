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
        imports = [ ./preferences.nix ];
        options.programs.helium.enable = lib.mkEnableOption "the Helium browser";
        options.programs.helium.policies = lib.mkOption {
          type = lib.types.attrsOf (pkgs.formats.json { }).type;
          default = { };
          description = "Managed browser policies. Policies in the Chromium directory also apply to other browsers using that directory.";
        };
        config = lib.mkIf config.programs.helium.enable {
          programs.helium.policies =
            let
              engine = name: shortcut: url: { inherit name shortcut url; };
            in
            {
              RestoreOnStartup = lib.mkDefault 1;
              SiteSearchSettings = lib.mkDefault [
                (engine "YouTube" "yt" "https://www.youtube.com/results?search_query={searchTerms}")
                (engine "Amazon" "amazon" "https://www.amazon.com/s?k={searchTerms}")
                (engine "eBay" "ebay" "https://www.ebay.com/sch/i.html?_nkw={searchTerms}")
              ];
            };

          programs.helium.preferences = {
            verticalLayout = lib.mkDefault true;
            frameless = lib.mkDefault true;
            expandTabsOnHover = lib.mkDefault true;
            # Catppuccin lavender in Latte and Mocha.
            accentColors = lib.mkDefault {
              light = "7287fd";
              dark = "b4befe";
            };
          };

          environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];
          environment.etc = lib.mkIf (config.programs.helium.policies != { }) (
            lib.genAttrs
              [
                "chromium/policies/managed/helium-nixos.json"
                "helium/policies/managed/helium-nixos.json"
              ]
              (_: {
                text = builtins.toJSON config.programs.helium.policies;
              })
          );
        };
      };
  };
}
