{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "appdata";
  version = "2.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MSIkHhaJ64vjau4orzvwgP4hbjzI+rta9ngmsUmDepI=";
  };

  build-system = [ python3Packages.setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "appdata" ];

  meta = with lib; {
    description = "Helpers for XDG-style app data directories";
    homepage = "https://pypi.org/project/appdata/";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
