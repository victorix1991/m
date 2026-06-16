{
  "log": {
    "disabled": false,
    "level": "info",
    "output": "",
    "timestamp": false
  },

  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:20123",
      "external_ui": "",
      "external_ui_download_url": "",
      "external_ui_download_detour": "🎯 全球直连",
      "secret": "158148f4162f628c3d4acbe885f2346183fbb6a4b350bea6d804d2e6349d1d38",
      "default_mode": "rule",
      "access_control_allow_origin": ["*"],
      "access_control_allow_private_network": false
    },

    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "cache_id": "ID_bb3jmc4w",
      "store_fakeip": true,
      "rdrc_timeout": "7d"
    }
  },

  "inbounds": [
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "127.0.0.1",
      "listen_port": 20122,
      "tcp_fast_open": false,
      "tcp_multi_path": false,
      "udp_fragment": false
    }
  ],

  "outbounds": [
    {
      "type": "selector",
      "tag": "🚀 节点选择",
      "interrupt_exist_connections": true,
      "outbounds": [
        "🎈 自动选择",
        "vless-main",
        "hysteria2-backup",
        "anytls-backup",
        "direct"
      ]
    },

    {
      "type": "urltest",
      "tag": "🎈 自动选择",
      "url": "https://www.gstatic.com/generate_204",
      "interval": "3m",
      "tolerance": 120,
      "interrupt_exist_connections": true,
      "outbounds": [
        "vless-main",
        "hysteria2-backup",
        "anytls-backup"
      ]
    },

    {
      "type": "vless",
      "tag": "vless-main",
      "server": "www.visa.cn",
      "server_port": 443,
      "uuid": "833817b0-a6ef-4ce6-b530-8ac222d1d87d",
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "server_name": "wispy-darkness-4e8e.xlatror.workers.dev",
        "alpn": ["h3"],
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
      "tag": "hysteria2-backup",
      "server": "sfo.63372321.xyz",
      "server_port": 36467,
      "password": "e204d0cc-6ad4-4eba-b72e-c0af1ff5e3a1",
      "tls": {
        "enabled": true,
        "insecure": true,
        "pin_sha256": "19FCCA50A5054A92E6785A023DCF5C32E8ECE62B50CBF1F78C3F8236209AA7F6"
      }
    },

    {
      "type": "anytls",
      "tag": "anytls-backup",
      "server": "sfo.63372321.xyz",
      "server_port": 443,
      "password": "1bb556c6-2e44-41be-89b8-719a7e3dd9b8",
      "tls": {
        "enabled": true,
        "insecure": true
      },
      "transport": {
        "type": "tcp",
        "header": {
          "type": "none"
        }
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
      "type": "selector",
      "tag": "🎯 全球直连",
      "interrupt_exist_connections": true,
      "outbounds": ["direct", "block"]
    },

    {
      "type": "selector",
      "tag": "🛑 全球拦截",
      "interrupt_exist_connections": true,
      "outbounds": ["block", "direct"]
    },

    {
      "type": "selector",
      "tag": "🐟 漏网之鱼",
      "interrupt_exist_connections": true,
      "outbounds": ["🚀 节点选择", "🎯 全球直连"]
    },

    {
      "type": "selector",
      "tag": "GLOBAL",
      "interrupt_exist_connections": true,
      "outbounds": [
        "🚀 节点选择",
        "🎈 自动选择",
        "🎯 全球直连",
        "🛑 全球拦截",
        "🐟 漏网之鱼"
      ]
    }
  ],

  "route": {
    "rules": [
      {
        "action": "hijack-dns",
        "protocol": "dns"
      },

      {
        "action": "route",
        "clash_mode": "direct",
        "outbound": "🎯 全球直连"
      },

      {
        "action": "route",
        "clash_mode": "global",
        "outbound": "GLOBAL"
      },

      {
        "action": "route",
        "network": "icmp",
        "outbound": "🎯 全球直连"
      },

      {
        "action": "route",
        "protocol": "quic",
        "outbound": "🛑 全球拦截"
      },

      {
        "action": "route",
        "rule_set": ["Category-Ads"],
        "outbound": "🛑 全球拦截"
      },

      {
        "action": "route",
        "rule_set": ["GeoSite-Private"],
        "outbound": "🎯 全球直连"
      },

      {
        "action": "route",
        "rule_set": ["GeoSite-CN"],
        "outbound": "🎯 全球直连"
      },

      {
        "action": "route",
        "rule_set": ["GeoIP-CN"],
        "outbound": "🎯 全球直连"
      },

      {
        "action": "route",
        "rule_set": ["GeoLocation-!CN"],
        "outbound": "🚀 节点选择"
      }
    ],

    "rule_set": [
      {
        "tag": "Category-Ads",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-ads-all.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      },
      {
        "tag": "GeoIP-Private",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/private.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      },
      {
        "tag": "GeoSite-Private",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/private.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      },
      {
        "tag": "GeoIP-CN",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      },
      {
        "tag": "GeoSite-CN",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/cn.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      },
      {
        "tag": "GeoLocation-!CN",
        "type": "remote",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-!cn.srs",
        "format": "binary",
        "download_detour": "🎯 全球直连"
      }
    ],

    "auto_detect_interface": true,
    "final": "🚀 节点选择",
    "default_domain_resolver": {
      "server": "Local-DNS"
    }
  },

  "dns": {
    "servers": [
      {
        "tag": "Fake-IP",
        "type": "fakeip",
        "inet4_range": "198.18.0.0/15",
        "inet6_range": "fc00::/18"
      },
      {
        "tag": "Local-DNS",
        "type": "https",
        "domain_resolver": "Local-DNS-Resolver",
        "server_port": 443,
        "server": "223.5.5.5",
        "path": "/dns-query"
      },
      {
        "tag": "Local-DNS-Resolver",
        "type": "udp",
        "server_port": 53,
        "server": "223.5.5.5"
      },
      {
        "tag": "Remote-DNS",
        "type": "tls",
        "detour": "🚀 节点选择",
        "domain_resolver": "Remote-DNS-Resolver",
        "server_port": 853,
        "server": "8.8.8.8"
      },
      {
        "tag": "Remote-DNS-Resolver",
        "type": "udp",
        "detour": "🚀 节点选择",
        "server_port": 53,
        "server": "8.8.8.8"
      }
    ],

    "rules": [
      {
        "action": "route",
        "clash_mode": "direct",
        "server": "Local-DNS"
      },
      {
        "action": "route",
        "clash_mode": "global",
        "server": "Remote-DNS"
      },
      {
        "action": "route",
        "rule_set": ["GeoSite-CN"],
        "server": "Local-DNS"
      },
      {
        "action": "route",
        "rule_set": ["GeoLocation-!CN"],
        "server": "Remote-DNS"
      }
    ],

    "disable_cache": false,
    "disable_expire": false,
    "independent_cache": false,
    "final": "Remote-DNS"
  }
}
