{ ... }:

{
  imports = [
    ./adapter.nix
    ./profile-balanced.nix
  ];

  home.username = "demo";
  home.homeDirectory = "/home/demo";
  home.stateVersion = "25.05";

  programs.clash-party = {
    enable = true;
    package = null;
  };
}
