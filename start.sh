#!/bin/bash

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

export USER=root
export HOME=/root
touch /root/.Xauthority

# 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 固定启动 noVNC 在 6080 端口
if command -v novnc_proxy >/dev/null 2>&1; then
    novnc_proxy --vnc localhost:5901 --listen 6080 &
else
    websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
fi

# Xray 使用 8080 端口
cat > /etc/xray/config.json <<EOF
{
  "inbounds": [{
    "port": 8080,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}],
      "decryption": "none"
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

# 启动 Xray
/usr/local/bin/xray run -c /etc/xray/config.json &

# 等待桌面完全启动后自动打开 Firefox（关闭沙盒，提高稳定性）
sleep 3
export DISPLAY=:1
firefox --no-sandbox --disable-gpu --disable-dev-shm-usage &

tail -f /dev/null
