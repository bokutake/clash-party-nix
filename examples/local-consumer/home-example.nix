{ ... }:

{
  imports = [ ./profile-balanced.nix ];

  home.stateVersion = "25.05";

  programs.clash-party = {
    enable = true;
    package = null;
  };
}
