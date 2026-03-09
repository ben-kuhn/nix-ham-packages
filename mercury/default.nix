{ lib
, stdenv
, fetchFromGitHub
, libpulseaudio
, alsa-lib
}:

stdenv.mkDerivation rec {
  pname = "mercury-modem";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury";
    rev = "v${version}";
    sha256 = "15s8f7mjz4y8k8699zl6vl642hwq0zn54iy1900l71ax8aih97v4";
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
