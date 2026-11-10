{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "6b7488bef7eed76ca6d6d9461a08ccaaf4dbc47b";
    hash = "sha256-XX6LSsxzSr33nWcGFsB4EYjSlMnb7fzpK6i09dPVUm8=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
