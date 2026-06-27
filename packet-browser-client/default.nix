{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "packet-browser-client";
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
  ];

  buildInputs = [
    openssl
  ];

  cargoBuildFlags = [
    "--bin"
    "packet-browser-client"
  ];

  # Tests require single-threaded execution due to env var manipulation
  doCheck = false;

  postInstall = ''
    # Install example config
    install -Dm644 $src/client/config.example.ini \
      $out/share/packet-browser/config.ini.example
  '';

  meta = {
    description = "Packet radio web browser client - AGWPE client with web proxy interface";
    homepage = "https://github.com/ben-kuhn/docker-packet-browser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "packet-browser-client";
  };
}
