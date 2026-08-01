#!/bin/bash

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

export USER=root
export HOME=/root
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export LC_ALL=zh_CN.UTF-8
touch /root/.Xauthority

# 尝试扩大共享内存
mount -o remount,size=512M /dev/shm 2>/dev/null || true

# ========== 限制总带宽（防止测速/YouTube 把内存打爆） ==========
# 限制为约 120Mbps（可按需要调整）
if command -v tc >/dev/null 2>&1; then
    tc qdisc del dev eth0 root 2>/dev/null || true
    tc qdisc add dev eth0 root tbf rate 60mbit burst 32kbit latency 400ms 2>/dev/null || true
fi

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

# 创建低内存火狐配置
mkdir -p /root/.mozilla/firefox/default
cat > /root/.mozilla/firefox/profiles.ini <<EOF
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=1
Path=default
Default=1
EOF

cat > /root/.mozilla/firefox/default/user.js <<EOF
user_pref("browser.tabs.remote.autostart", false);
user_pref("browser.tabs.remote.autostart.2", false);
user_pref("layers.acceleration.disabled", true);
user_pref("gfx.webrender.all", false);
user_pref("gfx.webrender.enabled", false);
user_pref("media.hardware-video-decoding.enabled", false);
user_pref("dom.ipc.processCount", 1);
user_pref("dom.ipc.processCount.web", 1);
user_pref("browser.cache.memory.enable", false);
user_pref("browser.cache.disk.enable", false);
user_pref("network.http.max-connections", 32);
user_pref("toolkit.cosmeticAnimations.enabled", false);
EOF

# 自动打开火狐
sleep 5
export DISPLAY=:1
export MOZ_FORCE_DISABLE_E10S=1
export MOZ_DISABLE_CONTENT_SANDBOX=1
export MOZ_DISABLE_GMP_SANDBOX=1

firefox --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --disable-background-networking -P default &

tail -f /dev/null
