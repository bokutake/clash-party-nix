{ ... }:

{
  programs.clash-party = {
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

    app = {
      useWindowFrame = false;
      proxyInTray = true;
      showCurrentProxyInTray = false;
      enableTrafficLogger = true;
      trayProxyGroupStyle = "default";
      disableTrayIconColor = false;
      customTrayIcon = "";
      maxLogDays = 7;
      maxLogFileSize = 10;
      disableAppLog = false;
      proxyCols = "auto";
      connectionDirection = "asc";
      connectionOrderBy = "time";
      autoQuitWithoutCore = false;
      autoQuitWithoutCoreDelay = 60;
      autoQuitWithoutCoreMode = "core";
      proxyDisplayMode = "simple";
      proxyDisplayOrder = "default";
      testProfileOnStart = true;
      useNameserverPolicy = false;
      nameserverPolicy = { };
      floatingWindowCompatMode = true;
      disableHardwareAcceleration = false;
      hideConnectionCardWave = false;
      siderOrder = [
        "sysproxy"
        "tun"
        "profile"
        "proxy"
        "rule"
        "resource"
        "override"
        "connection"
        "mihomo"
        "dns"
        "sniff"
        "log"
        "substore"
        "network"
        "usage"
      ];
      siderWidth = 250;
      triggerMainWindowBehavior = "show";
    };

    mihomo = {
      mode = "rule";

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
        enable = true;
        ipv6 = false;
        enhancedMode = "fake-ip";
      };

      sniffer = {
        parsePureIp = true;
        forceDnsMapping = true;
      };
    };
  };
}
