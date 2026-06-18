# NixOS Overlay for Amateur Radio Packages
#
# This overlay provides several amateur radio related packages:
# - linbpq: BPQ Packet Radio Node software
# - ldsped: AGW Packet Engine replacement
# - mercury: Mercury Modem
# - paracon: Paracon terminal (depends on pyham-ax25 and pyham-pe)
# - pyham-ax25: AX.25 protocol library for Python
# - pyham-pe: AGWPE protocol client library for Python
# - qtsoundmodem: Qt Sound Modem
# - qttermtcp: Qt Terminal TCP client
# - tncd: AGWPE-to-KISS Translation Bridge
# - pat: Cross-platform Winlink client (updated to v1.0.0)
#
# Usage: Import this file as an overlay in your NixOS configuration

final: prev: {
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

  # Paracon - Packet radio terminal application
  paracon = prev.callPackage ./paracon {
    inherit (final) pyham-ax25 pyham-pe;
  };

  # QtSoundModem - Qt-based sound modem
  qtsoundmodem = prev.callPackage ./qtsoundmodem { };

  # QtTermTCP - Qt Terminal TCP client for BPQ
  qttermtcp = prev.callPackage ./qttermtcp { };

  # ax253 - Pure Python AX.25 stack (dependency of kiss3)
  ax253 = prev.callPackage ./tncd/ax253.nix { };

  # kiss3 - Python KISS protocol implementation (dependency of tncd)
  kiss3 = prev.callPackage ./tncd/kiss3.nix {
    inherit (final) ax253;
  };

  # tncd - AGWPE-to-KISS Translation Bridge
  tncd = prev.callPackage ./tncd {
    inherit (final) pyham-ax25 kiss3;
  };

  # PAT - Cross-platform Winlink client (v1.0.0, upstream nixpkgs has 0.19.1)
  pat = prev.callPackage ./pat { };
}
