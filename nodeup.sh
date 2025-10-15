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

# 2. 检测 soga.conf 中的 server_type 是否为 ss
echo -e "${YELLOW}正在检测 /etc/soga/soga.conf 中的 server_type...${NC}"
if [ -f "/etc/soga/soga.conf" ]; then
    server_type=$(grep -E "^server_type\s*=" /etc/soga/soga.conf | sed -E 's/.*=\s*//;s/\s*$//')
    
    if [ -z "$server_type" ]; then
        echo -e "${YELLOW}警告: 未找到 server_type 配置项，继续执行${NC}"
    elif [ "$server_type" = "ss" ]; then
        echo -e "${YELLOW}server_type 为 ss，跳过后续操作${NC}"
        exit 0
    else
        echo -e "${GREEN}✓ server_type 不是 ss (当前为: $server_type)，继续执行${NC}"
    fi
else
    echo -e "${YELLOW}注意: soga.conf 文件不存在，继续执行${NC}"
fi

# 3. 检测 soga.txt 是否存在
echo -e "${YELLOW}正在检测 /etc/soga/soga.txt 文件...${NC}"
if [ ! -f "/etc/soga/soga.txt" ]; then
    echo -e "${YELLOW}soga.txt 文件不存在，将创建新的配置文件${NC}"
    
    # 询问 node_id
    echo -e "${GREEN}请输入 node_id 的值:${NC}"
    read -p "node_id=" node_id
    
    # 验证输入
    if [ -z "$node_id" ]; then
        echo -e "${RED}错误: node_id 不能为空${NC}"
        exit 1
    fi
    
    # 备份原有的 soga.conf (如果存在)
    if [ -f "/etc/soga/soga.conf" ]; then
        echo -e "${YELLOW}备份原有配置文件为 soga.conf.bak${NC}"
        mv /etc/soga/soga.conf /etc/soga/soga.conf.bak
    fi
    
    # 创建新的 soga.conf
    echo -e "${YELLOW}正在创建新的 soga.conf 配置文件...${NC}"
    cat > /etc/soga/soga.conf << EOF
# 基础配置
type=xiaov2board
server_type=ss
node_id=$node_id
soga_key=HMaHZtQwjahOdn18QidnC1fajCbNu040
# webapi 或 db 对接任选一个
api=webapi
# webapi 对接信息
webapi_url=https://koumakan.quickline.top/
webapi_key=703eff19-26d3-45e2-9834-bbcd5f3cdb2b
# db 对接信息
db_host=
db_port=
db_name=
db_user=
db_password=
# 手动证书配置
cert_file=
key_file=
# 自动证书配置
cert_mode=
cert_domain=
cert_key_length=ec-256
dns_provider=
# proxy protocol 中转配置
proxy_protocol=true
udp_proxy_protocol=true
# 全局限制用户 IP 数配置
redis_enable=true
redis_addr=xianzhi.102498.xyz:56734
redis_password=ABCDEF114514
redis_db=0
conn_limit_expiry=60
# 动态限速配置
dy_limit_enable=true
dy_limit_duration=20:00-24:00,00:00-06:00
dy_limit_trigger_time=180
dy_limit_trigger_speed=100
dy_limit_speed=50
dy_limit_time=600
dy_limit_white_user_id=1,107,8740,8443,442
# 其它杂项
user_conn_limit=0
user_speed_limit=0
user_tcp_limit=0
node_speed_limit=0
check_interval=60
submit_interval=60
forbidden_bit_torrent=true
log_level=info
# 更多配置项请看文档根据需求自行添加
submit_alive_ip_min_traffic=50
EOF
    
    echo -e "${GREEN}✓ 新配置文件创建成功 (node_id=$node_id)${NC}"
    
    # 跳转到重启步骤
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
    exit 0
fi

echo -e "${GREEN}✓ soga.txt 文件存在${NC}"

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
