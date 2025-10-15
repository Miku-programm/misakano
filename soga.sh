#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 定义路径
SOGA_DIR="/etc/soga"
SOGA_TXT="${SOGA_DIR}/soga.txt"
SOGA_CONF="${SOGA_DIR}/soga.conf"
SOGA_CONF_BAK="${SOGA_DIR}/soga.conf.bak"

echo "===================================="
echo "  Soga 配置文件切换脚本"
echo "===================================="

# 1. 检测路径 /etc/soga/ 是否存在
echo -e "\n${YELLOW}[1/5]${NC} 检测目录 ${SOGA_DIR} ..."
if [ ! -d "${SOGA_DIR}" ]; then
    echo -e "${RED}错误: 目录 ${SOGA_DIR} 不存在!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 目录存在${NC}"

# 2. 检测 soga.txt 是否存在
echo -e "\n${YELLOW}[2/5]${NC} 检测文件 ${SOGA_TXT} ..."
if [ ! -f "${SOGA_TXT}" ]; then
    echo -e "${RED}错误: 文件 ${SOGA_TXT} 不存在!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 文件存在${NC}"

# 3. 将 soga.conf 改为 soga.conf.bak
echo -e "\n${YELLOW}[3/5]${NC} 备份配置文件..."
if [ -f "${SOGA_CONF}" ]; then
    mv "${SOGA_CONF}" "${SOGA_CONF_BAK}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${SOGA_CONF} 已重命名为 ${SOGA_CONF_BAK}${NC}"
    else
        echo -e "${RED}错误: 重命名失败!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ ${SOGA_CONF} 不存在,跳过备份${NC}"
fi

# 4. 将 soga.txt 改为 soga.conf
echo -e "\n${YELLOW}[4/5]${NC} 重命名配置文件..."
mv "${SOGA_TXT}" "${SOGA_CONF}"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ ${SOGA_TXT} 已重命名为 ${SOGA_CONF}${NC}"
else
    echo -e "${RED}错误: 重命名失败!${NC}"
    # 尝试恢复备份
    if [ -f "${SOGA_CONF_BAK}" ]; then
        mv "${SOGA_CONF_BAK}" "${SOGA_CONF}"
        echo -e "${YELLOW}已恢复原配置文件${NC}"
    fi
    exit 1
fi

# 5. 重启 soga
echo -e "\n${YELLOW}[5/5]${NC} 重启 soga 服务..."
if command -v systemctl &> /dev/null; then
    systemctl restart soga
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Soga 服务重启成功${NC}"
        # 检查服务状态
        sleep 2
        systemctl is-active --quiet soga
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Soga 服务运行正常${NC}"
        else
            echo -e "${RED}⚠ Soga 服务可能未正常运行,请检查日志${NC}"
        fi
    else
        echo -e "${RED}错误: Soga 服务重启失败!${NC}"
        exit 1
    fi
else
    echo -e "${RED}错误: 未找到 systemctl 命令${NC}"
    exit 1
fi

echo -e "\n${GREEN}===================================="
echo -e "  配置切换完成!"
echo -e "====================================${NC}"