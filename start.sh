#!/bin/bash

set -e


echo "Starting Ubuntu Desktop Container"


#################################
# 创建显示环境
#################################

export DISPLAY=:1


Xvfb :1 -screen 0 1280x720x24 &


sleep 2


#################################
# 启动 XFCE
#################################

startxfce4 &


#################################
# 启动 VNC
#################################

x11vnc \
-display :1 \
-forever \
-shared \
-nopw \
-bg


#################################
# 启动 noVNC
#################################

/usr/share/novnc/utils/novnc_proxy \
--vnc localhost:5900 \
--listen 6080 &



#################################
# Xray端口
#################################

XRAY_PORT=${XRAY_PORT:-8080}


cat > /usr/local/etc/xray/config.json <<EOF

{
"log": {
"level": "warning"
},

"inbounds": [
{
"listen": "0.0.0.0",
"port": $XRAY_PORT,
"protocol": "vless",

"settings": {

"clients": [
{
"id": "YOUR-UUID-HERE",
"flow": ""
}
],

"decryption":"none"

},


"streamSettings": {

"network":"tcp"

}

}

],


"outbounds":[
{
"protocol":"freedom"
}
]

}

EOF



echo "Starting Xray port $XRAY_PORT"


/usr/local/bin/xray \
run \
-c /usr/local/etc/xray/config.json
