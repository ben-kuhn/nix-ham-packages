{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "c480f4b86ff5ee1fca0cd4a69724076718b79211";
  hash = "sha256-Z+/8dYN7YTzpY183X+u9GiFi3Pii62RL/wvyu6Ms6/k=";
}
