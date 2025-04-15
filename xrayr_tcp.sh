#!/bin/bash

# 配置文件路径
CONFIG_FILE="/etc/XrayR/config.yml"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在"
    exit 1
fi

# 创建备份
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "已创建配置文件备份: $BACKUP_FILE"

# 计算初始出现次数
INITIAL_COUNT=$(grep -c "EnableProxyProtocol:" "$CONFIG_FILE")
echo "在配置文件中发现 $INITIAL_COUNT 处 EnableProxyProtocol 设置"

# 使用 sed 替换所有 EnableProxyProtocol 的值为 true
# 匹配各种格式: EnableProxyProtocol: false, EnableProxyProtocol:false, 以及可能有不同数量的空格
sed -i 's/EnableProxyProtocol[[:space:]]*:[[:space:]]*\(false\|False\|FALSE\)/EnableProxyProtocol: true/g' "$CONFIG_FILE"

# 检查替换后的结果
CHANGED_COUNT=$(grep -c "EnableProxyProtocol: true" "$CONFIG_FILE")
echo "已将 $CHANGED_COUNT 处 EnableProxyProtocol 设置更新为 true"

# 检查是否有遗漏的 EnableProxyProtocol 设置
REMAINING=$(grep "EnableProxyProtocol:" "$CONFIG_FILE" | grep -v "EnableProxyProtocol: true")
if [ -n "$REMAINING" ]; then
    echo "警告: 以下 EnableProxyProtocol 设置未被修改:"
    echo "$REMAINING"
    echo "这可能是由于格式不标准或其他原因。请手动检查。"
else
    echo "成功: 所有 EnableProxyProtocol 设置已更新为 true"
fi

echo "配置文件更新完成"
