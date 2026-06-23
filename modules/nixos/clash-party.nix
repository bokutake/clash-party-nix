{ config, lib, pkgs, ... }:

let
  cfg = config.programs.clash-party;
in
{
  options.programs.clash-party = {
    enable = lib.mkEnableOption "Clash Party system integration";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Clash Party package to install when the system integration is enabled.";
    };

    sidecar.directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/clash-party/sidecar";
      description = "Writable runtime directory exposed to Clash Party for privileged Mihomo sidecars.";
    };

    sidecar.installSetuid = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install copied Mihomo sidecars as root-owned setuid binaries.";
    };

    sidecar.names = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "mihomo"
        "mihomo-alpha"
        "mihomo-smart"
      ];
      description = "Names of bundled Mihomo sidecars to materialize into the runtime sidecar directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package != null;
        message = "programs.clash-party.package must be set when programs.clash-party.enable = true.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d /var/lib/clash-party 0755 root root -"
      "d ${cfg.sidecar.directory} 0755 root root -"
    ];

    system.activationScripts.clashPartySidecars.text =
      let
        mode =
          if cfg.sidecar.installSetuid then
            "4755"
          else
            "0755";
      in
      ''
        install_core() {
          local src="$1"
          local dst="$2"
          ${pkgs.coreutils}/bin/install -D -m ${mode} -o root -g root "$src" "$dst"
        }
      ''
      + lib.concatMapStrings (name: ''
        install_core \
          "${cfg.package}/lib/clash-party/resources/nix-sidecar-store/${name}.bin.real" \
          "${cfg.sidecar.directory}/${name}"
        install_core \
          "${cfg.package}/lib/clash-party/resources/nix-sidecar-store/${name}.bin.real" \
          "${cfg.sidecar.directory}/${name}.bin"
      '') cfg.sidecar.names;
  };
}
