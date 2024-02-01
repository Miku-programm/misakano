#!/bin/bash

CONFIG_FILE="/etc/XrayR/config.yml"

# 检查配置文件是否存在且非空
if [ -s "$CONFIG_FILE" ]; then
    echo "配置文件存在，继续操作。"
else
    echo "配置文件不存在或为空，操作终止。"
    exit 1
fi

# 询问NodeID
echo -n "请输入NodeID的值: "
read node_id

# 插入配置到文件末尾
echo "在文件末尾插入配置..."
cat << EOF >> $CONFIG_FILE
  -
    PanelType: "NewV2board" # Panel type: SSpanel, V2board, PMpanel, Proxypanel
    ApiConfig:
      DisableCustomConfig: true
      ApiHost: "https://21e2bb13660e0d66e053012819acfd9d.xunxingjiasuqi.top"
      ApiKey: "703eff19-26d3-45e2-9834-bbcd5f3cdb2b"
      NodeID: $node_id
      NodeType: Shadowsocks # Node type: V2ray, Trojan, Shadowsocks, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/XrayR/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable Upload Traffic to the panel
      DisableGetRule: false # Disable Get Rule from the panel
      DisableIVCheck: false # Disable the anti-reply protection for Shadowsocks
      DisableSniffing: false # Disable domain sniffing 
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: http # Option about how to get certificate: none, file, http, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "tw2.riemunode.tk" # Domain to cert
        CertFile: /etc/XrayR/cer/tw2.riemunode.ga.cer # Provided if the CertMode is file
        KeyFile: /etc/XrayR/cer/tw2.riemunode.ga.key
        Provider: cloudflare # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: dns@oracleusa.com
        DNSEnv: # DNS ENV option used by DNS provider
          A: aaa
EOF

echo "配置已成功插入。"

# 重启XrayR服务
echo "重启XrayR服务..."
xrayr restart

echo "操作完成。"
