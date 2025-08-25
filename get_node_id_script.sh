#!/bin/bash

# 检查 /etc/XrayR/config.yml 中的 node_id
xrayr_node_id=""
if [ -f /etc/XrayR/config.yml ]; then
    # 提取 node_id 的值
    xrayr_node_id=$(grep -oP 'node_id:\s*\K.*' /etc/XrayR/config.yml | tr -d '[:space:]')
fi

# 检查 /etc/soga/soga.conf 中的 node_id
soga_node_id=""
if [ -f /etc/soga/soga.conf ]; then
    # 提取 node_id 的值
    soga_node_id=$(grep -oP '^node_id=\K.*' /etc/soga/soga.conf | tr -d '[:space:]')
fi

# 输出结果
if [ -n "$xrayr_node_id" ]; then
    echo "XrayR 节点ID: $xrayr_node_id"
fi

if [ -n "$soga_node_id" ]; then
    echo "soga 节点ID: $soga_node_id"
fi

# 如果两个配置文件都没有找到节点ID
if [ -z "$xrayr_node_id" ] && [ -z "$soga_node_id" ]; then
    echo "未找到节点ID配置"
    exit 1
fi