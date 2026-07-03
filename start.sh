#!/bin/bash
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
export USER=root

# 1. 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 2. 自动定位 novnc 并启动
NOVNC_BIN=$(which novnc_proxy || find /usr/share -name novnc_proxy | head -n 1)
if [ -f "$NOVNC_BIN" ]; then
    $NOVNC_BIN --vnc localhost:5901 --listen 6080 &
fi

# 3. 确保 Xray 配置已生成 (运行一次)
python3 /opt/scripts/monitor.py --once
# 4. 启动 Xray
/usr/local/bin/xray run -c /etc/xray/config.json &

# 5. 后台持续运行监控
python3 /opt/scripts/monitor.py &

tail -f /dev/null
