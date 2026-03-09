{
  lib,
  python3Packages,
  fetchFromGitHub,
  pyham-ax25,
  pyham-pe,
}:

python3Packages.buildPythonApplication rec {
  pname = "paracon";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mfncooper";
    repo = "paracon";
    rev = "v${version}";
    hash = "sha256-yEVlIF/7ZQf6WSqxSCWpSYunMFpeXBuBC/T11FO1xHM=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = [
    python3Packages.urwid
    pyham-ax25
    pyham-pe
  ];

  # Create __init__.py, setup.py, and fix version handling
  postPatch = ''
    # Create __init__.py that exports __version__ from paracon.py
    echo "from .paracon import __version__" > paracon/__init__.py

    # Fix relative imports in paracon.py (they should use relative imports for packaging)
    substituteInPlace paracon/paracon.py \
      --replace-fail "import config" "from . import config" \
      --replace-fail "import pserver" "from . import pserver" \
      --replace-fail "import urwidx" "from . import urwidx"

    # Fix Config package reference - should look in 'paracon' package, not 'paracon_config'
    substituteInPlace paracon/paracon.py \
      --replace-fail "config.Config('paracon', 'paracon_config')" "config.Config('paracon', 'paracon')"

    # Create minimal setup.py to work with setup.cfg
    cat > setup.py << 'EOF'
from setuptools import setup
setup()
EOF

    # Add entry point and package data to setup.cfg
    cat >> setup.cfg << 'EOF'

[options.entry_points]
console_scripts =
    paracon = paracon.paracon:run

[options.package_data]
paracon = *.def
EOF
  '';

  # No tests in the repository
  doCheck = false;

  meta = with lib; {
    description = "Packet radio terminal for Linux, Mac and Windows";
    longDescription = ''
      Paracon is a packet radio terminal application that provides:
      - Multiple simultaneous AX.25 connected-mode sessions
      - Unproto (datagram) mode for keyboard-to-keyboard chat
      - Cross-platform text-based console interface
      - AGWPE protocol compatibility with servers like Direwolf and ldsped

      A straightforward packet radio terminal for ham radio enthusiasts.
    '';
    homepage = "https://github.com/mfncooper/paracon";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "paracon";
  };
}
