{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.helium;
  prefs = cfg.preferences;
  toggle =
    description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      inherit description;
    };
  colors = prefs.accentColors;
  settings =
    lib.recursiveUpdate (lib.optionalAttrs prefs.verticalLayout { helium.browser.layout = 2; })
      (
        (lib.optionalAttrs (prefs.frameless != null) { helium.browser.zen_mode = prefs.frameless; })
        // (lib.optionalAttrs (prefs.expandTabsOnHover != null) {
          vertical_tabs = {
            expand_on_hover = prefs.expandTabsOnHover;
          }
          // lib.optionalAttrs prefs.expandTabsOnHover { collapsed_state = true; };
        })
      );
in
{
  options.programs.helium.preferences = {
    verticalLayout = lib.mkEnableOption "the vertical tab layout";
    frameless = toggle "Enable frameless mode in the default profile.";
    expandTabsOnHover = toggle "Expand collapsed vertical tabs on hover.";
    accentColors = lib.mkOption {
      default = null;
      description = "Optional light and dark browser accent colors, as six hex digits, selected at login.";
      type = lib.types.nullOr (
        lib.types.submodule {
          options = lib.genAttrs [ "light" "dark" ] (
            _: lib.mkOption { type = lib.types.strMatching "[0-9a-fA-F]{6}"; }
          );
        }
      );
    };
  };
  config = lib.mkIf (cfg.enable && (settings != { } || colors != null)) {
    systemd.user.services.helium-preferences = {
      description = "Apply Helium preferences before desktop startup";
      wantedBy = [ "graphical-session-pre.target" ];
      before = [ "graphical-session-pre.target" ];
      serviceConfig.Type = "oneshot";
      path = [
        pkgs.jq
        pkgs.coreutils
        pkgs.glib
      ];
      environment.XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}";
      script = ''
        set -eu
        profile="''${XDG_CONFIG_HOME:-$HOME/.config}/net.imput.helium"
        if [ -L "$profile/SingletonLock" ]; then exit 0; fi
        umask 077
        mkdir -p "$profile/Default"
        cd "$profile/Default"
        source=Preferences
        if [ ! -e Preferences ]; then source=/dev/null; fi
        temp=$(mktemp .Preferences.XXXXXX)
        trap 'rm -f "$temp"' EXIT
        theme='{}'
        ${lib.optionalString (colors != null) ''
          hex=${colors.light}
          if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-dark'" ]; then
            hex=${colors.dark}
          fi
          theme=$(jq -n --argjson color "$((0xff$hex - 0x100000000))" '{
            extensions: {theme: {id: "user_color_theme_id"}},
            browser: {theme: {is_grayscale2: false, user_color2: $color}}
          }')
        ''}
        jq -s --argjson prefs ${lib.escapeShellArg (builtins.toJSON settings)} --argjson theme "$theme" \
          '(.[0] // {}) * $prefs * $theme' "$source" > "$temp"
        mv "$temp" Preferences
      '';
    };
  };
}
