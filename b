[
  {
    "tag": "优先线路",
    "type": "vless",
    "server": "usa.visa.com",
    "server_port": 443,
    "uuid": "b93f333f-6128-4b79-a344-9b6b16b3d2f2",
    "tls": {
      "enabled": true,
      "server_name": "usa.visa.com",
      "insecure": false
    },
    "transport": {
      "type": "ws",
      "headers": {
        "Host": "sfo.63372321.xyz"
      },
      "path": "/b93f333f-6128-4b79-a344-9b6b16b3d2f2"
    }
  },
  {
    "tag": "普通线路",
    "type": "vless",
    "server": "usa.visa.com",
    "server_port": 443,
    "uuid": "833817b0-a6ef-4ce6-b530-8ac222d1d87d",
    "tls": {
      "enabled": true,
      "server_name": "clear.mtvfawen.dpdns.org",
      "insecure": true
    },
    "transport": {
      "type": "ws",
      "headers": {
        "Host": "clear.mtvfawen.dpdns.org"
      },
      "path": "/",
      "early_data_header_name": "Sec-WebSocket-Protocol",
      "max_early_data": 2560
    }
  },
  {
    "tag": "备用线路",
    "type": "hysteria2",
    "server": "gbt10096.duckdns.org",
    "server_port": 36467,
    "password": "833817b0-a6ef-4ce6-b530-8ac222d1d87f",
    "tls": {
      "enabled": true,
      "server_name": "gbt10096.duckdns.org",
      "insecure": true
    }
  }
]
