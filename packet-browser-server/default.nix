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
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "packet-browser";
    rev = "v${version}";
    hash = "sha256-qpRFBcgpYBr5NubjzUNJmffw0dSGjS30RjZYdoYb7O4=";
  };

  cargoHash = "sha256-R1YORIk9CXxB8rJr4ZsHBxt61yCLqu8oQT0bRGIt5eg=";

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
    homepage = "https://github.com/ben-kuhn/packet-browser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "packet-browser-server";
  };
}
