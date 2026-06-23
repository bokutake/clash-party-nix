{ lib, osConfig, ... }:

let
  clashPartyEnabled =
    (osConfig.desktop.clash.frontend or null) == "party"
    || (osConfig.desktop.clash-party.enable or false);
in
{
  home.activation.removeLegacyClashDesktopEntries = lib.mkIf clashPartyEnabled (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.config/autostart/Clash Verge.desktop"
      rm -f "$HOME/.local/share/applications/Clash Verge.desktop"
      rm -f "$HOME/.local/share/applications/clash-verge.desktop"
    ''
  );

  programs.clash-party = lib.mkIf clashPartyEnabled {
    startup = {
      silent = true;
      autoCheckUpdate = false;
    };

    systemProxy = {
      enable = true;
      mode = "manual";
    };

    features = {
      controlDns = true;
      controlSniff = true;
      tcpConcurrent = true;
      tun.enable = true;
    };

    ports = {
      socks.enable = false;
      http.enable = false;
    };

    dns.fakeIpFilterMode = "blacklist";

    mihomo = {
      profile = {
        storeSelected = true;
        storeFakeIp = true;
      };

      tun = {
        stack = "mixed";
        autoRoute = true;
        autoRedirect = true;
        autoDetectInterface = true;
        dnsHijack = [ "any:53" ];
        mtu = 1500;
        device = "Mihomo";
        strictRoute = true;
      };

      dns = {
        ipv6 = false;
        defaultNameserver = [ "tls://223.5.5.5" ];
        nameserver = [
          "https://doh.pub/dns-query"
          "https://dns.alidns.com/dns-query"
        ];
        proxyServerNameserver = [
          "https://doh.pub/dns-query"
          "https://dns.alidns.com/dns-query"
        ];
        fallbackFilter = {
          geoip = true;
          geoipCode = "CN";
          ipcidr = [ "240.0.0.0/4" "0.0.0.0/32" ];
          domain = [ "+.google.com" "+.facebook.com" "+.youtube.com" ];
        };
      };

      sniffer = {
        parsePureIp = true;
        forceDnsMapping = true;
        skipDomain = [ "+.push.apple.com" ];
        skipDstAddress = [
          "91.105.192.0/23"
          "91.108.4.0/22"
          "91.108.8.0/21"
          "91.108.16.0/21"
          "91.108.56.0/22"
          "95.161.64.0/20"
          "149.154.160.0/20"
          "185.76.151.0/24"
          "2001:67c:4e8::/48"
          "2001:b28:f23c::/47"
          "2001:b28:f23f::/48"
          "2a0a:f280:203::/48"
        ];
      };
    };
  };
}
