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
  # Tracks master: the latest tagged release (v0.3.2) is behind the
  # protocol and licensing work on master.
  version = "0.3.2-unstable-2026-11-23";

  src = fetchFromGitHub {
    owner = "notepid";
    repo = "vardeFM";
    rev = "29bcf4f9db0b635eef05225e2b1ecb545ee52e73";
    hash = "sha256-rabduH3e9+6lJg7D3+4wpuX8BApSCdk+oeaZ15ohGNE=";
  };

  cargoHash = "sha256-LNez4AzA2j82IR3thAJEEJelpnmJZ6R4OniHfd7K6vk=";

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
    install -Dm644 $src/LICENSE-MIT $out/share/doc/vardefm/LICENSE-MIT
    install -Dm644 $src/LICENSE-APACHE $out/share/doc/vardefm/LICENSE-APACHE
    install -Dm644 $src/packaging/linux/99-vardefm-cm108.rules \
      $out/lib/udev/rules.d/99-vardefm-cm108.rules
  '';

  meta = with lib; {
    description = "Open-source VARA FM-compatible data modem for FM radios";
    # Master relicensed from GPL-3.0-or-later to MIT OR Apache-2.0 after
    # v0.3.2; releases through 0.3.2 remain GPL-3.0-or-later.
    license = with licenses; [ mit asl20 ];
    longDescription = ''
      VardeFM is a cross-platform high-speed data modem for FM radios.  It
      provides VARA FM's TCP command/data interface, so Winlink clients such
      as Pat and packet BBS software can use it in place of VARA FM.  Both
      ends of a link must run VardeFM; it is not on-air compatible with VARA.
    '';
    homepage = "https://github.com/notepid/vardeFM";
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "vardefm";
  };
}
