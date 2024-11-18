#!/bin/bash

# 定义要下载的文件 URLs
FILE1="https://raw.githubusercontent.com/Miku-programm/misakano/refs/heads/main/custom_inbound.json"
FILE2="https://raw.githubusercontent.com/Miku-programm/misakano/refs/heads/main/custom_outbound.json"
FILE3="https://raw.githubusercontent.com/Miku-programm/misakano/refs/heads/main/route.json"

# 定义要下载的文件名
FILES=("custom_inbound.json" "custom_outbound.json" "route.json")

# 定义目标目录
V2BX_DIR="/etc/V2bx"
XRAYR_DIR="/etc/XrayR"

# 提示用户选择覆盖的目录
echo "请选择覆盖目标："
echo "1. 覆盖至 V2bx"
echo "2. 覆盖至 XrayR"
echo "3. 同时覆盖至 V2bx 和 XrayR"
read -p "请输入选项 (1、2 或 3): " choice

# 检查用户输入是否合法
if [ "$choice" != "1" ] && [ "$choice" != "2" ] && [ "$choice" != "3" ]; then
    echo "无效的选项，程序退出。"
    exit 1
fi

# 下载文件的函数
download_and_copy() {
    local target_dir=$1
    echo "正在下载文件到 $target_dir..."
    
    # 检查目标目录是否存在
    if [ ! -d "$target_dir" ]; then
        echo "目标目录不存在: $target_dir，正在创建..."
        mkdir -p "$target_dir"
    fi

    # 下载文件并覆盖
    for FILE_URL in "$FILE1" "$FILE2" "$FILE3"; do
        FILE_NAME=$(basename "$FILE_URL")
        wget -q "$FILE_URL" -O "$target_dir/$FILE_NAME"
        if [ $? -ne 0 ]; then
            echo "下载失败: $FILE_NAME"
            exit 1
        fi
        echo "已下载并覆盖: $target_dir/$FILE_NAME"
    done
}

# 根据用户选择执行操作
case "$choice" in
    1)
        download_and_copy "$V2BX_DIR"
        ;;
    2)
        download_and_copy "$XRAYR_DIR"
        ;;
    3)
        download_and_copy "$V2BX_DIR"
        download_and_copy "$XRAYR_DIR"
        ;;
esac

# 显示完成消息
echo "操作完成！所有文件已成功下载并覆盖。"
