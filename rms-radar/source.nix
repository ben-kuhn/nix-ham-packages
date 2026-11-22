{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "ea7b13ec89b5156e63784b94d82e21162b25c582";
  hash = "sha256-K9E5N80mozVojnaRKC8OH+bbvkgQS4XgdlUkFWznFVU=";
}
