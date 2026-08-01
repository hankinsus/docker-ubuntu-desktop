#!/bin/bash

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

export USER=root
export HOME=/root
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export LC_ALL=zh_CN.UTF-8
touch /root/.Xauthority

# 尝试扩大共享内存（减少闪退）
mount -o remount,size=512M /dev/shm 2>/dev/null || true

# 启动 VNC（支持自适应分辨率）
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 -AcceptSetDesktopSize --I-KNOW-THIS-IS-INSECURE

# noVNC 监听 6080
if command -v novnc_proxy >/dev/null 2>&1; then
    novnc_proxy --vnc localhost:5901 --listen 6080 &
else
    websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
fi

# Xray 监听 8080
cat > /etc/xray/config.json <<EOF
{
  "inbounds": [{
    "port": 8080,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/"
      }
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

/usr/local/bin/xray run -c /etc/xray/config.json &

# 等待桌面启动后自动打开中文火狐
sleep 5
export DISPLAY=:1
export MOZ_FORCE_DISABLE_E10S=1
export MOZ_DISABLE_CONTENT_SANDBOX=1
export MOZ_DISABLE_GMP_SANDBOX=1

firefox --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --disable-background-networking &

tail -f /dev/null
