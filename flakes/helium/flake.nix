{
  description = "Helium browser for NixOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }: {
    # Each Linux architecture has its own upstream Debian package and checksum.
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: rec {
      helium = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
      default = helium;
    });

    apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        host = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.default
            { programs.helium.enable = true; }
          ];
        };
        service = host.config.systemd.user.services.helium-preferences;
        seed = pkgs.writeShellScript "helium-test-preferences" ''
          export XDG_CONFIG_HOME="''${1:?expected a temporary configuration directory}"
          export PATH=${nixpkgs.lib.makeBinPath service.path}:$PATH
          export XDG_DATA_DIRS=${service.environment.XDG_DATA_DIRS}
          ${service.script}
        '';
        testPolicies = pkgs.writeTextDir "helium-nixos.json" (
          builtins.toJSON host.config.programs.helium.policies
        );
        testLaunch = pkgs.writeShellScript "helium-test-launch" ''
          exec ${pkgs.bubblewrap}/bin/bwrap --dev-bind / / \
            --overlay-src /etc --tmp-overlay /etc \
            --ro-bind ${testPolicies} /etc/chromium/policies/managed \
            ${self.packages.${system}.helium}/bin/helium "$@"
        '';
      in
      {
        test-launch = {
          type = "app";
          program = toString testLaunch;
        };
        seed-test-profile = {
          type = "app";
          program = toString seed;
        };
      }
    );

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
              DefaultSearchProviderEnabled = lib.mkDefault true;
              DefaultSearchProviderName = lib.mkDefault "Google";
              DefaultSearchProviderSearchURL = lib.mkDefault "https://www.google.com/search?q={searchTerms}";
              ExtensionSettings = lib.mkDefault {
                nngceckbapebfimnlniiiahkandclblb = {
                  installation_mode = "force_installed";
                  toolbar_pin = "force_pinned";
                  update_url = "https://services.helium.imput.net/ext/";
                  override_update_url = true;
                };
              };
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
