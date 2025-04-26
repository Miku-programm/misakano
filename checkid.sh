#!/bin/bash

# 提示用户输入节点ID
read -p "请输入节点ID: " input_id

# 检查 /etc/XrayR/config.yml 中的 node_id
xrayr_result="❌ 未匹配"
if [ -f /etc/XrayR/config.yml ]; then
    # 提取 node_id 的值
    xrayr_node_id=$(grep -oP 'node_id:\s*\K.*' /etc/XrayR/config.yml | tr -d '[:space:]')
    
    # 处理复杂 node_id（如 109,219）
    if [[ $xrayr_node_id =~ (^|,)$input_id(,|$) ]]; then
        xrayr_result="匹配成功 ✅ 节点ID: $input_id"
    fi
fi

# 检查 /etc/soga/soga.conf 中的 node_id
soga_result="❌ 未匹配"
if [ -f /etc/soga/soga.conf ]; then
    # 提取 node_id 的值
    soga_node_id=$(grep -oP '^node_id=\K.*' /etc/soga/soga.conf | tr -d '[:space:]')
    
    # 处理复杂 node_id（如 109,219）
    if [[ $soga_node_id =~ (^|,)$input_id(,|$) ]]; then
        soga_result="匹配成功 ✅ 节点ID: $input_id"
    fi
fi

# 输出结果，XrayR 在前，soga 在后，分两行显示
echo "XrayR--$xrayr_result"
echo "soga--$soga_result"