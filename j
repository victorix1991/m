{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns_proxy",
        "address": "https://1.1.1.1/dns-query",
        "address_resolver": "dns_direct",
        "detour": "Proxy"
      },
      {
        "tag": "dns_direct",
        "address": "https://223.5.5.5/dns-query",
        "address_resolver": "dns_local",
        "detour": "direct"
      },
      {
        "tag": "dns_local",
        "address": "223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "dns_fakeip",
        "address": "fakeip"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns_direct"
      },
      {
        "geosite": ["cn"],
        "server": "dns_direct"
      },
      {
        "geosite": ["geolocation-!cn"],
        "server": "dns_fakeip"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/15",
      "inet6_range": "fc00::/18"
    },
    "independent_cache": true
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/30",
      "auto_route": true,
      "strict_route": true,
      "stack": "system",
      "sniff": true
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "127.0.0.1",
      "listen_port": 2080,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "Proxy",
      "outbounds": ["Auto", "优先线路", "备用线路", "协议测试"]
    },
    {
      "type": "urltest",
      "tag": "Auto",
      "outbounds": ["优先线路", "备用线路", "协议测试"],
      "url": "http://cp.cloudflare.com/",
      "interval": "3m",
      "tolerance": 50
    },
    {
      "type": "vless",
      "tag": "优先线路",
      "server": "www.visa.cn",
      "server_port": 443,
      "uuid": "833817b0-a6ef-4ce6-b530-8ac222d1d87d",
      "tls": {
        "enabled": true,
        "server_name": "wispy-darkness-4e8e.xlatror.workers.dev",
        "insecure": false,
        "alpn": ["h3", "h2", "http/1.1"],
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        }
      },
      "transport": {
        "type": "ws",
        "path": "/?ed=2048",
        "headers": {
          "Host": "wispy-darkness-4e8e.xlatror.workers.dev"
        }
      }
    },
    {
      "type": "hysteria2",
      "tag": "备用线路",
      "server": "sfo.63372321.xyz",
      "server_port": 36467,
      "password": "e204d0cc-6ad4-4eba-b72e-c0af1ff5e3a1",
      "tls": {
        "enabled": true,
        "insecure": true
      }
    },
    {
      "type": "vless",
      "tag": "协议测试",
      "server": "sfo.63372321.xyz",
      "server_port": 443,
      "uuid": "1bb556c6-2e44-41be-89b8-719a7e3dd9b8",
      "tls": {
        "enabled": true,
        "insecure": true
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "route": {
    "geoip": {
      "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
      "download_detour": "direct"
    },
    "geosite": {
      "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
      "download_detour": "direct"
    },
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "geosite": ["category-ads-all"],
        "outbound": "block"
      },
      {
        "geosite": ["cn"],
        "geoip": ["cn", "private"],
        "outbound": "direct"
      },
      {
        "geosite": ["geolocation-!cn"],
        "outbound": "Proxy"
      }
    ],
    "auto_detect_interface": true
  }
}
