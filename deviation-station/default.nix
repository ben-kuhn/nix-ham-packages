{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "deviation-station";
    rev = "273a9ce6f69b205fac5ad664f0794996fefc90df";
    hash = "sha256-Y3H2IGsba05JMpssv2FPmXWhwWzfZp148JYMfHydquc=";
  };
in
callPackage "${src}/nix/package.nix" {
  applicationSrc = src;
}
