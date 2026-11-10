{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "34f9a0958bd448654f64a5c787e30af46243276d";
    hash = "sha256-5ZIgTEATa8eH1ThU5U2BCkwxS7j/QVkGpjfLaoxE0Rk=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
