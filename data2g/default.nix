{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  hamlib_4,
  zlib,
  alsa-lib,
}:

stdenv.mkDerivation rec {
  pname = "data2g";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "arodland";
    repo = "Data2G";
    rev = "v${version}";
    hash = "sha256-sk7jXO+jN2L3Hm07SJyY9Td95hc1GddRpqc3vns76UI=";
  };

  # The project root has the Python reference; the native C++/Qt build with
  # the CMakeLists lives in native/.
  cmakeDir = "../native";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebsockets
    qt6.qtwayland
    hamlib_4
    zlib
    alsa-lib
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DDATA2G_BUILD_HOST=ON"
    "-DDATA2G_BUILD_GUI=ON"
    "-DDATA2G_BUILD_QTAUDIO=ON"
    "-DDATA2G_AUDIO_BACKEND=miniaudio"
    "-DDATA2G_BUILD_RIG=ON"
    "-DDATA2G_HAMLIB_SYSTEM=ON"
    "-DDATA2G_BUILD_TESTS=OFF"
    "-DDATA2G_BUILD_PYMODULE=OFF"
  ];

  installPhase = ''
    runHook preInstall

    # Native/ has no install() rules; stage only the application binaries.
    for b in data2g-host data2g-gui data2g-web data2g-monitor \
             data2g-replay data2g-bench-rx data2g-audio-check; do
      if [ -x "./$b" ]; then
        install -Dm755 "./$b" "$out/bin/$b"
      fi
    done

    install -Dm644 ../native/packaging/org.cleverdomain.data2g.desktop \
      "$out/share/applications/org.cleverdomain.data2g.desktop"
    install -Dm644 ../native/packaging/org.cleverdomain.data2g.metainfo.xml \
      "$out/share/metainfo/org.cleverdomain.data2g.metainfo.xml"
    install -Dm644 ../native/packaging/data2g.svg \
      "$out/share/icons/hicolor/scalable/apps/org.cleverdomain.data2g.svg"

    for png in ../native/packaging/icons/data2g-*.png; do
      size="''${png##*-}"
      size="''${size%.png}"
      install -Dm644 "$png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/org.cleverdomain.data2g.png"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Open-source HF data modem with a VARA-compatible TNC";
    longDescription = ''
      Data2G is an HF data modem with a VARA-compatible TNC for Winlink/BBS,
      a KISS TNC for HF APRS, and an extended broadcast/connected mode. It
      uses OFDM, QC-LDPC and polar codes, hybrid ARQ, crest-factor control
      and intelligent rate shifting, with a Qt GUI and a headless host.
    '';
    homepage = "https://github.com/arodland/Data2G";
    changelog = "https://github.com/arodland/Data2G/releases/tag/v${version}";
    license = licenses.artistic2;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "data2g-gui";
  };
}
