{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tncd-go";
  version = "2.0.0-dev";

  # TODO: update after v2-go-port branch is pushed to GitHub:
  #   nix-prefetch-url --unpack https://github.com/ben-kuhn/tncd/archive/c32f2c9081e3c564dec446e23c7617f5a07417a9.tar.gz
  #   nix hash convert --hash-algo sha256 --to sri <hash>
  # and replace lib.fakeHash below with the resulting sri hash.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "c32f2c9081e3c564dec446e23c7617f5a07417a9";
    hash = lib.fakeHash;
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
