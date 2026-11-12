{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "e2309dd82d8b39f95c5e4020d67fdd2d8aee1b98";
    hash = "sha256-1beeNhvzC1stN0Vm8R45ywOsZ7Kaz1prJ6V+e8wj3SI=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
