{ lib
, stdenv
, fetchFromGitHub
, libpulseaudio
, alsa-lib
, pkg-config
, hamlib_4
}:

stdenv.mkDerivation rec {
  pname = "mercury-modem";
  version = "1.9.25";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury";
    rev = "v${version}";
    sha256 = "057s093pb40xi6akq6v8piwq0j59gmqzvmrxnwy0336k6r8f5w0k";
  };

  hardeningDisable = [ "all" ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpulseaudio
    alsa-lib
    hamlib_4
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 mercury $out/bin/mercury
    install -Dm644 mercury.1 $out/share/man/man1/mercury.1
    install -Dm644 mercury.ini.example $out/share/doc/mercury/mercury.ini.example
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
