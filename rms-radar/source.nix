{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "bdc81e1f57cf46ea17ccab7fee8617b7bf52989b";
  hash = "sha256-QQs0z5VAjurkkukB56AFmtUVdvsrDlX5Vaynn0i4BaM=";
}
