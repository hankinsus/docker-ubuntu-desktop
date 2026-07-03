FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装原有桌面组件 + 新增的网络/Xray/Aimili 依赖
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    locales fonts-wqy-zenhei \
    openvpn iputils-ping iptables iproute2 unzip nano \
    && rm -rf /var/lib/apt/lists/*

# 2. 语言包与环境配置
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8 LANGUAGE=zh_CN:zh LC_ALL=zh_CN.UTF-8

# 3. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 4. 预置 Xray 配置文件 (使用你指定的新 UUID)
RUN mkdir -p /etc/xray
RUN cat <<EOF > /etc/xray/config.json
{
    "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}, "streamSettings": {"network": "ws", "wsSettings": {"path": "/"}}}],
    "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": "127.0.0.1", "port": 7928}]}}]
}
EOF

# 5. 整合 entrypoint.sh (包含 Web 管理端口 8787 的处理)
RUN echo '#!/bin/bash\n\
# 启动 VNC 及桌面环境\n\
vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE\n\
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out /self.pem -keyout /self.pem\n\
websockify -D --web=/usr/share/novnc/ --cert=/self.pem 6080 localhost:5901\n\
# 启动 AimiliVPN，确保 Web 管理界面绑定在 127.0.0.1:8787\n\
# 如果脚本支持参数，请确保其监听 127.0.0.1:8787\n\
bash <(curl -Ls https://raw.githubusercontent.com/baoweise-bot/aimili-vpngate/main/install.sh) &\n\
# 等待 Aimili 启动并占用 7928 和 8787 端口\n\
sleep 20\n\
# 启动 Xray\n\
/usr/local/bin/xray run -c /etc/xray/config.json &\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

# 暴露端口：5901/6080(VNC), 8080(VLESS)
EXPOSE 5901 6080 8080

CMD ["/entrypoint.sh"]
