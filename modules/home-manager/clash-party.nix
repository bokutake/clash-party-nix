{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optional
    recursiveUpdate
    types
    ;

  cfg = config.programs.clash-party;
  yaml = pkgs.formats.yaml { };
  helpers = import ../../lib/config-map.nix { inherit lib; };
  customTypes = import ../../lib/types.nix { inherit lib; };
  nullOr = customTypes.nullOr;

  resolvedMixedPort =
    if cfg.ports.mixed.port != null then
      cfg.ports.mixed.port
    else
      cfg.links.mixedPort;

  resolvedDnsListen =
    if cfg.mihomo.dns.listen != null then
      cfg.mihomo.dns.listen
    else
      cfg.links.dnsListen;

  appConfig =
    helpers.compactAttrs (
      optionalAttrs (cfg.startup.silent != null) { silentStart = cfg.startup.silent; }
      // optionalAttrs (cfg.startup.autoCheckUpdate != null) {
        autoCheckUpdate = cfg.startup.autoCheckUpdate;
      }
      // optionalAttrs (cfg.app.useWindowFrame != null) { useWindowFrame = cfg.app.useWindowFrame; }
      // optionalAttrs (cfg.app.proxyInTray != null) { proxyInTray = cfg.app.proxyInTray; }
      // optionalAttrs (cfg.app.controlDns != null) { controlDns = cfg.app.controlDns; }
      // optionalAttrs (cfg.app.controlSniff != null) { controlSniff = cfg.app.controlSniff; }
      // optionalAttrs (resolvedMixedPort != null) { showMixedPort = resolvedMixedPort; }
    );

  mihomoConfig =
    helpers.compactAttrs (
      optionalAttrs (cfg.mihomo.mode != null) { mode = cfg.mihomo.mode; }
      // optionalAttrs (resolvedMixedPort != null) { "mixed-port" = resolvedMixedPort; }
      // optionalAttrs (cfg.mihomo.tun.enable != null) {
        tun = { enable = cfg.mihomo.tun.enable; };
      }
      // optionalAttrs (
        cfg.mihomo.dns.enable != null
        || resolvedDnsListen != null
      ) {
        dns = helpers.compactAttrs (
          optionalAttrs (cfg.mihomo.dns.enable != null) { enable = cfg.mihomo.dns.enable; }
          // optionalAttrs (resolvedDnsListen != null) { listen = resolvedDnsListen; }
        );
      }
    );

  stateDir = "${config.xdg.configHome}/${cfg.configDirName}";
  appConfigFile = yaml.generate "clash-party-config.yaml" appConfig;
  mihomoConfigFile = yaml.generate "clash-party-mihomo.yaml" mihomoConfig;
in
{
  options.programs.clash-party = {
    enable = mkEnableOption "Clash Party Home Manager integration";

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Optional Clash Party package to add to home.packages.";
    };

    configDirName = mkOption {
      type = types.str;
      default = "clash-party";
      description = "Configuration directory name under XDG config home.";
    };

    links = {
      mixedPort = mkOption {
        type = nullOr types.port;
        default = null;
        description = "Externally linked mixed proxy port.";
      };

      dnsListen = mkOption {
        type = nullOr types.str;
        default = null;
        description = "Externally linked Mihomo DNS listen address.";
      };
    };

    startup = {
      silent = mkOption {
        type = nullOr types.bool;
        default = null;
      };

      autoCheckUpdate = mkOption {
        type = nullOr types.bool;
        default = null;
      };
    };

    app = {
      useWindowFrame = mkOption {
        type = nullOr types.bool;
        default = null;
      };

      proxyInTray = mkOption {
        type = nullOr types.bool;
        default = null;
      };

      controlDns = mkOption {
        type = nullOr types.bool;
        default = null;
      };

      controlSniff = mkOption {
        type = nullOr types.bool;
        default = null;
      };
    };

    ports.mixed.port = mkOption {
      type = nullOr types.port;
      default = null;
    };

    mihomo = {
      mode = mkOption {
        type = nullOr (types.enum [ "rule" "global" "direct" ]);
        default = null;
      };

      tun.enable = mkOption {
        type = nullOr types.bool;
        default = null;
      };

      dns = {
        enable = mkOption {
          type = nullOr types.bool;
          default = null;
        };

        listen = mkOption {
          type = nullOr types.str;
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    warnings =
      optional (appConfig ? githubToken)
        "programs.clash-party app/githubToken will be stored in the Nix store; prefer setting it in the UI."
      ++ optional (appConfig ? gistAgeSecretKey)
        "programs.clash-party app/gistAgeSecretKey will be stored in the Nix store; prefer setting it in the UI.";

    home.packages = optional (cfg.package != null) cfg.package;

    home.activation.clashPartyDeclarativeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${stateDir}"
      install -m 0644 "${appConfigFile}" "${stateDir}/config.yaml"
      install -m 0644 "${mihomoConfigFile}" "${stateDir}/mihomo.yaml"
    '';
  };
}
