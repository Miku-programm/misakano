#!/bin/bash

# 检测并安装 curl
if ! command -v curl &> /dev/null; then
    echo "curl 未安装，正在安装..."
    sudo apt update
    sudo apt install curl -y
else
    echo "curl 已安装，跳过安装步骤。"
fi

# 安装 chrony
echo "安装 chrony..."
sudo apt update
sudo apt install chrony -y

# 设置时区为 Asia/Shanghai
echo "设置时区为 Asia/Shanghai..."
sudo timedatectl set-timezone Asia/Shanghai

# 验证时间
echo "当前系统时间："
date
