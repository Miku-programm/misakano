#!/bin/bash

CONFIG_FILE="/etc/XrayR/config.yml"

# 检查配置文件是否存在且不为空
if [ -s "$CONFIG_FILE" ]; then
    echo "配置文件存在，继续操作。"
else
    echo "配置文件不存在或为空，操作终止。"
    exit 1
fi

# 请求输入NodeID
echo -n "请输入NodeID的值: "
read node_id

# 检查文件最后是否有换行符，没有则添加
if [ "$(tail -c1 "$CONFIG_FILE" | wc -l)" -eq "0" ]; then
    echo "" >> "$CONFIG_FILE"
fi

# 向配置文件末尾追加新的配置
echo "正在向文件末尾追加配置..."
cat << EOF >> "$CONFIG_FILE"
  -
    PanelType: "NewV2board"
    ApiConfig:
      DisableCustomConfig: true
      ApiHost: "https://21e2bb13660e0d66e053012819acfd9d.xunxingjiasuqi.top"
      ApiKey: "703eff19-26d3-45e2-9834-bbcd5f3cdb2b"
      NodeID: $node_id
      NodeType: Shadowsocks
      Timeout: 30
      EnableVless: false
      EnableXTLS: false
      SpeedLimit: 0
      DeviceLimit: 0
      RuleListPath: 
    ControllerConfig:
      ListenIP: 0.0.0.0
      SendIP: 0.0.0.0
      UpdatePeriodic: 60
      EnableDNS: false
      DNSType: AsIs
      DisableUploadTraffic: false
      DisableGetRule: false
      DisableIVCheck: false
      DisableSniffing: false
      EnableProxyProtocol: false
      EnableFallback: false
      FallBackConfigs:
        -
          SNI: 
          Path: 
          Dest: 80
          ProxyProtocolVer: 0
      CertConfig:
        CertMode: http
        CertDomain: "tw2.riemunode.tk"
        CertFile: /etc/XrayR/cer/tw2.riemunode.ga.cer
        KeyFile: /etc/XrayR/cer/tw2.riemunode.ga.key
        Provider: cloudflare
        Email: dns@oracleusa.com
        DNSEnv:
          A: aaa
EOF

echo "配置已成功追加。"

# 重启XrayR服务
echo "正在重启XrayR服务..."
xrayr restart

echo "操作完成。"
