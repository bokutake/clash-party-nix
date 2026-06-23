{ config, lib, pkgs, ... }:

let
  inherit (lib)
    any
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalAttrs
    recursiveUpdate
    types
    ;

  cfg = config.programs.clash-party;
  yaml = pkgs.formats.yaml { };
  customTypes = import ../../lib/types.nix { inherit lib; };
  helpers = import ../../lib/config-map.nix { inherit lib; };
  nullType = customTypes.nullOr;
  nullOr = type: mkOption {
    type = nullType type;
    default = null;
  };

  linkedMixedPort = cfg.links.mixedPort;
  linkedDnsListen = cfg.links.dnsListen;
  linkedSystemProxyEnable = cfg.links.systemProxy.enable;
  linkedSystemProxyMode = cfg.links.systemProxy.mode;

  resolvedRuntimeDnsListen =
    if cfg.dns.runtimeListen != null then
      cfg.dns.runtimeListen
    else if cfg.mihomo.dns.listen != null then
      cfg.mihomo.dns.listen
    else
      linkedDnsListen;
  resolvedSilentStart =
    if cfg.startup.silent != null then
      cfg.startup.silent
    else
      cfg.app.silentStart;
  resolvedAutoCheckUpdate =
    if cfg.startup.autoCheckUpdate != null then
      cfg.startup.autoCheckUpdate
    else
      cfg.app.autoCheckUpdate;
  resolvedControlDns =
    if cfg.features.controlDns != null then
      cfg.features.controlDns
    else
      cfg.app.controlDns;
  resolvedControlSniff =
    if cfg.features.controlSniff != null then
      cfg.features.controlSniff
    else
      cfg.app.controlSniff;
  resolvedTcpConcurrent =
    if cfg.features.tcpConcurrent != null then
      cfg.features.tcpConcurrent
    else
      cfg.mihomo.tcpConcurrent;
  resolvedTunEnable =
    if cfg.features.tun.enable != null then
      cfg.features.tun.enable
    else
      cfg.mihomo.tun.enable;
  resolvedFakeIpFilterMode =
    if cfg.dns.fakeIpFilterMode != null then
      cfg.dns.fakeIpFilterMode
    else
      cfg.mihomo.dns.fakeIpFilterMode;
  resolvedMixedPort =
    if cfg.ports.mixed.port != null then
      cfg.ports.mixed.port
    else if cfg.mihomo.mixedPort != null then
      cfg.mihomo.mixedPort
    else
      linkedMixedPort;
  resolvedMixedDisplayPort =
    if cfg.ports.mixed.displayPort != null then
      cfg.ports.mixed.displayPort
    else if cfg.app.showMixedPort != null then
      cfg.app.showMixedPort
    else
      resolvedMixedPort;
  resolvedMixedPortEnabled =
    if cfg.ports.mixed.enable != null then
      cfg.ports.mixed.enable
    else
      cfg.app.enableMixedPort;
  resolvedSocksPort =
    if cfg.ports.socks.port != null then
      cfg.ports.socks.port
    else
      cfg.mihomo.socksPort;
  resolvedSocksDisplayPort =
    if cfg.ports.socks.displayPort != null then
      cfg.ports.socks.displayPort
    else if cfg.app.showSocksPort != null then
      cfg.app.showSocksPort
    else
      resolvedSocksPort;
  resolvedSocksPortEnabled =
    if cfg.ports.socks.enable != null then
      cfg.ports.socks.enable
    else
      cfg.app.enableSocksPort;
  resolvedHttpPort =
    if cfg.ports.http.port != null then
      cfg.ports.http.port
    else
      cfg.mihomo.httpPort;
  resolvedHttpDisplayPort =
    if cfg.ports.http.displayPort != null then
      cfg.ports.http.displayPort
    else if cfg.app.showHttpPort != null then
      cfg.app.showHttpPort
    else
      resolvedHttpPort;
  resolvedHttpPortEnabled =
    if cfg.ports.http.enable != null then
      cfg.ports.http.enable
    else
      cfg.app.enableHttpPort;
  resolvedRedirPort =
    if cfg.ports.redir != null then
      cfg.ports.redir
    else
      cfg.mihomo.redirPort;
  resolvedTproxyPort =
    if cfg.ports.tproxy != null then
      cfg.ports.tproxy
    else
      cfg.mihomo.tproxyPort;
  resolvedSysProxyEnable =
    if cfg.systemProxy.enable != null then
      cfg.systemProxy.enable
    else if cfg.app.sysProxyEnable != null then
      cfg.app.sysProxyEnable
    else
      linkedSystemProxyEnable;
  resolvedSysProxyMode =
    if cfg.systemProxy.mode != null then
      cfg.systemProxy.mode
    else if cfg.app.sysProxyMode != null then
      cfg.app.sysProxyMode
    else
      linkedSystemProxyMode;

  stateDir = "${config.xdg.configHome}/${cfg.configDirName}";

  hasValues = attrs: any (v: if builtins.isAttrs v then hasValues v else v != null) (builtins.attrValues attrs);

  appTypedPatch =
    optionalAttrs (cfg.app.core != null) { core = cfg.app.core; }
    // optionalAttrs (cfg.app.enableSmartCore != null) { enableSmartCore = cfg.app.enableSmartCore; }
    // optionalAttrs (cfg.app.enableSmartOverride != null) { enableSmartOverride = cfg.app.enableSmartOverride; }
    // optionalAttrs (resolvedSilentStart != null) { silentStart = resolvedSilentStart; }
    // optionalAttrs (cfg.app.appTheme != null) { appTheme = cfg.app.appTheme; }
    // optionalAttrs (cfg.app.useWindowFrame != null) { useWindowFrame = cfg.app.useWindowFrame; }
    // optionalAttrs (cfg.app.proxyInTray != null) { proxyInTray = cfg.app.proxyInTray; }
    // optionalAttrs (cfg.app.showCurrentProxyInTray != null) {
      showCurrentProxyInTray = cfg.app.showCurrentProxyInTray;
    }
    // optionalAttrs (cfg.app.enableTrafficLogger != null) {
      enableTrafficLogger = cfg.app.enableTrafficLogger;
    }
    // optionalAttrs (cfg.app.trayProxyGroupStyle != null) {
      trayProxyGroupStyle = cfg.app.trayProxyGroupStyle;
    }
    // optionalAttrs (cfg.app.disableTrayIconColor != null) {
      disableTrayIconColor = cfg.app.disableTrayIconColor;
    }
    // optionalAttrs (cfg.app.customTrayIcon != null) { customTrayIcon = cfg.app.customTrayIcon; }
    // optionalAttrs (cfg.app.maxLogDays != null) { maxLogDays = cfg.app.maxLogDays; }
    // optionalAttrs (cfg.app.maxLogFileSize != null) { maxLogFileSize = cfg.app.maxLogFileSize; }
    // optionalAttrs (cfg.app.disableAppLog != null) { disableAppLog = cfg.app.disableAppLog; }
    // optionalAttrs (cfg.app.proxyCols != null) { proxyCols = cfg.app.proxyCols; }
    // optionalAttrs (cfg.app.connectionDirection != null) {
      connectionDirection = cfg.app.connectionDirection;
    }
    // optionalAttrs (cfg.app.connectionOrderBy != null) { connectionOrderBy = cfg.app.connectionOrderBy; }
    // optionalAttrs (cfg.app.useSubStore != null) { useSubStore = cfg.app.useSubStore; }
    // optionalAttrs (cfg.app.autoQuitWithoutCore != null) { autoQuitWithoutCore = cfg.app.autoQuitWithoutCore; }
    // optionalAttrs (cfg.app.autoQuitWithoutCoreDelay != null) {
      autoQuitWithoutCoreDelay = cfg.app.autoQuitWithoutCoreDelay;
    }
    // optionalAttrs (cfg.app.autoQuitWithoutCoreMode != null) {
      autoQuitWithoutCoreMode = cfg.app.autoQuitWithoutCoreMode;
    }
    // optionalAttrs (cfg.app.proxyDisplayMode != null) { proxyDisplayMode = cfg.app.proxyDisplayMode; }
    // optionalAttrs (cfg.app.proxyDisplayOrder != null) { proxyDisplayOrder = cfg.app.proxyDisplayOrder; }
    // optionalAttrs (cfg.app.autoCloseConnection != null) { autoCloseConnection = cfg.app.autoCloseConnection; }
    // optionalAttrs (resolvedAutoCheckUpdate != null) { autoCheckUpdate = resolvedAutoCheckUpdate; }
    // optionalAttrs (cfg.app.subscriptionTimeout != null) { subscriptionTimeout = cfg.app.subscriptionTimeout; }
    // optionalAttrs (resolvedControlDns != null) { controlDns = resolvedControlDns; }
    // optionalAttrs (resolvedControlSniff != null) { controlSniff = resolvedControlSniff; }
    // optionalAttrs (cfg.app.floatingWindowCompatMode != null) {
      floatingWindowCompatMode = cfg.app.floatingWindowCompatMode;
    }
    // optionalAttrs (cfg.app.disableHardwareAcceleration != null) {
      disableHardwareAcceleration = cfg.app.disableHardwareAcceleration;
    }
    // optionalAttrs (cfg.app.hideConnectionCardWave != null) {
      hideConnectionCardWave = cfg.app.hideConnectionCardWave;
    }
    // optionalAttrs (cfg.app.diffWorkDir != null) { diffWorkDir = cfg.app.diffWorkDir; }
    // optionalAttrs (cfg.app.useHotReloadProfile != null) { useHotReloadProfile = cfg.app.useHotReloadProfile; }
    // optionalAttrs (cfg.app.hotReloadProfileAutoCloseConnection != null) {
      hotReloadProfileAutoCloseConnection = cfg.app.hotReloadProfileAutoCloseConnection;
    }
    // optionalAttrs (cfg.app.pauseSSID != null) { pauseSSID = cfg.app.pauseSSID; }
    // optionalAttrs (cfg.app.disableDnsOnPauseSSID != null) {
      disableDnsOnPauseSSID = cfg.app.disableDnsOnPauseSSID;
    }
    // optionalAttrs (cfg.app.userAgent != null) { userAgent = cfg.app.userAgent; }
    // optionalAttrs (cfg.app.delayTestUrl != null) { delayTestUrl = cfg.app.delayTestUrl; }
    // optionalAttrs (cfg.app.delayTestConcurrency != null) {
      delayTestConcurrency = cfg.app.delayTestConcurrency;
    }
    // optionalAttrs (cfg.app.delayTestTimeout != null) { delayTestTimeout = cfg.app.delayTestTimeout; }
    // optionalAttrs (cfg.app.language != null) { language = cfg.app.language; }
    // optionalAttrs (cfg.app.disableTray != null) { disableTray = cfg.app.disableTray; }
    // optionalAttrs (cfg.app.siderOrder != null) { siderOrder = cfg.app.siderOrder; }
    // optionalAttrs (cfg.app.siderWidth != null) { siderWidth = cfg.app.siderWidth; }
    // optionalAttrs (cfg.app.triggerMainWindowBehavior != null) {
      triggerMainWindowBehavior = cfg.app.triggerMainWindowBehavior;
    }
    // optionalAttrs (cfg.app.testProfileOnStart != null) { testProfileOnStart = cfg.app.testProfileOnStart; }
    // optionalAttrs (cfg.app.useNameserverPolicy != null) { useNameserverPolicy = cfg.app.useNameserverPolicy; }
    // optionalAttrs (cfg.app.nameserverPolicy != null) { nameserverPolicy = cfg.app.nameserverPolicy; }
    // optionalAttrs (resolvedMixedDisplayPort != null) { showMixedPort = resolvedMixedDisplayPort; }
    // optionalAttrs (resolvedMixedPortEnabled != null) { enableMixedPort = resolvedMixedPortEnabled; }
    // optionalAttrs (resolvedSocksDisplayPort != null) { showSocksPort = resolvedSocksDisplayPort; }
    // optionalAttrs (resolvedSocksPortEnabled != null) { enableSocksPort = resolvedSocksPortEnabled; }
    // optionalAttrs (resolvedHttpDisplayPort != null) { showHttpPort = resolvedHttpDisplayPort; }
    // optionalAttrs (resolvedHttpPortEnabled != null) { enableHttpPort = resolvedHttpPortEnabled; }
    // optionalAttrs (resolvedSysProxyEnable != null || resolvedSysProxyMode != null) {
      sysProxy =
        optionalAttrs (resolvedSysProxyEnable != null) { enable = resolvedSysProxyEnable; }
        // optionalAttrs (resolvedSysProxyMode != null) { mode = resolvedSysProxyMode; };
    };

  mihomoTypedPatch =
    optionalAttrs (cfg.mihomo.mode != null) { mode = cfg.mihomo.mode; }
    // optionalAttrs (resolvedMixedPort != null) { "mixed-port" = resolvedMixedPort; }
    // optionalAttrs (resolvedSocksPort != null) { "socks-port" = resolvedSocksPort; }
    // optionalAttrs (resolvedHttpPort != null) { port = resolvedHttpPort; }
    // optionalAttrs (resolvedRedirPort != null) { "redir-port" = resolvedRedirPort; }
    // optionalAttrs (resolvedTproxyPort != null) { "tproxy-port" = resolvedTproxyPort; }
    // optionalAttrs (cfg.mihomo.allowLan != null) { "allow-lan" = cfg.mihomo.allowLan; }
    // optionalAttrs (cfg.mihomo.bindAddress != null) { "bind-address" = cfg.mihomo.bindAddress; }
    // optionalAttrs (cfg.mihomo.logLevel != null) { "log-level" = cfg.mihomo.logLevel; }
    // optionalAttrs (cfg.mihomo.unifiedDelay != null) { "unified-delay" = cfg.mihomo.unifiedDelay; }
    // optionalAttrs (resolvedTcpConcurrent != null) { "tcp-concurrent" = resolvedTcpConcurrent; }
    // optionalAttrs (cfg.mihomo.ipv6 != null) { ipv6 = cfg.mihomo.ipv6; }
    // optionalAttrs (cfg.mihomo.findProcessMode != null) {
      "find-process-mode" = cfg.mihomo.findProcessMode;
    }
    // optionalAttrs (cfg.mihomo.lanAllowedIps != null) {
      "lan-allowed-ips" = cfg.mihomo.lanAllowedIps;
    }
    // optionalAttrs (cfg.mihomo.lanDisallowedIps != null) {
      "lan-disallowed-ips" = cfg.mihomo.lanDisallowedIps;
    }
    // optionalAttrs (cfg.mihomo.authentication != null) { authentication = cfg.mihomo.authentication; }
    // optionalAttrs (cfg.mihomo.skipAuthPrefixes != null) {
      "skip-auth-prefixes" = cfg.mihomo.skipAuthPrefixes;
    }
    // optionalAttrs (cfg.mihomo.geoAutoUpdate != null) { "geo-auto-update" = cfg.mihomo.geoAutoUpdate; }
    // optionalAttrs (cfg.mihomo.geoUpdateInterval != null) {
      "geo-update-interval" = cfg.mihomo.geoUpdateInterval;
    }
    // optionalAttrs (cfg.mihomo.geodataMode != null) { "geodata-mode" = cfg.mihomo.geodataMode; }
    // optionalAttrs (cfg.mihomo.geoxUrl != null) { "geox-url" = cfg.mihomo.geoxUrl; }
    // optionalAttrs (hasValues cfg.mihomo.profile) {
      profile =
        optionalAttrs (cfg.mihomo.profile.storeSelected != null) {
          "store-selected" = cfg.mihomo.profile.storeSelected;
        }
        // optionalAttrs (cfg.mihomo.profile.storeFakeIp != null) {
          "store-fake-ip" = cfg.mihomo.profile.storeFakeIp;
        };
    }
    // optionalAttrs (hasValues cfg.mihomo.tun) {
      tun =
        optionalAttrs (resolvedTunEnable != null) { enable = resolvedTunEnable; }
        // optionalAttrs (cfg.mihomo.tun.stack != null) { stack = cfg.mihomo.tun.stack; }
        // optionalAttrs (cfg.mihomo.tun.autoRoute != null) { "auto-route" = cfg.mihomo.tun.autoRoute; }
        // optionalAttrs (cfg.mihomo.tun.autoRedirect != null) {
          "auto-redirect" = cfg.mihomo.tun.autoRedirect;
        }
        // optionalAttrs (cfg.mihomo.tun.autoDetectInterface != null) {
          "auto-detect-interface" = cfg.mihomo.tun.autoDetectInterface;
        }
        // optionalAttrs (cfg.mihomo.tun.dnsHijack != null) { "dns-hijack" = cfg.mihomo.tun.dnsHijack; }
        // optionalAttrs (cfg.mihomo.tun.routeExcludeAddress != null) {
          "route-exclude-address" = cfg.mihomo.tun.routeExcludeAddress;
        }
        // optionalAttrs (cfg.mihomo.tun.mtu != null) { mtu = cfg.mihomo.tun.mtu; }
        // optionalAttrs (cfg.mihomo.tun.device != null) { device = cfg.mihomo.tun.device; }
        // optionalAttrs (cfg.mihomo.tun.strictRoute != null) { "strict-route" = cfg.mihomo.tun.strictRoute; };
    }
    // optionalAttrs (hasValues cfg.mihomo.dns || hasValues cfg.mihomo.dns.fallbackFilter) {
      dns =
        optionalAttrs (cfg.mihomo.dns.enable != null) { enable = cfg.mihomo.dns.enable; }
        // optionalAttrs (cfg.mihomo.dns.ipv6 != null) { ipv6 = cfg.mihomo.dns.ipv6; }
        // optionalAttrs (resolvedRuntimeDnsListen != null) { listen = resolvedRuntimeDnsListen; }
        // optionalAttrs (cfg.mihomo.dns.enhancedMode != null) {
          "enhanced-mode" = cfg.mihomo.dns.enhancedMode;
        }
        // optionalAttrs (cfg.mihomo.dns.fakeIpRange != null) {
          "fake-ip-range" = cfg.mihomo.dns.fakeIpRange;
        }
        // optionalAttrs (cfg.mihomo.dns.fakeIpFilter != null) {
          "fake-ip-filter" = cfg.mihomo.dns.fakeIpFilter;
        }
        // optionalAttrs (cfg.mihomo.dns.useHosts != null) { "use-hosts" = cfg.mihomo.dns.useHosts; }
        // optionalAttrs (cfg.mihomo.dns.useSystemHosts != null) {
          "use-system-hosts" = cfg.mihomo.dns.useSystemHosts;
        }
        // optionalAttrs (cfg.mihomo.dns.respectRules != null) {
          "respect-rules" = cfg.mihomo.dns.respectRules;
        }
        // optionalAttrs (cfg.mihomo.dns.defaultNameserver != null) {
          "default-nameserver" = cfg.mihomo.dns.defaultNameserver;
        }
        // optionalAttrs (cfg.mihomo.dns.nameserver != null) { nameserver = cfg.mihomo.dns.nameserver; }
        // optionalAttrs (cfg.mihomo.dns.proxyServerNameserver != null) {
          "proxy-server-nameserver" = cfg.mihomo.dns.proxyServerNameserver;
        }
        // optionalAttrs (cfg.mihomo.dns.directNameserver != null) {
          "direct-nameserver" = cfg.mihomo.dns.directNameserver;
        }
        // optionalAttrs (cfg.mihomo.dns.fallback != null) { fallback = cfg.mihomo.dns.fallback; }
        // optionalAttrs (resolvedFakeIpFilterMode != null) {
          "fake-ip-filter-mode" = resolvedFakeIpFilterMode;
        }
        // optionalAttrs (hasValues cfg.mihomo.dns.fallbackFilter) {
          "fallback-filter" =
            optionalAttrs (cfg.mihomo.dns.fallbackFilter.geoip != null) {
              geoip = cfg.mihomo.dns.fallbackFilter.geoip;
            }
            // optionalAttrs (cfg.mihomo.dns.fallbackFilter.geoipCode != null) {
              "geoip-code" = cfg.mihomo.dns.fallbackFilter.geoipCode;
            }
            // optionalAttrs (cfg.mihomo.dns.fallbackFilter.ipcidr != null) {
              ipcidr = cfg.mihomo.dns.fallbackFilter.ipcidr;
            }
            // optionalAttrs (cfg.mihomo.dns.fallbackFilter.domain != null) {
              domain = cfg.mihomo.dns.fallbackFilter.domain;
            };
        };
    }
    // optionalAttrs (hasValues cfg.mihomo.sniffer) {
      sniffer =
        optionalAttrs (cfg.mihomo.sniffer.enable != null) { enable = cfg.mihomo.sniffer.enable; }
        // optionalAttrs (cfg.mihomo.sniffer.parsePureIp != null) {
          "parse-pure-ip" = cfg.mihomo.sniffer.parsePureIp;
        }
        // optionalAttrs (cfg.mihomo.sniffer.forceDnsMapping != null) {
          "force-dns-mapping" = cfg.mihomo.sniffer.forceDnsMapping;
        }
        // optionalAttrs (cfg.mihomo.sniffer.overrideDestination != null) {
          "override-destination" = cfg.mihomo.sniffer.overrideDestination;
        }
        // optionalAttrs (cfg.mihomo.sniffer.skipDomain != null) {
          "skip-domain" = cfg.mihomo.sniffer.skipDomain;
        }
        // optionalAttrs (cfg.mihomo.sniffer.skipDstAddress != null) {
          "skip-dst-address" = cfg.mihomo.sniffer.skipDstAddress;
        }
        // optionalAttrs (
          cfg.mihomo.sniffer.httpPorts != null
          || cfg.mihomo.sniffer.httpOverrideDestination != null
          || cfg.mihomo.sniffer.tlsPorts != null
        ) {
          sniff =
            optionalAttrs (
              cfg.mihomo.sniffer.httpPorts != null
              || cfg.mihomo.sniffer.httpOverrideDestination != null
            ) {
              HTTP =
                optionalAttrs (cfg.mihomo.sniffer.httpPorts != null) { ports = cfg.mihomo.sniffer.httpPorts; }
                // optionalAttrs (cfg.mihomo.sniffer.httpOverrideDestination != null) {
                  "override-destination" = cfg.mihomo.sniffer.httpOverrideDestination;
                };
            }
            // optionalAttrs (cfg.mihomo.sniffer.tlsPorts != null) {
              TLS = { ports = cfg.mihomo.sniffer.tlsPorts; };
            };
        };
    };

  appConfig = recursiveUpdate appTypedPatch (if cfg.appConfigPatch == null then { } else cfg.appConfigPatch);
  mihomoConfig =
    recursiveUpdate mihomoTypedPatch (if cfg.mihomoConfigPatch == null then { } else cfg.mihomoConfigPatch);

  managed = appConfig != { } || mihomoConfig != { };

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
      default = "mihomo-party";
      description = "Linux user data directory name under XDG config home used by Clash Party.";
    };

    links = {
      mixedPort = mkOption {
        type = nullType types.port;
        default = null;
        description = "Externally linked mixed proxy port.";
      };

      dnsListen = mkOption {
        type = nullType types.str;
        default = null;
        description = "Externally linked Mihomo DNS listen address.";
      };

      systemProxy = {
        enable = mkOption {
          type = nullType types.bool;
          default = null;
          description = "Externally linked system proxy enable flag.";
        };

        mode = mkOption {
          type = nullType types.str;
          default = null;
          description = "Externally linked system proxy mode.";
        };
      };
    };

    app = {
      core = nullOr (types.enum [ "mihomo" "mihomo-alpha" "mihomo-smart" ]);
      enableSmartCore = nullOr types.bool;
      enableSmartOverride = nullOr types.bool;
      silentStart = nullOr types.bool;
      appTheme = nullOr (types.enum [ "system" "dark" "light" ]);
      useWindowFrame = nullOr types.bool;
      proxyInTray = nullOr types.bool;
      showCurrentProxyInTray = nullOr types.bool;
      enableTrafficLogger = nullOr types.bool;
      trayProxyGroupStyle = nullOr types.str;
      disableTrayIconColor = nullOr types.bool;
      customTrayIcon = nullOr types.str;
      maxLogDays = nullOr types.int;
      maxLogFileSize = nullOr types.int;
      disableAppLog = nullOr types.bool;
      proxyCols = nullOr types.str;
      connectionDirection = nullOr (types.enum [ "asc" "desc" ]);
      connectionOrderBy = nullOr types.str;
      useSubStore = nullOr types.bool;
      autoQuitWithoutCore = nullOr types.bool;
      autoQuitWithoutCoreDelay = nullOr types.int;
      autoQuitWithoutCoreMode = nullOr types.str;
      proxyDisplayMode = nullOr types.str;
      proxyDisplayOrder = nullOr types.str;
      autoCloseConnection = nullOr types.bool;
      autoCheckUpdate = nullOr types.bool;
      subscriptionTimeout = nullOr types.int;
      controlDns = nullOr types.bool;
      controlSniff = nullOr types.bool;
      floatingWindowCompatMode = nullOr types.bool;
      disableHardwareAcceleration = nullOr types.bool;
      hideConnectionCardWave = nullOr types.bool;
      diffWorkDir = nullOr types.bool;
      useHotReloadProfile = nullOr types.bool;
      hotReloadProfileAutoCloseConnection = nullOr types.bool;
      pauseSSID = nullOr (types.listOf types.str);
      disableDnsOnPauseSSID = nullOr types.bool;
      userAgent = nullOr types.str;
      delayTestUrl = nullOr types.str;
      delayTestConcurrency = nullOr types.int;
      delayTestTimeout = nullOr types.int;
      language = nullOr (types.enum [ "zh-CN" "zh-TW" "en-US" "ru-RU" "fa-IR" ]);
      disableTray = nullOr types.bool;
      siderOrder = nullOr (types.listOf types.str);
      siderWidth = nullOr types.int;
      triggerMainWindowBehavior = nullOr types.str;
      testProfileOnStart = nullOr types.bool;
      useNameserverPolicy = nullOr types.bool;
      nameserverPolicy = nullOr (types.attrsOf types.anything);
      showMixedPort = nullOr types.port;
      enableMixedPort = nullOr types.bool;
      showSocksPort = nullOr types.port;
      enableSocksPort = nullOr types.bool;
      showHttpPort = nullOr types.port;
      enableHttpPort = nullOr types.bool;
      sysProxyEnable = nullOr types.bool;
      sysProxyMode = nullOr types.str;
    };

    startup = {
      silent = nullOr types.bool;
      autoCheckUpdate = nullOr types.bool;
    };

    features = {
      controlDns = nullOr types.bool;
      controlSniff = nullOr types.bool;
      tcpConcurrent = nullOr types.bool;

      tun.enable = nullOr types.bool;
    };

    ports = {
      mixed = {
        port = nullOr types.port;
        displayPort = nullOr types.port;
        enable = nullOr types.bool;
      };
      socks = {
        port = nullOr types.port;
        displayPort = nullOr types.port;
        enable = nullOr types.bool;
      };
      http = {
        port = nullOr types.port;
        displayPort = nullOr types.port;
        enable = nullOr types.bool;
      };
      redir = nullOr types.port;
      tproxy = nullOr types.port;
    };

    systemProxy = {
      enable = nullOr types.bool;
      mode = nullOr types.str;
    };

    dns = {
      runtimeListen = nullOr types.str;
      fakeIpFilterMode = nullOr (types.enum [ "blacklist" "whitelist" ]);
    };

    mihomo = {
      mode = nullOr (types.enum [ "rule" "global" "direct" ]);
      mixedPort = nullOr types.port;
      socksPort = nullOr types.port;
      httpPort = nullOr types.port;
      redirPort = nullOr types.port;
      tproxyPort = nullOr types.port;
      allowLan = nullOr types.bool;
      bindAddress = nullOr types.str;
      logLevel = nullOr (types.enum [ "debug" "info" "warning" "error" "silent" ]);
      unifiedDelay = nullOr types.bool;
      tcpConcurrent = nullOr types.bool;
      ipv6 = nullOr types.bool;
      findProcessMode = nullOr (types.enum [ "strict" "off" "always" ]);
      lanAllowedIps = nullOr (types.listOf types.str);
      lanDisallowedIps = nullOr (types.listOf types.str);
      authentication = nullOr (types.listOf types.str);
      skipAuthPrefixes = nullOr (types.listOf types.str);
      geoAutoUpdate = nullOr types.bool;
      geoUpdateInterval = nullOr types.int;
      geodataMode = nullOr types.bool;
      geoxUrl = nullOr (types.attrsOf types.str);

      profile = {
        storeSelected = nullOr types.bool;
        storeFakeIp = nullOr types.bool;
      };

      tun = {
        enable = nullOr types.bool;
        stack = nullOr (types.enum [ "system" "gvisor" "mixed" ]);
        autoRoute = nullOr types.bool;
        autoRedirect = nullOr types.bool;
        autoDetectInterface = nullOr types.bool;
        dnsHijack = nullOr (types.listOf types.str);
        routeExcludeAddress = nullOr (types.listOf types.str);
        mtu = nullOr types.int;
        device = nullOr types.str;
        strictRoute = nullOr types.bool;
      };

      dns = {
        enable = nullOr types.bool;
        ipv6 = nullOr types.bool;
        listen = nullOr types.str;
        enhancedMode = nullOr (types.enum [ "fake-ip" "redir-host" "normal" ]);
        fakeIpRange = nullOr types.str;
        fakeIpFilter = nullOr (types.listOf types.str);
        useHosts = nullOr types.bool;
        useSystemHosts = nullOr types.bool;
        respectRules = nullOr types.bool;
        defaultNameserver = nullOr (types.listOf types.str);
        nameserver = nullOr (types.listOf types.str);
        proxyServerNameserver = nullOr (types.listOf types.str);
        directNameserver = nullOr (types.listOf types.str);
        fallback = nullOr (types.listOf types.str);
        fakeIpFilterMode = nullOr (types.enum [ "blacklist" "whitelist" ]);

        fallbackFilter = {
          geoip = nullOr types.bool;
          geoipCode = nullOr types.str;
          ipcidr = nullOr (types.listOf types.str);
          domain = nullOr (types.listOf types.str);
        };
      };

      sniffer = {
        enable = nullOr types.bool;
        parsePureIp = nullOr types.bool;
        forceDnsMapping = nullOr types.bool;
        overrideDestination = nullOr types.bool;
        httpPorts = nullOr (types.listOf (types.oneOf [ types.int types.str ]));
        httpOverrideDestination = nullOr types.bool;
        tlsPorts = nullOr (types.listOf (types.oneOf [ types.int types.str ]));
        skipDomain = nullOr (types.listOf types.str);
        skipDstAddress = nullOr (types.listOf types.str);
      };
    };

    appConfigPatch = mkOption {
      type = types.nullOr (types.attrsOf types.anything);
      default = null;
      description = ''
        Escape hatch for raw Clash Party `config.yaml` fields not covered by typed options.
        Values here override generated typed settings on key conflict.
      '';
    };

    mihomoConfigPatch = mkOption {
      type = types.nullOr (types.attrsOf types.anything);
      default = null;
      description = ''
        Escape hatch for raw Clash Party `mihomo.yaml` fields not covered by typed options.
        Values here override generated typed settings on key conflict.
      '';
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      warnings =
        optional (appConfig ? githubToken)
          "programs.clash-party app/githubToken will be stored in the Nix store; prefer setting it in the UI."
        ++ optional (appConfig ? gistAgeSecretKey)
          "programs.clash-party app/gistAgeSecretKey will be stored in the Nix store; prefer setting it in the UI."
        ++ optional (appConfig ? lastSelectedSiderCard)
          "Clash Party lastSelectedSiderCard is UI state memory and should not be managed declaratively.";

      home.packages = optional (cfg.package != null) cfg.package;
    })

    (mkIf (cfg.enable && managed) {
      home.activation.clashPartyDeclarativeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${stateDir}"

        ${lib.optionalString (appConfig != { }) ''
          install -m 0644 "${appConfigFile}" "${stateDir}/config.yaml"
        ''}

        ${lib.optionalString (mihomoConfig != { }) ''
          install -m 0644 "${mihomoConfigFile}" "${stateDir}/mihomo.yaml"
        ''}
      '';
    })
  ];
}
