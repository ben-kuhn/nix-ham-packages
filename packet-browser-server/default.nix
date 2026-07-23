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
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "packet-browser";
    rev = "v${version}";
    hash = "sha256-1xeGiT/dKezuk7hcR/66ly35LdflHFpi5Vl2+mDb2hQ=";
  };

  cargoHash = "sha256-718jmHjGPlsefoJ2Kx/hXQB8w+XxVVxlRlr4KI5snJ8=";

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
