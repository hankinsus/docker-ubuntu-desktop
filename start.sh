#!/bin/bash

set -e


echo "Starting Ubuntu Desktop"


#################################
# 环境
#################################

export DISPLAY=:1


#################################
# X Server
#################################

Xvfb :1 \
-screen 0 1280x720x24 \
-ac &


sleep 3


#################################
# XFCE桌面
#################################

startxfce4 &


sleep 3


#################################
# VNC
#################################

x11vnc \
-display :1 \
-forever \
-shared \
-nopw \
-bg


#################################
# noVNC
#################################

websockify \
--web=/usr/share/novnc \
6080 \
localhost:5900 &



#################################
# Xray
#################################

UUID=${UUID:-"9b191c56-d0fd-6889-ac99-3016ba36a189"}

XRAY_PORT=${PORT:-8080}


mkdir -p /etc/xray


cat >/etc/xray/config.json <<EOF

{
"log":{
"level":"warning"
},

"inbounds":[
{
"listen":"0.0.0.0",
"port":${XRAY_PORT},

"protocol":"vless",

"settings":{

"clients":[
{
"id":"${UUID}"
}
],

"decryption":"none"

},

"streamSettings":{

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



echo "Xray running port ${XRAY_PORT}"


/usr/local/bin/xray run \
-c /etc/xray/config.json
