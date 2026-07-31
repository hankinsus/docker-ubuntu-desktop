FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 基础环境 + 桌面 + VNC + 中文支持
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc \
    python3-pip curl unzip wget procps net-tools iputils-ping \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    dbus-x11 libgtk-3-0 libdbus-glib-1-2 libxt6 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 强制安装 deb 版 Firefox（避免 Snap 问题）
RUN add-apt-repository -y ppa:mozillateam/ppa && \
    echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y firefox firefox-locale-zh-hans && \
    rm -rf /var/lib/apt/lists/*

# 安装 websockify
RUN pip3 install websockify

# 安装 Xray
RUN wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && \
    rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 复制 monitor（如果有的话）
COPY monitor.py /opt/scripts/monitor.py
RUN mkdir -p /opt/scripts

EXPOSE 6080

CMD ["/start.sh"]
