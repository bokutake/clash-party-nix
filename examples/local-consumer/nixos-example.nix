{ pkgs, ... }:

{
  imports = [ ./adapter.nix ];

  users.users.demo = {
    isNormalUser = true;
    home = "/home/demo";
  };

  desktop.proxy = {
    enable = true;
    mixedPort = 7897;
    dnsPort = 11453;
    systemProxy = {
      enable = true;
      mode = "manual";
    };
  };

  programs.clash-party = {
    enable = true;
    package = pkgs.runCommandNoCC "fake-clash-party" { } ''
      mkdir -p "$out/lib/clash-party/resources/nix-sidecar-store"
      touch "$out/lib/clash-party/resources/nix-sidecar-store/mihomo.bin.real"
      touch "$out/lib/clash-party/resources/nix-sidecar-store/mihomo-alpha.bin.real"
      touch "$out/lib/clash-party/resources/nix-sidecar-store/mihomo-smart.bin.real"
    '';
  };

  home-manager.users.demo = import ./home-example.nix;

  system.stateVersion = "25.05";
}
