{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  ncurses,
  hidapi,
  hamlib,
}:

stdenv.mkDerivation rec {
  pname = "modem73";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "RFnexus";
    repo = "modem73";
    rev = "v${version}";
    hash = "sha256-KDVnj0eYQ3NM3DFFFbo6llBPhvgMlfiZFuYjtSLob6E=";
  };

  nativeBuildInputs = [ pkg-config ];

  # ncurses for the TUI, hidapi for CM108 USB PTT, hamlib for direct rig PTT.
  # Both optional features are auto-detected by the Makefile via pkg-config.
  buildInputs = [
    ncurses
    hidapi
    hamlib
  ];

  # The Makefile defaults to -march=native, which is both non-reproducible and
  # unsafe across machines, so clear it. The CXX/CC defaults are hardcoded to
  # g++/gcc, so pass the Nix toolchain explicitly (command-line vars win).
  makeFlags = [
    "ARCHFLAGS="
    "VERSION=${version}"
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 modem73 $out/bin/modem73

    # udev rules for non-root access to CM108 and GPIO PTT lines.
    install -Dm644 misc/50-cm108-ptt.rules \
      $out/lib/udev/rules.d/50-cm108-ptt.rules
    install -Dm644 misc/60-gpio-ptt.rules \
      $out/lib/udev/rules.d/60-gpio-ptt.rules

    install -Dm644 README.md $out/share/doc/modem73/README.md
    install -Dm644 QUICKSTART.md $out/share/doc/modem73/QUICKSTART.md
    install -Dm644 CONTROL_PORT.md $out/share/doc/modem73/CONTROL_PORT.md

    # Guard against the Makefile silently dropping the optional PTT backends
    # (upstream's CI does the same check).
    readelf -d $out/bin/modem73 | grep -q hidapi || {
      echo "error: CM108 (hidapi) PTT support was not linked in" >&2
      exit 1
    }
    readelf -d $out/bin/modem73 | grep -q hamlib || {
      echo "error: hamlib PTT support was not linked in" >&2
      exit 1
    }

    runHook postInstall
  '';

  meta = with lib; {
    description = "High-speed software modem for HF/VHF/UHF radios with 2400 Hz bandwidth";
    longDescription = ''
      MODEM73 is a software modem that turns a computer's sound interface into a
      KISS TNC for any HF, VHF, or UHF radio with 2400 Hz of bandwidth. It offers
      three modem families (OFDM, ROBUST, and MFSK) that are decoded
      simultaneously, and supports rigctl, VOX, serial, GPIO, and CM108 PTT.
    '';
    homepage = "https://modem73.app/";
    changelog = "https://github.com/RFnexus/modem73/releases/tag/v${version}";
    license = licenses.unlicense;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "modem73";
  };
}
