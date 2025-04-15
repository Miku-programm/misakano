#!/bin/bash

CONFIG_FILE="/etc/soga/soga.conf"
INSERT_LINE="submit_alive_ip_min_traffic=300"

# 1. 检测是否存在配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件 $CONFIG_FILE 不存在，脚本退出。"
    exit 1
fi

# 2. 插入指定行到文件末尾
echo "$INSERT_LINE" >> "$CONFIG_FILE"
echo "已将配置插入到 $CONFIG_FILE 末尾。"

# 3. 重启 soga 服务
if command -v systemctl &> /dev/null; then
    systemctl restart soga
else
    soga restart
fi

echo "soga 服务已重启。"
