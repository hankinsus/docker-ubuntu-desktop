#!/bin/bash
# 1. 清理残留锁
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 2. 启动 VNC (添加了 -SecurityTypes None)
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720

# 3. 启动 websockify 桥接
websockify --web=/usr/share/novnc 6080 localhost:5901 &

# 4. 启动 monitor.py，它会自动在后台下载节点并启动 Xray
python3 /opt/scripts/monitor.py &

# 5. 保持容器前台运行
tail -f /dev/null
