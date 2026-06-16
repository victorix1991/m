"outbounds": [
  {
    "type": "direct",
    "tag": "direct"
  },

  {
    "type": "vless",
    "tag": "proxy-vless",
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
    "tag": "proxy-hy2",
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
    "tag": "proxy-anytls",
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

  // ⭐ AUTO FAILOVER GROUP (BEST PRACTICE)
  {
    "type": "urltest",
    "tag": "auto",
    "outbounds": [
      "proxy-vless",
      "proxy-hy2",
      "proxy-anytls"
    ],
    "url": "https://cp.cloudflare.com/generate_204",
    "interval": "5m",
    "tolerance": 100
  },

  // ⭐ MANUAL SWITCHER
  {
    "type": "selector",
    "tag": "proxy",
    "outbounds": [
      "auto",
      "proxy-vless",
      "proxy-hy2",
      "proxy-anytls"
    ],
    "default": "auto"
  }
]
