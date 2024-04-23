# DNS 配置可自行修改
port: 7890
allow-lan: true
mode: rule
log-level: info
unified-delay: true
global-client-fingerprint: chrome
dns:
  enable: true
  listen: :53
  ipv6: false
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  default-nameserver: 
    - 223.5.5.5
    - 168.95.1.1
    - 8.8.8.8
  nameserver:
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
  fallback:
    - https://1.0.0.1/dns-query
    - tls://dns.google
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4

# 当前 13 个主流协议节点配置模版，按需求修改，如不需要使用某协议节点，则无需删除，确保代理分流中没有该节点即可
proxies:
- name: hysteria                                  # 节点名称
  type: hysteria2
  server: 66.103.196.9                          # 服务器 IP
  port: 50224                                      # 节点端口，如使用端口跳跃则改为 ports: 2000-3000/1000
  password: 84afe70e                               # 节点认证密码
  sni: www.bing.com                                # SNI 域名或自签证书的三方域名
  skip-cert-verify: true                           # 使用自签证书请保持此处为 true，如为 CA 证书建议修改为 false

- name: hysteria2                                  # 节点名称
  type: hysteria2
  server: 142.171.85.110                           # 服务器 IP
  port: 58951                                      # 节点端口，如使用端口跳跃则改为 ports: 2000-3000/1000
  password: 9819d1d5                               # 节点认证密码
  sni: www.bing.com                                # SNI 域名或自签证书的三方域名
  skip-cert-verify: true                           # 使用自签证书请保持此处为 true，如为 CA 证书建议修改为 false

# 分流组可自行创建或添加，proxies 参数下的节点名称，按需求自行增减，确保出现的节点名称在代理协议中可查找
proxy-groups:
- name: 负载均衡
  type: load-balance
  url: http://www.gstatic.com/generate_204
  interval: 300
  proxies:
    - hysteria
    - hysteria2

- name: 自动选择
  type: url-test
  url: http://www.gstatic.com/generate_204
  interval: 300
  tolerance: 50
  proxies:
    - hysteria
    - hysteria2
    
- name: 🌍选择代理
  type: select
  proxies:
    - 负载均衡                                            # 自定义添加的节点名称
    - 自动选择
    - DIRECT
    - hysteria
    - hysteria2

# 代理规则可自行添加 
rules:
  - GEOIP,CN,DIRECT
  - MATCH,🌍选择代理
