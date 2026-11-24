{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "9088279459a52ccca0265853cf06d984c8c7d018";
  hash = "sha256-qb+vgsG2zXtHCbcNAmrIesCmidUDEnzyM+AIqytkaxM=";
}
