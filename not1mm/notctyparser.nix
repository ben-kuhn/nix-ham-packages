{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "notctyparser";
  version = "23.6.21";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6NzyxITeow02pOGB0cm/L4bfQ1MdENVHbNFwPMnXCu8=";
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
