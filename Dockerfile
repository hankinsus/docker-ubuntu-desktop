#!/bin/bash

# 1. 启动 Xray (后台运行)
/usr/local/bin/xray run -c /etc/xray/config.json &

# 2. VNC 稳健启动：强制免密，且在后台运行
# 注意：vncserver :1 是启动显示 1，这是标准的 VNC 启动方式
mkdir -p ~/.vnc
echo "password" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 启动 VNC 桌面服务
vncserver :1 -geometry 1024x768 -depth 24 &

# 3. 启动 websockify 转发 (novnc 端口)
# 确保它指向 5901 (即 :1 对应的端口)
websockify -D --web=/usr/share/novnc/ 6080 localhost:5901

# 保持存活
tail -f /dev/null
