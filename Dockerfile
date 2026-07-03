FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装依赖，增加了 firefox 和中文语言包
RUN apt update && apt install -y \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc \
    python3-pip curl unzip wget procps net-tools openvpn \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install websockify

# 2. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 3. 准备 VPN 管理和 Xray 配置目录
RUN mkdir -p /opt/vpn_manager /etc/openvpn/ /etc/xray

# 4. 写入 Xray 配置文件
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

WORKDIR /opt/vpn_manager
COPY monitor.py .

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 5. 启动入口
CMD touch /root/.Xauthority && \
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE && \
    websockify -D 6080 localhost:5901 && \
    /usr/local/bin/xray run -c /etc/xray/config.json & \
    python3 monitor.py & \
    tail -f /dev/null
