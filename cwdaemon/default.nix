{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  unixcw,
}:

stdenv.mkDerivation rec {
  pname = "cwdaemon";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "acerion";
    repo = "cwdaemon";
    rev = "v${version}";
    hash = "sha256-t9wkejT6VagPR7sxZ9GI1g1Rq/RDy8YXv4q6/HhCUJg=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ unixcw ];

  meta = with lib; {
    description = "Morse code (CW) keying daemon controlled over UDP";
    longDescription = ''
      cwdaemon is a small daemon that uses libcw to send Morse code through
      the serial, parallel, or sound-card port of a PC. Clients (such as
      Not1MM) send commands to cwdaemon over a UDP socket.
    '';
    homepage = "https://github.com/acerion/cwdaemon";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "cwdaemon";
  };
}
