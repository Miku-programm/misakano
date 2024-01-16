#!/bin/bash

# 检查 crontab 是否已存在该任务
if crontab -l | grep -q "/usr/local/bin/ctrld/ctrld restart"; then
    echo "Cron job already exists. No changes made."
else
    (crontab -l 2>/dev/null; echo "*/30 * * * * /usr/local/bin/ctrld restart") | crontab -
    echo "Cron job added for every 30 minutes."
fi
