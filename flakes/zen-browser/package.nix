{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  patchelfUnstable,
  wrapGAppsHook3,
  wrapFirefox,
  makeDesktopItem,
  copyDesktopItems,
  gtk3,
  adwaita-icon-theme,
  alsa-lib,
  dbus-glib,
  libXtst,
  ffmpeg_8,
  ffmpeg_9 ? ffmpeg_8,
  curl,
  libva,
  pciutils,
  libGL,
  pipewire,
  p11-kit,
  writeText,
  config,
}:
let
  release = (builtins.fromJSON (builtins.readFile ./release.json)).${stdenv.hostPlatform.system};
  libName = "zen-bin-${release.version}";
  policies = writeText "zen-policies.json" (
    builtins.toJSON {
      policies = {
        SecurityDevices."System Trust" = "${p11-kit}/lib/pkcs11/p11-kit-trust.so";
      }
      // (config.firefox.policies or { });
    }
  );
  unwrapped = stdenv.mkDerivation {
    pname = "zen-beta-bin-unwrapped";
    inherit (release) version;
    src = fetchzip {
      inherit (release) url;
      hash = release.sha256;
    };
    nativeBuildInputs = [
      autoPatchelfHook
      patchelfUnstable
      wrapGAppsHook3
      copyDesktopItems
    ];
    buildInputs = [
      gtk3
      adwaita-icon-theme
      alsa-lib
      dbus-glib
      libXtst
      ffmpeg_9
    ];
    runtimeDependencies = [
      curl
      libva.out
      pciutils
      libGL
    ];
    appendRunpaths = [
      "${libGL}/lib"
      "${pipewire}/lib"
    ];
    patchelfFlags = [ "--no-clobber-old-sections" ];
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib/${libName}" "$out/bin"
      cp -r "$src"/* "$out/lib/${libName}/"
      ln -s "$out/lib/${libName}/zen" "$out/bin/zen-beta"
      mkdir -p "$out/lib/${libName}/distribution"
      ln -sf ${policies} "$out/lib/${libName}/distribution/policies.json"
      for size in 16 32 48 64 128; do
        install -Dm644 "$src/browser/chrome/icons/default/default$size.png" \
          "$out/share/icons/hicolor/''${size}x$size/apps/zen-browser.png"
      done
      runHook postInstall
    '';
    preFixup = ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ ffmpeg_9 ]}"
        --add-flags "--name=''${MOZ_APP_LAUNCHER:-zen-beta}"
        --add-flags "--class=''${MOZ_APP_LAUNCHER:-zen-beta}"
      )
    '';
    desktopItems = [
      (makeDesktopItem {
        name = "zen-beta";
        desktopName = "Zen Browser";
        exec = "zen-beta %u";
        icon = "zen-browser";
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeTypes = [
          "text/html"
          "application/xhtml+xml"
          "application/pdf"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        startupWMClass = "zen-beta";
        startupNotify = true;
        actions = {
          new-window = {
            name = "New Window";
            exec = "zen-beta %u";
          };
          new-private-window = {
            name = "New Private Window";
            exec = "zen-beta --private-window %u";
          };
          profilemanager = {
            name = "Profile Manager";
            exec = "zen-beta --ProfileManager %u";
          };
        };
      })
    ];
    passthru = {
      inherit libName gtk3;
      applicationName = "Zen Browser (Beta)";
      binaryName = "zen-beta";
      ffmpegSupport = true;
      gssSupport = true;
    };
    meta = {
      description = "Zen Browser Beta";
      homepage = "https://github.com/zen-browser/desktop";
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      license = lib.licenses.mpl20;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "zen-beta";
    };
  };
in
# The Firefox wrapper uses the Gecko version to choose runtime libraries.
wrapFirefox (unwrapped // { version = release.firefoxVersion; }) {
  inherit (release) version;
  icon = "zen-browser";
}
