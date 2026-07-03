FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 仅安装必要组件，确保构建稳健
RUN apt update && apt install -y \
    xfce4 tigervnc-standalone-server novnc websockify \
    iputils-ping net-tools curl unzip wget \
    && rm -rf /var/lib/apt/lists/*

# 安装 Xray
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip

# 预置 Xray 配置文件 (保持你的 UUID)
RUN mkdir -p /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 简洁启动脚本
RUN echo '#!/bin/bash\n\
vncserver -localhost no -SecurityTypes None -geometry 1024x768 &\n\
websockify -D --web=/usr/share/novnc/ 6080 localhost:5901 &\n\
/usr/local/bin/xray run -c /etc/xray/config.json &\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 6080 8080
CMD ["/entrypoint.sh"]
