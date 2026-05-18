{
  lib,
  python3Packages,
  fetchFromGitHub,
  pyham-ax25,
  kiss3,
  bluetoothSupport ? false,
}:

python3Packages.buildPythonApplication rec {
  pname = "tncd";
  version = "0.11-BETA";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "v0.11-BETA";
    hash = "sha256-BGPOq/vclS2FXnoAS7BKIW1WRn6+5IAQmoOkxYNtTdQ=";
  };

  format = "other";

  disabled = python3Packages.pythonOlder "3.8";

  dependencies = [
    python3Packages.pyserial
    pyham-ax25
    kiss3
  ] ++ lib.optionals bluetoothSupport (with python3Packages; [
    dbus-python
    pygobject3
  ]);

  installPhase = ''
    install -Dm755 tncd.py      $out/bin/tncd
    install -Dm755 tncd-rfcomm  $out/bin/tncd-rfcomm
    install -Dm644 tncd.ini     $out/share/tncd/tncd.ini.example
  '';

  meta = with lib; {
    description = "AGWPE-to-KISS Translation Bridge";
    longDescription = ''
      A bridge that allows AGWPE-client applications to communicate with KISS TNCs.
      Supports both serial and TCP KISS connections.
    '';
    homepage = "https://github.com/ben-kuhn/tncd";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "tncd";
  };
}
