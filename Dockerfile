FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 基础环境 + 桌面 + VNC + 中文支持
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    python3-pip \
    curl \
    unzip \
    wget \
    procps \
    net-tools \
    iputils-ping \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    language-pack-zh-hans \
    dbus-x11 \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 强制安装 deb 版 Firefox（解决 Snap 导致看不到的问题）
RUN add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y --no-install-recommends firefox firefox-locale-zh-hans && \
    rm -rf /var/lib/apt/lists/*

# 安装 websockify
RUN pip3 install --no-cache-dir websockify

# 安装 Xray
RUN wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip -d /usr/local/bin/ && \
    rm -f Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 创建必要目录
RUN mkdir -p /etc/xray /opt/scripts

# 复制启动脚本和 monitor
COPY start.sh /start.sh
COPY monitor.py /opt/scripts/monitor.py
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
