{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  glib,
  gdk-pixbuf,
  pango,
  harfbuzz,
  atk,
  cairo,
  libepoxy,
  fontconfig,
  libxkbcommon,
  libGL,
  bluez,
  libpulseaudio,
  libsecret,
  libserialport,
  gst_all_1,
  gsettings-desktop-schemas,
}:

stdenv.mkDerivation rec {
  pname = "htcommander";
  version = "0.1.97";

  # Upstream ships a self-contained Linux bundle.  A source build currently
  # needs Flutter 3.47.9 / Dart 3.12.2; nixpkgs has Flutter 3.41.9 / Dart
  # 3.11.5, and upstream does not commit a pubspec.lock, so use the release.
  src = fetchurl {
    url = "https://github.com/Ylianst/HTCommander/releases/download/v${version}/htcommander-linux-x64.tar.gz";
    hash = "sha256-NfzHNoXs2xSWu1TOSaT3LZatM8V+pN/MIYysjmQ5AhE=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    glib
    gdk-pixbuf
    pango
    harfbuzz
    atk
    cairo
    libepoxy
    fontconfig
    libxkbcommon
    libGL
    bluez
    libpulseaudio
    libsecret
    libserialport
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gsettings-desktop-schemas
    stdenv.cc.cc.lib
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "htcommander";
      desktopName = "HTCommander";
      comment = "Amateur radio tool for UV-Pro, GA-5WB, VR-N76, VR-N7500 and compatible radios";
      exec = "htcommander";
      icon = "htcommander";
      categories = [ "Utility" "HamRadio" ];
      terminal = false;
    })
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/htcommander
    cp -a htcommander data lib web_app $out/lib/htcommander/

    # Android-only JNI bridge; it needs libjvm and is not used on Linux.
    rm -f $out/lib/htcommander/lib/libdartjni.so

    mkdir -p $out/bin
    ln -s $out/lib/htcommander/htcommander $out/bin/htcommander

    install -Dm644 $out/lib/htcommander/data/flutter_assets/assets/images/AppIcon.png \
      $out/share/icons/hicolor/256x256/apps/htcommander.png

    runHook postInstall
  '';

  # The Flutter engine and several plugins load libraries at runtime rather
  # than through DT_NEEDED, so put the bundle and its dependencies on the
  # loader path.
  postFixup = ''
    wrapProgram $out/bin/htcommander \
      --prefix LD_LIBRARY_PATH : "$out/lib/htcommander/lib" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        gtk3
        glib
        gdk-pixbuf
        pango
        harfbuzz
        atk
        cairo
        libepoxy
        fontconfig
        libxkbcommon
        libGL
        bluez
        libpulseaudio
        libsecret
        libserialport
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
      ]}
  '';

  meta = with lib; {
    description = "Multi-platform control and programming tool for UV-Pro, GA-5WB, VR-N76 and compatible radios";
    longDescription = ''
      HTCommander controls and programs several Bluetooth-enabled amateur
      radios, with channel editing, APRS, Winlink mail, packet terminal, BBS,
      SSTV, Bluetooth audio and AGWPE support on Linux.
    '';
    homepage = "https://github.com/Ylianst/HTCommander";
    downloadPage = "https://ylianst.github.io/HTCommanderSite/";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "htcommander";
  };
}
