#!/bin/bash
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
export USER=root

# 1. 确保 Xauthority 存在，修复 xauth 报错
touch /root/.Xauthority

# 2. 启动 VNC
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 3. 动态寻找 novnc 并启动
NOVNC_BIN=$(find /usr/share -name novnc_proxy | head -n 1)
[ -f "$NOVNC_BIN" ] && $NOVNC_BIN --vnc localhost:5901 --listen 6080 &

# 4. 彻底解决 config.json 不存在的问题：预生成一个默认配置
mkdir -p /etc/xray
echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 5. 启动 Xray 并后台运行 monitor
/usr/local/bin/xray run -c /etc/xray/config.json &
python3 /opt/scripts/monitor.py &

tail -f /dev/null
