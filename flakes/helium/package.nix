{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
}:
let
  release = lib.importJSON ./release.json;
  arch =
    {
      x86_64-linux = "amd64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "helium";
  inherit (release) version;
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${release.tag}/helium-bin_${release.version}-1_${arch}.deb";
    sha256 = release.sha256.${arch};
  };

  # dpkg extracts the payload. autoPatchelfHook fixes the loader and library paths.
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    libgbm
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    nspr
    nss
    pango
    systemd
    qt6.qtbase
  ];
  # Chromium loads these at runtime, so they do not appear in its ELF dependencies.
  runtimeDependencies = with pkgs; [
    gtk3
    libGL
    vulkan-loader
    pipewire
    libva
  ];
  dontWrapQtApps = true;
  dontUnpack = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    dpkg-deb -x "$src" payload
    mkdir -p "$out/bin" "$out/opt"
    mv payload/opt/helium "$out/opt/"
    cp -r payload/usr/share "$out/share"
    # GTK and the Qt 6 shim provide desktop integration.
    rm -f "$out/opt/helium/libqt5_shim.so"
    makeWrapper "$out/opt/helium/helium-wrapper" "$out/bin/helium" \
      --prefix PATH : "${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.xdg-utils
        ]
      }"
    substituteInPlace "$out/share/applications/helium.desktop" \
      --replace-fail 'Exec=helium' "Exec=$out/bin/helium"
    install -Dm644 "$out/opt/helium/product_logo_256.png" "$out/share/icons/hicolor/256x256/apps/helium.png"
    runHook postInstall
  '';
  meta = {
    mainProgram = "helium";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    homepage = "https://helium.computer";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
