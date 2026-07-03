FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础依赖与工具
RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc python3-pip \
    curl unzip wget procps net-tools iputils-ping \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

# 2. Xray Core 安装
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 3. 核心修复：VNC 和 Xray 的启动脚本
# 我们将所有启动逻辑打包进一个 start.sh，确保顺序执行
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
# 启动 VNC 并强制跳过认证\n\
vncserver :1 -localhost no -geometry 1280x720 -SecurityTypes None &\n\
# 启动 novnc 桥接\n\
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &\n\
# 启动 Xray\n\
/usr/local/bin/xray run -c /etc/xray/config.json &\n\
# 保持容器运行\n\
tail -f /dev/null' > /start.sh && chmod +x /start.sh

# 4. 初始化 Xray 配置
RUN mkdir -p /etc/xray
RUN echo '{"inbounds":[{"port":8080,"protocol":"vless","settings":{"clients":[{"id":"9b191c56-d0fd-6889-ac99-3016ba36a189"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

CMD ["/start.sh"]
