#!/bin/bash

# 1. 检测文件是否存在
if [ -f /etc/soga/soga.conf ]; then
    echo "文件 /etc/soga/soga.conf 存在"

    # 2. 读取 submit_alive_ip_min_traffic 配置
    traffic_value=$(grep '^submit_alive_ip_min_traffic=' /etc/soga/soga.conf | cut -d'=' -f2)

    if [ -n "$traffic_value" ]; then
        echo "当前 submit_alive_ip_min_traffic 值为: $traffic_value"

        # 3. 检查是否为300，若是则修改为8
        if [ "$traffic_value" = "300" ]; then
            echo "修改 submit_alive_ip_min_traffic 为 8"
            sed -i 's/^submit_alive_ip_min_traffic=300/submit_alive_ip_min_traffic=8/' /etc/soga/soga.conf
            echo "修改完成"

        # 4. 检查是否为8，若是则不修改
        elif [ "$traffic_value" = "8" ]; then
            echo "submit_alive_ip_min_traffic 已为 8，无需修改"
        else
            echo "submit_alive_ip_min_traffic 值为 $traffic_value，不符合修改条件"
        fi
    else
        echo "未找到 submit_alive_ip_min_traffic 配置"
    fi

    # 5. 重启 soga 服务
    echo "正在重启 soga 服务..."
    soga restart
    if [ $? -eq 0 ]; then
        echo "soga 服务重启成功"
    else
        echo "soga 服务重启失败，请检查服务状态"
    fi
else
    echo "文件 /etc/soga/soga.conf 不存在"
fi