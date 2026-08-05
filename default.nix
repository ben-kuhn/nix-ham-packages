# NixOS Overlay for Amateur Radio Packages
#
# This overlay provides several amateur radio related packages:
# - bpq-monitor: Web UI for BPQ node modem traffic and status
# - cwdaemon: Morse code (CW) keying daemon (used by not1mm)
# - linbpq: BPQ Packet Radio Node software
# - ldsped: AGW Packet Engine replacement
# - mercury: Mercury Modem
# - not1mm: Amateur radio contest logger (PyQt6)
# - paracon: Paracon terminal (depends on pyham-ax25 and pyham-pe)
# - pat: Cross-platform Winlink client (updated to v1.0.0)
# - pyham-ax25: AX.25 protocol library for Python
# - pyham-pe: AGWPE protocol client library for Python
# - qtsoundmodem: Qt Sound Modem
# - qttermtcp: Qt Terminal TCP client
# - tncd: AGWPE-to-KISS Translation Bridge (Go)
# - tuxlink: Native Linux Winlink client (Rust + Tauri, alpha)
#
# Usage: Import this file as an overlay in your NixOS configuration

final: prev: {
  # BPQ Monitor - web UI for BPQ node modem traffic and status
  bpq-monitor = prev.callPackage ./bpq-monitor { };

  # LinBPQ - Linux BPQ Packet Radio Node
  linbpq = prev.callPackage ./linbpq { };

  # LDSPED - AGW Packet Engine replacement for AX.25 packet radio
  ldsped = prev.callPackage ./ldsped { };

  # Mercury Modem
  mercury-modem = prev.callPackage ./mercury { };

  # PyHam AX.25 - AX.25 protocol library for Python
  pyham-ax25 = prev.callPackage ./pyham-ax25 { };

  # PyHam PE - AGWPE protocol client library for Python
  pyham-pe = prev.callPackage ./pyham-pe {
    inherit (final) pyham-ax25;
  };

  # Not1MM dependency: CTY file parser
  notctyparser = prev.callPackage ./not1mm/notctyparser.nix { };

  # Not1MM dependency: ADIF format reader/writer
  adif-io = prev.callPackage ./not1mm/adif-io.nix { };

  # Not1MM dependency: XDG app-data helpers
  appdata = prev.callPackage ./not1mm/appdata.nix { };

  # Not1MM - amateur radio contest logger
  not1mm = prev.callPackage ./not1mm {
    inherit (final) notctyparser adif-io appdata;
  };

  # cwdaemon - Morse keying daemon (used by not1mm)
  cwdaemon = prev.callPackage ./cwdaemon { };

  # Paracon - Packet radio terminal application
  paracon = prev.callPackage ./paracon {
    inherit (final) pyham-ax25 pyham-pe;
  };

  # QtSoundModem - Qt-based sound modem
  qtsoundmodem = prev.callPackage ./qtsoundmodem { };

  # QtTermTCP - Qt Terminal TCP client for BPQ
  qttermtcp = prev.callPackage ./qttermtcp { };

  # tncd - AGWPE-to-KISS Translation Bridge (Go)
  tncd = prev.callPackage ./tncd { };

  # PAT - Cross-platform Winlink client (v1.0.0, upstream nixpkgs has 0.19.1)
  pat = prev.callPackage ./pat { };

  # Tuxlink - Linux-native Winlink client (Tauri 2.x, Rust + React)
  tuxlink = prev.callPackage ./tuxlink { };

  # Packet Browser Server - Web page fetcher for AX.25 packet radio
  packet-browser-server = prev.callPackage ./packet-browser-server { };

  # Packet Browser Client - AGWPE client with web proxy interface
  packet-browser-client = prev.callPackage ./packet-browser-client { };
}
