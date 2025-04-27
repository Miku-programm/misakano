#!/bin/bash

# 检查是否以root用户运行
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root权限运行，请使用sudo或切换到root用户"
    exit 1
fi

# 安装openssh-server
echo "正在安装openssh-server..."
apt-get update
apt-get install -y openssh-server

# 启用并启动ssh服务
echo "正在启用并启动SSH服务..."
systemctl enable ssh
systemctl start ssh

# 检查SSH服务状态
echo "检查SSH服务状态..."
if systemctl is-active --quiet ssh; then
    echo "SSH服务已成功启动"
else
    echo "SSH服务启动失败，请检查日志"
    exit 1
fi

# 开放22端口（如果使用ufw）
if command -v ufw >/dev/null; then
    echo "正在配置防火墙..."
    ufw allow 22
    ufw reload
fi

# 显示SSH配置信息
echo "SSH服务配置完成"
echo "默认端口：22"
echo "可以通过 'systemctl status ssh' 查看服务状态"
echo "可以通过 'nano /etc/ssh/sshd_config' 修改SSH配置文件"
