{ config, lib, ... }:

let
  proxy = config.desktop.proxy;
in
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

  config = lib.mkIf proxy.enable {
    programs.clash-party.links = {
      mixedPort = proxy.mixedPort;
      dnsListen =
        if proxy.dnsPort != null then
          "0.0.0.0:${toString proxy.dnsPort}"
        else
          null;
      systemProxy.enable = proxy.systemProxy.enable;
      systemProxy.mode = proxy.systemProxy.mode;
    };
  };
}
