{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "472515079e83c71440402fa11961355cf82a6ee6";
    hash = "sha256-f3xdr4XBemCMRDDALLZDoQ8u2JGBE4V04MHqrVwkGQY=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
