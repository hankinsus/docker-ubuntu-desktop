#!/bin/bash
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
export USER=root
touch /root/.Xauthority

# 1. 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 2. 自动定位 novnc 并启动
NOVNC_BIN=$(find /usr/share /usr/lib -name novnc_proxy | head -n 1)
[ -f "$NOVNC_BIN" ] && $NOVNC_BIN --vnc localhost:5901 --listen 6080 &

# 3. 预生成默认 Xray 配置，防止报错
mkdir -p /etc/xray
echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 4. 运行一次 monitor 更新节点，再启动 Xray
python3 /opt/scripts/monitor.py --once
/usr/local/bin/xray run -c /etc/xray/config.json &

# 5. 后台持续运行监控
python3 /opt/scripts/monitor.py &

tail -f /dev/null
