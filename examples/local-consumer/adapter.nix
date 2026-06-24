{ lib, osConfig, ... }:

let
  proxy = lib.attrByPath [ "desktop" "proxy" ] {
    enable = false;
    mixedPort = null;
    dnsPort = null;
    systemProxy = {
      enable = null;
      mode = null;
    };
  } osConfig;
in
{
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
