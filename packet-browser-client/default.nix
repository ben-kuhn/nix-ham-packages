{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  rustfmt,
}:

rustPlatform.buildRustPackage rec {
  pname = "packet-browser-client";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "packet-browser";
    rev = "v${version}";
    hash = "sha256-SszXx7c4mGE95ogfFKR3mC8Kd7cqQOHzsEZ9b/tlE2k=";
  };

  cargoHash = "sha256-juo2bSusBY/FUkv0QWUK3dHxEURsQUEdnLJgTheDrLU=";

  nativeBuildInputs = [
    pkg-config
    rustfmt
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
    homepage = "https://github.com/ben-kuhn/packet-browser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "packet-browser-client";
  };
}
