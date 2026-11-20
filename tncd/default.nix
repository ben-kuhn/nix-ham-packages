{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# tncd 2.0 — pure-Go rewrite of the AGWPE-to-KISS AX.25 bridge.
# (The 1.x Python line is maintenance-only on the `v1` git branch; the public
#  APT/RPM repos serve the Go line since v2.0.0.)
buildGoModule rec {
  pname = "tncd";
  version = "2.0.0";

  # The stable release tag, not the development tree.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "v2.0.0";
    hash = "sha256-jFBkN6yJc1K55+gb06eDiZKkzdBjhdwxCnQIpwGaNtc=";
  };

  # go.mod is unchanged since the tncd-go dev package; same vendorHash.
  vendorHash = "sha256-iRvDXz9Dn7Pi6m2rA+nwgDYCgqd3KWJATBMSKvxwRZ8=";

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
