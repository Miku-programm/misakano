#!/bin/bash

# Debian 12 IPv6启用脚本 - 基于Sakura VPS官方文档
# 此脚本自动化了IPv6启用的全部步骤

set -e

echo "=========================================="
echo "开始启用 Debian 12 IPv6"
echo "=========================================="

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "错误: 此脚本必须以root权限运行"
   exit 1
fi

# 步骤1: 检查当前IPv6配置
echo ""
echo "[步骤1] 检查当前IPv6配置..."
echo "当前 /etc/sysctl.d/ipv6.conf 内容:"
cat /etc/sysctl.d/ipv6.conf | grep -E "disable_ipv6|accept_ra" || true

# 步骤2: 修改内核参数 - 启用IPv6
echo ""
echo "[步骤2] 修改内核参数启用IPv6..."
sed -i -e "/net.ipv6.conf.all.disable_ipv6/s/1/0/" /etc/sysctl.d/ipv6.conf
sed -i -e "/net.ipv6.conf.default.disable_ipv6/s/1/0/" /etc/sysctl.d/ipv6.conf

echo "✓ 内核参数已修改"
echo "修改后的配置:"
cat /etc/sysctl.d/ipv6.conf | grep -E "disable_ipv6|accept_ra" || true

# 步骤3: 修改网络配置文件 - 取消IPv6注释
echo ""
echo "[步骤3] 修改网络接口配置..."
echo "当前 /etc/network/interfaces 内容:"
cat /etc/network/interfaces

# 备份原始文件
cp /etc/network/interfaces /etc/network/interfaces.bak
echo "✓ 已备份原文件到 /etc/network/interfaces.bak"

# 取消所有行的注释
sed -i -e "s/^#//g" /etc/network/interfaces

echo ""
echo "✓ 已取消IPv6相关配置的注释"
echo "修改后的配置:"
cat /etc/network/interfaces

# 步骤4: 验证配置
echo ""
echo "[步骤4] 验证配置文件..."
if grep -q "iface ens3 inet6 static" /etc/network/interfaces; then
    echo "✓ IPv6配置已正确添加"
else
    echo "⚠ 警告: 未找到IPv6配置，请检查网络接口名称"
fi

# 步骤5: 提示用户重启
echo ""
echo "=========================================="
echo "配置完成！"
echo "=========================================="
echo ""
echo "现在需要重启系统以使配置生效"
echo ""
read -p "是否立即重启系统? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "系统将在3秒后重启..."
    sleep 3
    systemctl reboot
else
    echo "请手动执行以下命令重启系统:"
    echo "  sudo systemctl reboot"
    echo ""
    echo "重启后，可用以下命令验证IPv6:"
    echo "  ip addr show ens3"
    echo "  ip -6 route show"
fi
