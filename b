{
  "dns": {
    "final": "dns-proxy",
    "rules": [
      {
        "rule_set": "geosite-cn",
        "server": "dns-direct"
      }
    ],
    "servers": [
      {
        "type": "udp",
        "tag": "dns-direct",
        "server": "223.5.5.5"
      },
      {
        "type": "https",
        "tag": "dns-proxy",
        "server": "dns.google",
        "server_port": 443,
        "path": "/dns-query",
        "detour": "proxy"
      }
    ],
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "address": [
        "172.19.0.1/30"
      ],
      "auto_route": true,
      "strict_route": true,
      "tag": "tun-in",
      "type": "tun"
    },
    {
      "listen": "127.0.0.1",
      "listen_port": 1080,
      "tag": "mixed-in",
      "type": "mixed"
    }
  ],
  "log": {
    "level": "info",
    "timestamp": true
  },
  "outbounds": [
    {
      "default": "直连线路",
      "outbounds": [
        "直连线路",
        "备用线路"
      ],
      "tag": "proxy",
      "type": "selector"
    },
    {
      "password": "5eb056cd-9d14-4942-b244-b8d3e4192d19",
      "server": "speedtest.xlat.kdns.fr",
      "server_port": 40123,
      "tag": "直连线路",
      "tls": {
        "enabled": true,
        "insecure": true
      },
      "type": "hysteria2",
      "server_ports": [
        "45000:46999"
      ]
    },
    {
      "method": "aes-256-gcm",
      "password": "6fb74183cc50974ebe9a3e95",
      "server": "speedtest-tc.xlat.kdns.fr",
      "server_port": 9773,
      "tag": "备用线路",
      "type": "shadowsocks"
    },
    {
      "tag": "direct",
      "type": "direct"
    },
    {
      "tag": "block",
      "type": "block"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "proxy",
    "rule_set": [
      {
        "download_detour": "direct",
        "format": "binary",
        "tag": "futu",
        "type": "remote",
        "url": "http://49.234.200.146:65111/futu.srs"
      },
      {
        "download_detour": "proxy",
        "format": "binary",
        "tag": "geosite-cn",
        "type": "remote",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs"
      },
      {
        "download_detour": "proxy",
        "format": "binary",
        "tag": "geoip-cn",
        "type": "remote",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs"
      }
    ],
    "rules": [
      {
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "outbound": "proxy",
        "rule_set": "futu"
      },
      {
        "outbound": "direct",
        "rule_set": "geosite-cn"
      },
      {
        "outbound": "direct",
        "rule_set": "geoip-cn"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      }
    ],
    "default_domain_resolver": "dns-direct"
  }
}