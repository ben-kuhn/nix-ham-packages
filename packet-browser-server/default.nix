{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  perl,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "packet-browser-server";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "docker-packet-browser";
    rev = "v${version}";
    hash = ""; # Update with: nix-prefetch-git --rev v0.2.0 https://github.com/ben-kuhn/docker-packet-browser.git
  };

  cargoHash = ""; # Update with actual hash after first build attempt

  nativeBuildInputs = [
    pkg-config
    perl
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
