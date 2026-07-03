FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境
RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc \
    python3-pip curl unzip wget procps net-tools openvpn \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install websockify

# 2. Xray Core 安装
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 3. 目录与配置
RUN mkdir -p /opt/vpn_manager /etc/openvpn/ /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

WORKDIR /opt/vpn_manager
COPY monitor.py .
# 【关键改进】：确保脚本具有执行权限
RUN chmod +x monitor.py

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 【关键改进】：使用 exec 模式和更好的启动逻辑
# 使用 /bin/bash -c 确保所有后台进程在同一个 shell 环境下正确初始化
CMD ["/bin/bash", "-c", "touch /root/.Xauthority && vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE && websockify -D 6080 localhost:5901 && /usr/local/bin/xray run -c /etc/xray/config.json & python3 /opt/vpn_manager/monitor.py & tail -f /dev/null"]
