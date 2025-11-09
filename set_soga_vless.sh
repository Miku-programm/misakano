#!/bin/bash
CONF="/etc/soga/soga.conf"

# 1. 检查配置文件
if [ ! -f "$CONF" ]; then
  echo "未找到文件 $CONF"
  exit 1
fi

# 2. 输入 node_id
read -rp "请输入新的 node_id: " NODE_ID
if [ -z "$NODE_ID" ]; then
  echo "node_id 不能为空"
  exit 1
fi

# 3. 设置 server_type=vless
if grep -q '^server_type=' "$CONF"; then
  sed -i 's/^server_type=.*/server_type=vless/' "$CONF"
else
  echo "server_type=vless" >> "$CONF"
fi

# 4. 设置 node_id
if grep -q '^node_id=' "$CONF"; then
  sed -i "s/^node_id=.*/node_id=${NODE_ID}/" "$CONF"
else
  echo "node_id=${NODE_ID}" >> "$CONF"
fi

# 5. 重启 soga
if command -v soga >/dev/null 2>&1; then
  soga restart
  echo "已更新配置并执行 soga restart"
else
  echo "更新完成，但未找到 soga 命令，请手动重启"
fi