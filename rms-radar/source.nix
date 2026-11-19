{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "9dc2a83d1e88cf8f613cc1f8bc872ec36c337352";
  hash = "sha256-GcgZ45ASWyS0TJ5MGUv3sHrVLQlAbqJDgN3GofdUoRc=";
}
