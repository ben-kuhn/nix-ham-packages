{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "notctyparser";
  version = "26.8.31";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZUIqnI+xVs8StZ/UJFYEpsV6VtP4U+SlUYm3HToQSsg=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    feedparser
    requests
    lxml
  ];

  doCheck = false;
  pythonImportsCheck = [ "notctyparser" ];

  meta = with lib; {
    description = "Country (CTY) file parser used by Not1MM";
    homepage = "https://pypi.org/project/notctyparser/";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
