{ lib
, stdenv
, fetchFromGitHub
, paho-mqtt-c
, jansson
, miniupnpc
, libconfig
, libpcap
, zlib
, libcap
}:

stdenv.mkDerivation rec {
  pname = "linbpq";
  version = "25.15";

  src = fetchFromGitHub {
    owner = "g8bpq";
    repo = "linbpq";
    rev = version;
    sha256 = "0xx8xvs6z8mdlsq7906h3vpzpk9xw5yaipffsvfva9qjg3bq1bib";
  };

  buildInputs = [
    paho-mqtt-c
    jansson
    miniupnpc
    libconfig
    libpcap
    zlib
  ];

  nativeBuildInputs = [
    libcap  # For setcap during build (we skip it in Nix)
  ];

  # The Makefile uses pkg-config style linking but hardcodes library names
  # We need to ensure libraries are found
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  # Don't run setcap during build - Nix handles capabilities differently
  preBuild = ''
    # Remove setcap call from Makefile (not needed/allowed in Nix build)
    sed -i 's/sudo setcap.*$/# setcap removed for nix build/' makefile
  '';

  installPhase = ''
    runHook preInstall

    # Install the binary
    install -Dm755 linbpq $out/bin/linbpq

    # Install HTML help files if present
    if [ -d HTML ]; then
      mkdir -p $out/share/linbpq/HTML
      cp -r HTML/* $out/share/linbpq/HTML/ 2>/dev/null || true
    fi

    # Install sample configuration files
    mkdir -p $out/share/linbpq/examples
    for f in *.cfg *.txt; do
      [ -f "$f" ] && cp "$f" $out/share/linbpq/examples/ || true
    done

    # Install wav files (used for audio alerts)
    for f in *.wav; do
      [ -f "$f" ] && install -Dm644 "$f" $out/share/linbpq/"$f" || true
    done

    runHook postInstall
  '';

  # Create a wrapper script that helps with the working directory setup
  postInstall = ''
    mkdir -p $out/libexec

    # Create a helper script for first-time setup
    cat > $out/libexec/linbpq-setup << 'EOF'
#!/bin/sh
# LinBPQ initial setup helper
# Creates the working directory structure in /etc/linbpq

WORKDIR="''${1:-/etc/linbpq}"

echo "Setting up LinBPQ working directory at $WORKDIR"

mkdir -p "$WORKDIR"
mkdir -p "$WORKDIR/logs"
mkdir -p "$WORKDIR/HTML"
mkdir -p "$WORKDIR/data"

# Copy example config if no config exists
if [ ! -f "$WORKDIR/bpq32.cfg" ]; then
    echo "Note: You need to create $WORKDIR/bpq32.cfg"
    echo "See documentation at https://www.cantab.net/users/john.wiseman/Documents/LinBPQ.html"
fi

# Set ownership if running as root
if [ "$(id -u)" = "0" ]; then
    chown -R bpq:bpq "$WORKDIR" 2>/dev/null || true
fi

echo "Setup complete. Edit $WORKDIR/bpq32.cfg before starting linbpq."
EOF
    chmod +x $out/libexec/linbpq-setup
  '';

  meta = with lib; {
    description = "Linux BPQ Packet Radio Network Node Software";
    longDescription = ''
      LinBPQ is a Linux implementation of the BPQ packet radio networking system.
      It provides a full-featured packet radio BBS, network node, and gateway
      supporting multiple protocols including AX.25, VARA, ARDOP, and more.

      Features:
      - Packet radio BBS with full mail and bulletin support
      - Network node with NETROM and other routing protocols
      - Support for multiple TNCs and modems
      - Web-based management interface
      - MQTT integration
      - APRS support

      Configuration directory: /etc/linbpq
      Run with: linbpq -d /etc/linbpq -c /etc/linbpq -l /etc/linbpq/logs
    '';
    homepage = "https://www.cantab.net/users/john.wiseman/Documents/LinBPQ.html";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "linbpq";
  };
}
