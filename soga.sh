#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 检测路径 /etc/soga/ 是否存在
echo -e "${YELLOW}正在检测 /etc/soga/ 路径...${NC}"
if [ ! -d "/etc/soga/" ]; then
    echo -e "${RED}错误: /etc/soga/ 路径不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✓ /etc/soga/ 路径存在${NC}"

# 2. 检测 soga.txt 是否存在
echo -e "${YELLOW}正在检测 /etc/soga/soga.txt 文件...${NC}"
if [ ! -f "/etc/soga/soga.txt" ]; then
    echo -e "${RED}错误: /etc/soga/soga.txt 文件不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✓ soga.txt 文件存在${NC}"

# 3. 检测 server_type 的值是否为 vless
echo -e "${YELLOW}正在检测 server_type 的值...${NC}"
server_type=$(grep -E "^server_type\s*=" /etc/soga/soga.txt | sed -E 's/.*=\s*//;s/\s*$//')

if [ -z "$server_type" ]; then
    echo -e "${RED}警告: 未找到 server_type 配置项${NC}"
    exit 1
fi

echo -e "${YELLOW}当前 server_type = $server_type${NC}"

if [ "$server_type" != "vless" ]; then
    echo -e "${YELLOW}server_type 不是 vless，跳过后续操作${NC}"
    exit 0
fi

echo -e "${GREEN}✓ server_type 为 vless，继续执行${NC}"

# 4. 将 soga.conf 改为 soga.conf.bak
echo -e "${YELLOW}正在备份 soga.conf...${NC}"
if [ -f "/etc/soga/soga.conf" ]; then
    mv /etc/soga/soga.conf /etc/soga/soga.conf.bak
    echo -e "${GREEN}✓ 已将 soga.conf 重命名为 soga.conf.bak${NC}"
else
    echo -e "${YELLOW}注意: soga.conf 文件不存在，跳过备份步骤${NC}"
fi

# 5. 将 soga.txt 改为 soga.conf
echo -e "${YELLOW}正在将 soga.txt 重命名为 soga.conf...${NC}"
mv /etc/soga/soga.txt /etc/soga/soga.conf
echo -e "${GREEN}✓ 已将 soga.txt 重命名为 soga.conf${NC}"

# 6. 重启 soga 服务
echo -e "${YELLOW}正在重启 soga 服务...${NC}"
if command -v systemctl &> /dev/null; then
    systemctl restart soga
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ soga 服务重启成功${NC}"
        systemctl status soga --no-pager
    else
        echo -e "${RED}错误: soga 服务重启失败${NC}"
        exit 1
    fi
else
    echo -e "${RED}错误: systemctl 命令不可用${NC}"
    exit 1
fi

echo -e "${GREEN}所有操作完成！${NC}"
