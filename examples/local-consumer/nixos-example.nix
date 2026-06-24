{ lib, pkgs, ... }:

{
  options.desktop.proxy = {
    enable = lib.mkEnableOption "example local proxy adapter";

    mixedPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
    };

    dnsPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
    };

    systemProxy = {
      enable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      mode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  config = {
    users.users.demo = {
      isNormalUser = true;
      home = "/home/demo";
    };

    boot.loader.grub.devices = [ "nodev" ];

    fileSystems."/" = {
      device = "/dev/disk/by-label/example-root";
      fsType = "ext4";
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
  };
}
