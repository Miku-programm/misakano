#!/bin/bash

# 节点转换脚本 - 配置soga证书和密钥

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印信息函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    print_error "请使用root权限运行此脚本"
    exit 1
fi

# 定义变量
SOGA_DIR="/etc/soga"
CERT_URL="https://raw.githubusercontent.com/Miku-programm/misakano/refs/heads/main/bili.cer"
KEY_URL="https://raw.githubusercontent.com/Miku-programm/misakano/refs/heads/main/bili.key"
CERT_FILE="bili.cer"
KEY_FILE="bili.key"
CERT_PATH="${SOGA_DIR}/${CERT_FILE}"
KEY_PATH="${SOGA_DIR}/${KEY_FILE}"
CONF_FILE="${SOGA_DIR}/soga.conf"

print_info "开始配置soga节点..."

# 1. 创建soga目录(如果不存在)
if [ ! -d "$SOGA_DIR" ]; then
    print_info "创建目录: $SOGA_DIR"
    mkdir -p "$SOGA_DIR"
fi

# 2. 下载证书
print_info "下载证书文件..."
if wget -q -O "$CERT_PATH" "$CERT_URL"; then
    print_info "证书下载成功: ${CERT_PATH}"
else
    print_error "证书下载失败"
    exit 1
fi

# 3. 下载密钥
print_info "下载密钥文件..."
if wget -q -O "$KEY_PATH" "$KEY_URL"; then
    print_info "密钥下载成功: ${KEY_PATH}"
else
    print_error "密钥下载失败"
    exit 1
fi

# 4. 设置文件权限
print_info "设置文件权限..."
chmod 644 "$CERT_PATH"
chmod 600 "$KEY_PATH"

# 5. 检查配置文件是否存在
if [ ! -f "$CONF_FILE" ]; then
    print_error "配置文件不存在: $CONF_FILE"
    exit 1
fi

# 6. 备份原配置文件
print_info "备份原配置文件..."
cp "$CONF_FILE" "${CONF_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# 7. 直接修改或添加配置
print_info "修改配置文件..."

# 删除旧的证书配置(如果存在)
sed -i '/^cert_file=/d' "$CONF_FILE"
sed -i '/^key_file=/d' "$CONF_FILE"

# 在文件末尾添加新配置
echo "" >> "$CONF_FILE"
echo "# 手动证书配置" >> "$CONF_FILE"
echo "cert_file=${CERT_PATH}" >> "$CONF_FILE"
echo "key_file=${KEY_PATH}" >> "$CONF_FILE"

print_info "配置已添加"

# 8. 显示配置内容
print_info "当前证书配置:"
echo "  cert_file=${CERT_PATH}"
echo "  key_file=${KEY_PATH}"

# 9. 验证文件存在性
print_info "验证证书文件..."
if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ]; then
    print_info "证书文件验证成功"
else
    print_error "证书文件验证失败"
    exit 1
fi

# 10. 重启soga服务
print_info "重启soga服务..."
if systemctl restart soga; then
    print_info "soga服务重启成功"
    sleep 2
    if systemctl is-active --quiet soga; then
        print_info "soga服务运行正常"
    else
        print_warning "soga服务可能未正常启动,请检查日志: journalctl -u soga -n 50"
    fi
else
    print_error "soga服务重启失败"
    print_warning "请检查日志: journalctl -u soga -n 50"
    exit 1
fi

print_info "节点配置完成!"
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}所有操作已成功完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo "证书路径: ${CERT_PATH}"
echo "密钥路径: ${KEY_PATH}"
echo "配置文件: ${CONF_FILE}"
echo "配置备份: ${CONF_FILE}.backup.*"
echo -e "\n查看服务状态: systemctl status soga"
echo "查看服务日志: journalctl -u soga -f"
