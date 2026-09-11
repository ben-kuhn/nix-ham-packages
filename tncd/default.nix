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
  version = "1.101-Beta+txfix";

  # Field-testing the fix/tx-silent-failure branch ahead of a tagged release:
  # the Bluetooth TX path could accept writes that never reached the air, and
  # tncd reported them as transmitted. Pinned to a commit rather than a tag
  # until this has on-air time; restore the `rev = "v${version}"` form at the
  # next release.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "f6dcfb755f5f280922e4e32bf8e0435186897cc6";
    hash = "sha256-rt/35lTGZtgIHnDoDVJMlkHxU6LQaUD/2grmAUGfo9Y=";
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
