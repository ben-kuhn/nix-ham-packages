{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "be02f36eb9132c8e728b98be992b7c2986267d1d";
    hash = "sha256-s7omuAjYVmGz43600urG9UdrCAmCKhs3RdhhnQmy724=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
