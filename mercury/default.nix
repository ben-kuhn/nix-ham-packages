{ lib
, stdenv
, fetchFromGitHub
, libpulseaudio
, alsa-lib
}:

stdenv.mkDerivation rec {
  pname = "mercury-modem";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury";
    rev = "v${version}";
    sha256 = "04fc46pp92rvcr4xbcfsln7nqaasczdsgw98p93hcil4j808msn7";
  };

  hardeningDisable = [ "all" ];

  buildInputs = [
    libpulseaudio
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 mercury $out/bin/mercury
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mercury is a free software software-defined High-Frequency Modem";
    longDescription = ''
      Mercury is a free software software-defined modem solution for the High-Frequency (HF) band.
    '';
    homepage = "https://github.com/Rhizomatica/mercury";
    changelog = "https://github.com/Rhizomatica/mercury/releases/tag/v${version}";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
