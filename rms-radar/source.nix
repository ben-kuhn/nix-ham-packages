{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "0fb9da18c9ac097d252c9467100cbb3afdfe7f30";
  hash = "sha256-shGOuFnde1Zdw/8lD+HBN4fI5cBCevDAuaK7kivDBCU=";
}
