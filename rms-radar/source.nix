{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "f286220d4445ae521376b751631d7a26e202c937";
  hash = "sha256-5PvaGyZvnU8R/xS7LFeVgkXTAS9QfIwnJlpQOP+ACe4=";
}
