{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyham_ax25";
  version = "1.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VREevLvlwaXFdoHgKqyyirByWYwvFpDnDQhktn4f06w=";
  };

  build-system = [ python3Packages.flit-core ];

  # No tests in the package
  doCheck = false;

  pythonImportsCheck = [ "ax25" ];

  meta = with lib; {
    description = "Modules for working with AX.25 packets in amateur packet radio";
    longDescription = ''
      pyham_ax25 provides Python modules for encoding and decoding AX.25
      packets used in amateur packet radio communications. It supports
      the full AX.25 protocol including NET/ROM extensions.
    '';
    homepage = "https://github.com/mfncooper/pyham_ax25";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
