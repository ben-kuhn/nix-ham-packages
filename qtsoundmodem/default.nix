{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  alsa-lib,
  libpulseaudio,
  fftwFloat,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "qtsoundmodem";
  version = "0.76";

  src = fetchFromGitHub {
    owner = "g8bpq";
    repo = "QtSoundModem";
    rev = version;
    hash = "sha256-GnAWhUEoAgoO8tPX1POcoEtiaBIKmm/Uwn5raCGGqdQ=";
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtserialport
    alsa-lib
    libpulseaudio
    fftwFloat
  ];

  # Disable Werror that may come from hardening or qmake
  hardeningDisable = [ "all" ];

  # Also ensure QMAKE_CXXFLAGS doesn't have Werror
  preConfigure = ''
    echo "QMAKE_CXXFLAGS -= -Werror" >> QtSoundModem.pro
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "qtsoundmodem";
      desktopName = "QtSoundModem";
      exec = "QtSoundModem";
      icon = "qtsoundmodem";
      categories = [ "Network" "HamRadio" "AudioVideo" ];
      comment = meta.description;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 QtSoundModem $out/bin/QtSoundModem

    mkdir -p $out/share/icons/hicolor/256x256/apps
    install -Dm644 ${./qtsoundmodem.png} $out/share/icons/hicolor/256x256/apps/qtsoundmodem.png

    runHook postInstall
  '';

  meta = {
    description = "Multi-platform sound modem for packet radio supporting various baud rates and protocols (FX.25, IL2P)";
    longDescription = ''
      QtSoundModem is a multi-platform port of UZ7HO's Sound Modem.
      It uses a computer's sound interface to send and receive AX.25 packet radio data.
      Supports multiple modems with different KISS interfaces, allowing up to 4 ports
      with different speeds, protocols and modes in the same channel.
      Supports baud rates from 300 to 4800 and modern extensions like FX.25 and IL2P.
    '';
    homepage = "https://www.cantab.net/users/john.wiseman/Documents/QtSoundModem.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "QtSoundModem";
  };
}
