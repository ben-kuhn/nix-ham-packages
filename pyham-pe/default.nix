{
  lib,
  python3Packages,
  fetchPypi,
  pyham-ax25,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyham_pe";
  version = "1.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YzQzsVOgMjK4fAcpuEQdtWVKi0vUpxXdlDMzmkM5EvA=";
  };

  build-system = [ python3Packages.flit-core ];

  dependencies = [ pyham-ax25 ];

  # No tests in the package
  doCheck = false;

  pythonImportsCheck = [ "pe" ];

  meta = with lib; {
    description = "Packet Engine client for the AGWPE protocol";
    longDescription = ''
      pyham_pe provides a full client library for the AGWPE (AGW Packet Engine)
      protocol used in amateur packet radio. It enables Python applications to
      communicate with AGWPE-compatible servers like Direwolf and ldsped.

      Features:
      - Connected mode AX.25 sessions
      - Unproto (datagram) mode
      - Multiple simultaneous connections
      - Asynchronous event handling
    '';
    homepage = "https://github.com/mfncooper/pyham_pe";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
