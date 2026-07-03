FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境与工具安装
RUN apt update && apt install -y \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc \
    python3-pip curl unzip wget procps net-tools iputils-ping \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 websockify
RUN pip3 install websockify

# 3. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 4. 写入 Xray 配置文件
RUN mkdir -p /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 5. 设置中文环境
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 6. 核心优化：修复 405 错误与自动启动
# 注意：我们增加了 --vnc 路径指向和正确的命令组合
CMD touch /root/.Xauthority && \
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5901 & \
    /usr/local/bin/xray run -c /etc/xray/config.json & \
    tail -f /dev/null
