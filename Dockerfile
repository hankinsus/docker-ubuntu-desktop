FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境安装
RUN apt update && apt install -y \
    xfce4 tigervnc-standalone-server novnc \
    python3-pip curl unzip wget procps net-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 websockify
RUN pip3 install websockify

# 3. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 4. 写入 Xray 配置文件 (默认端口 8080)
RUN mkdir -p /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 5. 定义启动逻辑
# --I-KNOW-THIS-IS-INSECURE 是必须的参数，否则 VNC 会在启动时自毁
CMD vncserver :1 -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
    websockify -D 6080 localhost:5901 && \
    /usr/local/bin/xray run -c /etc/xray/config.json && \
    tail -f /dev/null
