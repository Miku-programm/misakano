#!/bin/bash

# 1. 开启systemd-resolved服务
echo "步骤1: 开启systemd-resolved服务"
sudo systemctl enable systemd-resolved && sudo systemctl start systemd-resolved

# 2. 配置resolved.conf文件
echo "步骤2: 配置resolved.conf文件"
RESOLVED_CONF="/etc/systemd/resolved.conf"

# 检查文件是否存在，不存在则创建
if [ ! -f "$RESOLVED_CONF" ]; then
    echo "未找到resolved.conf文件，将创建新文件"
    sudo mkdir -p /etc/systemd/
    sudo touch "$RESOLVED_CONF"
fi

# 询问用户输入DNS内容
echo "请输入DNS内容替换值 (例如: dns-family):"
read dns_content

# 写入配置文件
echo "正在写入配置到$RESOLVED_CONF"
sudo tee "$RESOLVED_CONF" > /dev/null << EOF
[Resolve]
DNS=76.76.2.22#$dns_content.dns.controld.com
DNSOverTLS=yes
EOF

# 3. 创建符号链接
echo "步骤3: 创建符号链接"
if sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null; then
    echo "成功创建符号链接"
else
    echo "创建符号链接失败，可能文件已存在，尝试删除并重新创建"
    sudo rm -f /etc/resolv.conf
    sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    echo "符号链接已重新创建"
fi

# 4. 重启systemd-resolved服务
echo "步骤4: 重启systemd-resolved服务"
sudo systemctl restart systemd-resolved

echo "DNS配置已完成！"
