FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境与桌面 (保持原版)
RUN apt update && apt install -y \
    xfce4 tigervnc-standalone-server novnc websockify \
    iputils-ping net-tools curl unzip wget \
    && rm -rf /var/lib/apt/lists/*

# 2. 直接下载并解压 Xray
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 3. 创建极简配置
RUN mkdir -p /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 4. 关键：直接在 CMD 中串联启动，不依赖 entrypoint.sh 脚本
# 这样如果其中一个进程报错，不会导致整个容器启动脚本解析失败
CMD vncserver -localhost no -SecurityTypes None -geometry 1024x768 && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5901 && \
    /usr/local/bin/xray run -c /etc/xray/config.json
