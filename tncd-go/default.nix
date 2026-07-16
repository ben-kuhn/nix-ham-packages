{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tncd-go";
  version = "2.0.0-dev";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "67ad3658e4f4d750f600624393a0cc4fe9748a22";
    hash = "sha256-nGXzAJLZLBTkMF7vG1F3r/WDm+6fM7vl0sw4YqQY8iQ=";
  };

  # vendorHash was extracted from a local-src build of the same commit:
  #   nix-build /path/to/scratch.nix  (src = lib.cleanSource /home/ku0hn/dev/tncd)
  # The mismatch error from fakeHash revealed this real hash.
  vendorHash = "sha256-FFRXOD48HO+2C3m95wkFYpAIXmHytpXFSxl5TYbnjR8=";

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ben-kuhn/tncd/v2/internal/version.Version=${version}"
  ];

  # Install as tncd-go so it never collides with the production tncd (Python) package.
  postInstall = ''
    mv $out/bin/tncd $out/bin/tncd-go
  '';

  meta = with lib; {
    description = "AGWPE-to-KISS Translation Bridge (Go port, 2.0 dev — serial OTA testing)";
    longDescription = ''
      Interim Nix package for the tncd 2.0 Go port, tracking the v2-go-port
      branch for serial OTA validation. Not yet production-ready; use the
      `tncd` package for the stable Python implementation.
    '';
    homepage = "https://tncd.dev";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "tncd-go";
  };
}
