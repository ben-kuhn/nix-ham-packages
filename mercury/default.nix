{ lib
, stdenv
, fetchFromGitHub
, libpulseaudio
, alsa-lib
}:

stdenv.mkDerivation rec {
  pname = "mercury-modem";
  version = "1.9.9";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury";
    rev = "v${version}";
    sha256 = "0d00dqs367c0f716dc90rb64mld9dv98w75pk1xk5bbpm7pz2m5q";
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
