{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "type": "udp",
        "tag": "dns_bootstrap",
        "server": "223.5.5.5"
      },
      {
        "type": "https",
        "tag": "dns_direct",
        "server": "223.5.5.5",
        "path": "/dns-query"
      },
      {
        "type": "https",
        "tag": "dns_proxy",
        "server": "1.1.1.1",
        "path": "/dns-query",
        "detour": "节点选择"
      }
    ],
    "rules": [
      {
        "clash_mode": "direct",
        "action": "route",
        "server": "dns_direct"
      },
      {
        "clash_mode": "global",
        "action": "route",
        "server": "dns_proxy"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "action": "reject"
      },
      {
        "rule_set": "geosite-cn",
        "action": "route",
        "server": "dns_direct"
      }
    ],
    "final": "dns_proxy",
    "strategy": "prefer_ipv4"
  },
  "http_clients": [
    {
      "tag": "direct-http",
      "detour": "direct"
    }
  ],
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": ["172.19.0.1/30", "fdfe:dcba:9876::1/126"],
      "auto_route": true,
      "strict_route": true
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "127.0.0.1",
      "listen_port": 7890
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "节点选择",
      "outbounds": ["自动选择", "快速线路", "回落线路"],
      "default": "自动选择"
    },
    {
      "type": "urltest",
      "tag": "自动选择",
      "outbounds": ["快速线路", "回落线路"],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "3m",
      "tolerance": 100
    },
    {
      "type": "hysteria2",
      "tag": "快速线路",
      "server": "lax.nea.kdns.fr",
      "server_port": 36467,
      "password": "e204d0cc-6ad4-4eba-b72e-c0af1ff5e3a1",
      "tls": {
        "enabled": true,
        "server_name": "lax.nea.kdns.fr",
        "insecure": true
      },
      "domain_resolver": "dns_bootstrap"
    },
    {
      "type": "vless",
      "tag": "回落线路",
      "server": "lax.nea.kdns.fr",
      "server_port": 443,
      "uuid": "b79b2fbf-a99c-4330-8269-cec35da5839d",
      "flow": "xtls-rprx-vision",
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "server_name": "dash.cloudflare.com",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": true,
          "public_key": "T8dALm81Gl7HZUqUfIoK5D0NERTHwQEDqlCGhBzVqUM",
          "short_id": ""
        }
      },
      "domain_resolver": "dns_bootstrap"
    },
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "rules": [
      {
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "clash_mode": "direct",
        "action": "route",
        "outbound": "direct"
      },
      {
        "clash_mode": "global",
        "action": "route",
        "outbound": "节点选择"
      },
      {
        "ip_is_private": true,
        "action": "route",
        "outbound": "direct"
      },
      {
        "protocol": "quic",
        "action": "reject"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "action": "reject"
      },
      {
        "rule_set": ["geosite-cn", "geoip-cn"],
        "action": "route",
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/cn.srs",
        "http_client": "direct-http",
        "update_interval": "3d"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs",
        "http_client": "direct-http",
        "update_interval": "3d"
      },
      {
        "type": "remote",
        "tag": "geosite-category-ads-all",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-ads-all.srs",
        "http_client": "direct-http",
        "update_interval": "3d"
      }
    ],
    "final": "节点选择",
    "auto_detect_interface": true,
    "default_domain_resolver": "dns_direct",
    "default_http_client": "direct-http"
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "store_dns": true
    },
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "default_mode": "rule"
    }
  }
}
