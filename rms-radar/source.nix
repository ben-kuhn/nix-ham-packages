{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "5d9b83fe30f5eec8b7b5be4a3a4b53917a036ce8";
  hash = "sha256-Q+mx8jufBVD+BtTDxRauWlJnqq3dQC5RftT20Ml8xjA=";
}
