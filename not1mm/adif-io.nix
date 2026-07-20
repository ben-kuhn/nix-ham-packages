{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "adif_io";
  version = "0.6.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CmUtWb1U8/AF21yPCnwLVhqH35ZSakspKRhxoTnH9xU=";
  };

  build-system = [ python3Packages.setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "adif_io" ];

  meta = with lib; {
    description = "Pure Python ADIF (Amateur Data Interchange Format) reader/writer";
    homepage = "https://pypi.org/project/adif-io/";
    license = licenses.isc;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
