#!/bin/bash

# 清理旧锁
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

export USER=root
export HOME=/root
touch /root/.Xauthority

# 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 使用 Railway 的 PORT，本地测试默认 6080
PORT=${PORT:-6080}

# 启动 noVNC（优先用 novnc_proxy，找不到就用 websockify）
if command -v novnc_proxy >/dev/null 2>&1; then
    novnc_proxy --vnc localhost:5901 --listen $PORT &
else
    websockify --web=/usr/share/novnc/ $PORT localhost:5901 &
fi

# 初始化 Xray 配置
mkdir -p /etc/xray
echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 如果有 monitor.py 就运行一次
if [ -f /opt/scripts/monitor.py ]; then
    python3 /opt/scripts/monitor.py --once 2>/dev/null || true
fi

# 启动 Xray
/usr/local/bin/xray run -c /etc/xray/config.json &

# 后台持续监控（如果有）
if [ -f /opt/scripts/monitor.py ]; then
    python3 /opt/scripts/monitor.py &
fi

# 保持容器运行
tail -f /dev/null
