#!/bin/bash

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

export USER=root
export HOME=/root
touch /root/.Xauthority

# 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# Railway 注入的 PORT（公网访问用这个）
PORT=${PORT:-6080}

# 启动 noVNC（必须监听 $PORT，才能通过 Railway 域名访问）
if command -v novnc_proxy >/dev/null 2>&1; then
    novnc_proxy --vnc localhost:5901 --listen "$PORT" &
else
    websockify --web=/usr/share/novnc/ "$PORT" localhost:5901 &
fi

# 初始化 Xray 配置（改用 10086 端口，避免和 noVNC 冲突）
cat > /etc/xray/config.json <<EOF
{
  "inbounds": [{
    "port": 10086,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}],
      "decryption": "none"
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

# 如果有 monitor 就运行一次
if [ -f /opt/scripts/monitor.py ]; then
    python3 /opt/scripts/monitor.py --once 2>/dev/null || true
fi

# 启动 Xray
/usr/local/bin/xray run -c /etc/xray/config.json &

# 后台持续监控
if [ -f /opt/scripts/monitor.py ]; then
    python3 /opt/scripts/monitor.py &
fi

tail -f /dev/null
