#!/bin/bash

# 进入/root目录
cd /root || { echo "错误：无法进入/root目录"; exit 1; }

# 检查soga_ip.sh文件是否存在
if [ -f soga_ip.sh ]; then
    # 如果存在，删除文件
    rm soga_ip.sh
    echo "soga_ip.sh 文件已删除。"
else
    # 如果不存在，显示提示
    echo "没有找到 soga_ip.sh 文件。"
fi
