{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  udev,
}:

rustPlatform.buildRustPackage rec {
  pname = "vardefm";
  # Tracks master: the latest tagged release (v0.3.1) is well behind the
  # protocol work on master.
  version = "0.3.1-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "notepid";
    repo = "vardeFM";
    rev = "40c448ae99c9029adc50497081c4bce8fd676bc2";
    hash = "sha256-z1M7+MuQQtO5JytxH/FQ9EZAwybQFQsTj/W9CxzJa74=";
  };

  cargoHash = "sha256-zvP5xnh1b9Q8mxSbpO0gJN/AlpQX6LXBBgnhhq4JGeg=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    udev
  ];

  buildAndTestSubdir = "crates/vardefm-cli";

  # The test suite exercises live sound-card paths and is run upstream in CI.
  doCheck = false;

  postInstall = ''
    install -Dm644 $src/packaging/README.md \
      $out/share/doc/vardefm/README.md
    install -Dm644 $src/docs/RADIO.md \
      $out/share/doc/vardefm/RADIO.md
    install -Dm644 $src/docs/PROTOCOL.md \
      $out/share/doc/vardefm/PROTOCOL.md
    install -Dm644 $src/LICENSE $out/share/doc/vardefm/LICENSE
    install -Dm644 $src/packaging/linux/99-vardefm-cm108.rules \
      $out/lib/udev/rules.d/99-vardefm-cm108.rules
  '';

  meta = with lib; {
    description = "Open-source VARA FM-compatible data modem for FM radios";
    longDescription = ''
      VardeFM is a cross-platform high-speed data modem for FM radios.  It
      provides VARA FM's TCP command/data interface, so Winlink clients such
      as Pat and packet BBS software can use it in place of VARA FM.  Both
      ends of a link must run VardeFM; it is not on-air compatible with VARA.
    '';
    homepage = "https://github.com/notepid/vardeFM";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "vardefm";
  };
}
