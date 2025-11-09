#!/bin/bash
CONF="/etc/soga/soga.conf"
BACKUP="soga.txt"

# 1. 检查配置文件
if [ ! -f "$CONF" ]; then
  echo "未找到文件 $CONF"
  exit 1
fi

# 2. 检测原有配置并备份
echo "================================"
echo "检测到原有配置："
echo "================================"

# 检测原有 node_id
OLD_NODE_ID=$(grep '^node_id=' "$CONF" | cut -d'=' -f2)
if [ -n "$OLD_NODE_ID" ]; then
  echo "原有 node_id: $OLD_NODE_ID"
else
  echo "原有 node_id: (未设置)"
fi

# 检测原有 server_type
OLD_SERVER_TYPE=$(grep '^server_type=' "$CONF" | cut -d'=' -f2)
if [ -n "$OLD_SERVER_TYPE" ]; then
  echo "原有 server_type: $OLD_SERVER_TYPE"
else
  echo "原有 server_type: (未设置)"
fi

echo "================================"

# 3. 保存原有配置到 soga.txt
echo "正在备份原有配置到 $BACKUP ..."
cp "$CONF" "$BACKUP"
echo "原有配置已保存到: $(pwd)/$BACKUP"
echo ""

# 4. 输入新的 node_id
read -rp "请输入新的 node_id: " NODE_ID
if [ -z "$NODE_ID" ]; then
  echo "node_id 不能为空"
  exit 1
fi

# 5. 设置 server_type=vless
if grep -q '^server_type=' "$CONF"; then
  sed -i 's/^server_type=.*/server_type=vless/' "$CONF"
else
  echo "server_type=vless" >> "$CONF"
fi

# 6. 设置 node_id
if grep -q '^node_id=' "$CONF"; then
  sed -i "s/^node_id=.*/node_id=${NODE_ID}/" "$CONF"
else
  echo "node_id=${NODE_ID}" >> "$CONF"
fi

echo ""
echo "================================"
echo "配置更新完成："
echo "================================"
echo "server_type: vless"
echo "node_id: $NODE_ID"
echo "================================"
echo ""

# 7. 重启 soga
if command -v soga >/dev/null 2>&1; then
  soga restart
  echo "已执行 soga restart"
else
  echo "未找到 soga 命令，请手动重启"
fi
