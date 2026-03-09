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

  # Paracon - Packet radio terminal application
  paracon = prev.callPackage ./paracon {
    inherit (final) pyham-ax25 pyham-pe;
  };

  # QtSoundModem - Qt-based sound modem
  qtsoundmodem = prev.callPackage ./qtsoundmodem { };

  # QtTermTCP - Qt Terminal TCP client for BPQ
  qttermtcp = prev.callPackage ./qttermtcp { };
}
