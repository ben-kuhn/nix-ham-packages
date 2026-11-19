{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "68063b315525e0394e496aa86f91ab893f2ee434";
  hash = "sha256-4MuT4Josr0d8ixQ1Pdo2TxZ5ZlDwfFgaiRHsaMn9Cz8=";
}
