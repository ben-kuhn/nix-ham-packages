{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "qttermtcp";
  version = "0.81";

  src = fetchFromGitHub {
    owner = "g8bpq";
    repo = "QtTermTCP";
    rev = version;
    hash = "sha256:0hslzvn8lxpd0x4hj1b93160l0rc0x0n17jly4p121nj8ylrnh7s";
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
  ];

  # Disable hardening that causes -Werror=format-security
  hardeningDisable = [ "all" ];

  # Remove Werror from qmake flags
  preConfigure = ''
    echo "QMAKE_CXXFLAGS -= -Werror" >> QtTermTCP.pro
    echo "QMAKE_CFLAGS -= -Werror" >> QtTermTCP.pro
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "qttermtcp";
      desktopName = "QtTermTCP";
      exec = "QtTermTCP";
      icon = "net.g8bpq.qttermtcp";
      categories = [ "Network" "HamRadio" ];
      comment = meta.description;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 QtTermTCP $out/bin/QtTermTCP

    mkdir -p $out/share/icons/hicolor/256x256/apps
    install -Dm644 ${./net.g8bpq.qttermtcp.png} $out/share/icons/hicolor/256x256/apps/net.g8bpq.qttermtcp.png

    runHook postInstall
  '';

  meta = {
    description = "GUI terminal for BPQ (FBB mode) as well as AGWPE, KISS, and VARA modems";
    homepage = "https://www.cantab.net/users/john.wiseman/Documents/QtTermTCP.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "QtTermTCP";
  };
}
