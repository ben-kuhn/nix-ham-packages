{
  lib,
  python3Packages,
  fetchPypi,
  qt6,
  notctyparser,
  adif-io,
  appdata,
}:

python3Packages.buildPythonApplication rec {
  pname = "not1mm";
  version = "26.10.11";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-S5nNa2bXFL2sqSQZRV+uPPOpJxMQ44jr0jSyyh8k3W8=";
  };

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  buildInputs = [ qt6.qtbase ];

  dontWrapQtApps = false;

  dependencies = (with python3Packages; [
    pyqt6
    requests
    dicttoxml
    xmltodict
    pyserial
    sounddevice
    soundfile
    numpy
    rapidfuzz
  ]) ++ [
    notctyparser
    adif-io
    appdata
  ];

  doCheck = false;
  pythonImportsCheck = [ "not1mm" ];

  meta = with lib; {
    description = "Amateur radio contest logger (PyQt6)";
    longDescription = ''
      Not1MM is an amateur radio contest logger written in Python and PyQt6.
      It connects to rigctld (from hamlib) for radio control and to cwdaemon
      over UDP for CW keying; both daemons are run separately by the user.
    '';
    homepage = "https://github.com/mbridak/not1mm";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "not1mm";
  };
}
