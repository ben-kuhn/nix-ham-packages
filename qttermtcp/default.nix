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
  # Latest G8BPQ beta; the 0.81 tag points at 0.0.0.79, master is 0.0.0.81.
  version = "0.0.0.81";

  src = fetchFromGitHub {
    owner = "g8bpq";
    repo = "QtTermTCP";
    rev = "00ca15573c4653882265d6bfc884fca619556c30";
    hash = "sha256-Wy7eTmTF9f7NjXYqgx6rtSPTnUBRjqRDZ+at+A0kp0k=";
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
    # Upstream ships prebuilt object files (notably ax25.o) which are not
    # usable on this architecture; force them to be rebuilt.
    rm -f *.o
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
