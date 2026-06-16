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
  version = "1.1";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "v1.1";
    hash = "sha256-AfBURXbiW74nbkWqaaaHo1ZaAOIF9RDeCTpH/pbOXkg=";
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
    install -Dm644 tncd.ini     $out/share/tncd/tncd.ini.example
  '';

  meta = with lib; {
    description = "AGWPE-to-KISS Translation Bridge";
    longDescription = ''
      A bridge that allows AGWPE-client applications to communicate with KISS TNCs.
      Supports both serial and TCP KISS connections.
    '';
    homepage = "https://tncd.dev";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "tncd";
  };
}
