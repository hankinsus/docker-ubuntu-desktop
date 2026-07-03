#!/bin/bash
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
export USER=root
touch /root/.Xauthority

# 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 动态查找并启动 novnc
NOVNC_PATH=$(find /usr/share/novnc /usr/lib/novnc -name novnc_proxy | head -n 1)
$NOVNC_PATH --vnc localhost:5901 --listen 6080 &

# 确保配置生成后再启动 Xray
python3 /opt/scripts/monitor.py --once
/usr/local/bin/xray run -c /etc/xray/config.json &

# 后台轮询
python3 /opt/scripts/monitor.py &

tail -f /dev/null
