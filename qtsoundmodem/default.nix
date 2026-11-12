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
  # Latest G8BPQ beta; the 0.76 tag points at 0.0.0.74 Beta 2, master is 0.0.0.76.
  version = "0.0.0.76";

  src = fetchFromGitHub {
    owner = "g8bpq";
    repo = "QtSoundModem";
    rev = "9cd2735bc97000fb2d46de2a8ee8cfaa0580a34b";
    hash = "sha256-vBz0zY150TChufN4dpcMhNh2q9eFEbqn3z0T8+VWTd0=";
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtserialport
    qt5.qtmultimedia
    alsa-lib
    libpulseaudio
    fftwFloat
  ];

  # Disable Werror that may come from hardening or qmake
  hardeningDisable = [ "all" ];

  # GCC 14+ promotes -Wincompatible-pointer-types to an error; upstream passes
  # unsigned char * to strcat (const char *). Suppress for C files only.
  preConfigure = ''
    echo "QMAKE_CXXFLAGS -= -Werror" >> QtSoundModem.pro
    echo "QMAKE_CFLAGS += -std=gnu17 -Wno-incompatible-pointer-types" >> QtSoundModem.pro
  '';

  # QtSoundModem loads libpulse dynamically via dlopen, so we need to add it to LD_LIBRARY_PATH
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libpulseaudio ]}"
  ];

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
