{
  lib,
  flutter347,
  fetchFromGitHub,
  pkg-config,
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
  alsa-lib,
  gst_all_1,
  gsettings-desktop-schemas,
  sqlite,
  stdenv,
}:

let
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Ylianst";
    repo = "HTCommander";
    tag = "v${version}";
    hash = "sha256-SK1E+4mrp1ySQh7cbmJ84XjIceqnLqb/eHr2qoDCynA=";
  };

  # Upstream does not commit pubspec.lock; this was generated with Flutter
  # 3.47.4 (Dart 3.13.3) from the v0.2.0 source tree.
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  # HTCommander uses SQLite, not SQLCipher.  nixpkgs' sqlite3 asset builder
  # always fetches a prebuilt SQLCipher library and has no hash for 3.9.1;
  # point both lookups at the system SQLite instead.
  sqliteBuilder = { version, src, ... }:
    stdenv.mkDerivation {
      pname = "sqlite3";
      inherit version src;
      inherit (src) passthru;
      postPatch = ''
        substituteInPlace lib/src/hook/compile/description.dart \
          --replace-fail "return fromGitHub(LibraryType.sqlite3);" "return LookupSystem('sqlite3');" \
          --replace-fail "return fromGitHub(LibraryType.sqlcipher);" "return LookupSystem('sqlite3');"
      '';
      installPhase = ''
        mkdir -p $out
        cp --recursive . $out
      '';
    };

  # The Linux Flutter wrapper deliberately omits the web SDK artifacts.
  # Build the hosted web UI with a web-target Flutter and copy it into the
  # desktop bundle below.
  web = flutter347.buildFlutterApplication {
    pname = "htcommander-web";
    inherit version src pubspecLock;
    sourceRoot = "${src.name}/src";
    targetFlutterPlatform = "web";
    customSourceBuilders.sqlite3 = sqliteBuilder;
  };
in
flutter347.buildFlutterApplication rec {
  pname = "htcommander";
  inherit version src pubspecLock;

  sourceRoot = "${src.name}/src";

  customSourceBuilders.sqlite3 = sqliteBuilder;

  nativeBuildInputs = [
    pkg-config
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
    alsa-lib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gsettings-desktop-schemas
    sqlite
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

  postInstall = ''
    install -Dm644 $out/app/htcommander/data/flutter_assets/assets/images/AppIcon.png \
      $out/share/icons/hicolor/256x256/apps/htcommander.png

    # sqlite3_flutter_libs loads the bare `libsqlite3.so` name; the Dart
    # asset builder points at system SQLite, so expose it in the bundle.
    ln -sf ${lib.getLib sqlite}/lib/libsqlite3.so $out/app/htcommander/lib/libsqlite3.so
    ln -sf ${lib.getLib sqlite}/lib/libsqlite3.so.0 $out/app/htcommander/lib/libsqlite3.so.0

    cp -r ${web}/. $out/app/htcommander/web_app/
  '';

  meta = with lib; {
    description = "Multi-platform control and programming tool for UV-Pro, GA-5WB, VR-N76 and compatible radios";
    homepage = "https://github.com/Ylianst/HTCommander";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "htcommander";
  };
}
