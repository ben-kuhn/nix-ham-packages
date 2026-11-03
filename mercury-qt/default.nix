{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:

let
  python = python3.withPackages (ps: [
    ps.numpy
    ps.pyside6
  ]);
in
stdenv.mkDerivation rec {
  pname = "mercury-qt";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury-qt";
    rev = "v${version}";
    hash = "sha256-xr8JwMIgD9gLuCcQzndGKMSfqxqOczrX8dbqUoTfXUg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mercury-qt
    cp -r app.py apps assets core $out/share/mercury-qt/

    makeWrapper ${python}/bin/python3 $out/bin/mercury-qt \
      --add-flags "$out/share/mercury-qt/app.py mercury" \
      --prefix PYTHONPATH : "$out/share/mercury-qt"

    runHook postInstall
  '';

  meta = with lib; {
    description = "PySide6 desktop client for the Mercury HERMES HF modem";
    longDescription = ''
      Mercury Qt connects to a running Mercury backend over its WebSocket UI
      channel (port 10000 by default). Start the backend with `mercury -G`
      before launching the GUI.
    '';
    homepage = "https://github.com/Rhizomatica/mercury-qt";
    changelog = "https://github.com/Rhizomatica/mercury-qt/releases/tag/v${version}";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mercury-qt";
  };
}
