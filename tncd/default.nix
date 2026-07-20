{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# tncd 2.0 — pure-Go rewrite of the AGWPE-to-KISS AX.25 bridge.
# (The 1.x Python line lives on the `v1` git branch and the stable
#  APT/RPM repos; this package tracks the 2.0 Go beta line.)
buildGoModule rec {
  pname = "tncd";
  version = "1.97-Beta";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "v${version}";
    hash = "sha256-X7H7QVI+yNiojiQfSnEehCgm/aN9DLxdMBc3PNhDcA8=";
  };

  # go.mod is unchanged since the tncd-go dev package; same vendorHash.
  vendorHash = "sha256-FFRXOD48HO+2C3m95wkFYpAIXmHytpXFSxl5TYbnjR8=";

  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/tncd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ben-kuhn/tncd/v2/internal/version.Version=${version}"
  ];

  postInstall = ''
    install -Dm644 tncd.ini $out/share/tncd/tncd.ini.example
  '';

  meta = with lib; {
    description = "AGWPE-to-KISS Translation Bridge (Go)";
    longDescription = ''
      A bridge that allows AGWPE-client applications (PAT/Winlink, Paracon,
      Xastir) to communicate with KISS TNCs over serial, TCP, or Bluetooth SPP.
      Implements AX.25 layer-2 connected mode. Pure-Go 2.0 rewrite.
    '';
    homepage = "https://tncd.dev";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "tncd";
  };
}
