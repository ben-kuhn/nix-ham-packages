{
  lib,
  python3Packages,
  fetchPypi,
  ax253,
}:

python3Packages.buildPythonPackage rec {
  pname = "kiss3";
  version = "8.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-B2AGoNejYVdTMZbR5BeHshfL1aTjSLIDIsKrba4jhCU=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    attrs
    ax253
    bitarray
    importlib-metadata
    pyserial-asyncio
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = false;

  pythonImportsCheck = [ "kiss" ];

  meta = with lib; {
    description = "Pure-Python implementation of serial KISS and KISS-over-TCP protocols for communicating with TNC devices";
    homepage = "https://github.com/python-aprs/kiss3";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
