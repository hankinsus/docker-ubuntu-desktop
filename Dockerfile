FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 基础环境 + 桌面 + VNC + 中文支持 + Firefox依赖
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
    libasound2 \
    libx11-xcb1 \
    libxcb-shm0 \
    libxcb-render0 \
    libxrender1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    xz-utils \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# ========== 直接下载官方 Firefox 二进制包（最可靠） ==========
RUN mkdir -p /opt && \
    wget -q "https://ftp.mozilla.org/pub/firefox/releases/153.0.1/linux-x86_64/zh-CN/firefox-153.0.1.tar.xz" -O /tmp/firefox.tar.xz && \
    tar -xJf /tmp/firefox.tar.xz -C /opt/ && \
    rm /tmp/firefox.tar.xz && \
    ln -sf /opt/firefox/firefox /usr/bin/firefox

# 安装 websockify
RUN pip3 install --no-cache-dir websockify

# 安装 Xray
RUN wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip -d /usr/local/bin/ && \
    rm -f Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 创建必要目录
RUN mkdir -p /etc/xray /opt/scripts

# 复制启动脚本
COPY start.sh /start.sh
COPY monitor.py /opt/scripts/monitor.py
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
