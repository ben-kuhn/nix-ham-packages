{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "ax253";
  version = "0.1.5.post1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FhQaeis6Y1qMDY3GvqebmpENnsIWSRTp5MfQJVeoCo8=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    attrs
    bitarray
    importlib-metadata
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = false;

  pythonImportsCheck = [ "ax253" ];

  meta = with lib; {
    description = "Experimental pure Python AX.25 stack";
    homepage = "https://github.com/python-aprs/ax253";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
