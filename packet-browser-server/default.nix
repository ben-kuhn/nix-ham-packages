{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
  rustfmt,
}:

rustPlatform.buildRustPackage rec {
  pname = "packet-browser-server";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "docker-packet-browser";
    rev = "v${version}";
    hash = "sha256-O8i6VcbdaWaHheRFo/N219u/ALOjr8ZQNXJ+SdOh6uE=";
  };

  cargoHash = "sha256-/xdcaJTacEK79mx0F69LgscaWuSlkauZAfv6uBU/u7o=";

  nativeBuildInputs = [
    pkg-config
    perl
    rustfmt
  ];

  buildInputs = [
    openssl
  ];

  cargoBuildFlags = [
    "--bin"
    "packet-browser-server"
  ];

  # Tests require single-threaded execution due to env var manipulation
  doCheck = false;

  meta = {
    description = "Packet radio web browser server - fetches and sanitizes web pages for AX.25";
    homepage = "https://github.com/ben-kuhn/docker-packet-browser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "packet-browser-server";
  };
}
