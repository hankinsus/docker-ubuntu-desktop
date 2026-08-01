FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 安装基础环境 + 中文 + 桌面 + VNC + Firefox依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    language-pack-zh-hans \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    fonts-noto-cjk \
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
    dbus-x11 \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6 \
    libasound2 \
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
    iproute2 \
    && locale-gen zh_CN.UTF-8 \
    && update-locale LANG=zh_CN.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# 安装官方中文 Firefox + 菜单快捷方式
RUN mkdir -p /opt && \
    wget -q "https://ftp.mozilla.org/pub/firefox/releases/153.0.1/linux-x86_64/zh-CN/firefox-153.0.1.tar.xz" -O /tmp/firefox.tar.xz && \
    tar -xJf /tmp/firefox.tar.xz -C /opt/ && \
    rm /tmp/firefox.tar.xz && \
    ln -sf /opt/firefox/firefox /usr/bin/firefox && \
    mkdir -p /usr/share/applications && \
    printf '%s\n' \
      '[Desktop Entry]' \
      'Name=Firefox' \
      'Name[zh_CN]=火狐浏览器' \
      'Comment=Browse the World Wide Web' \
      'Comment[zh_CN]=浏览互联网' \
      'Exec=firefox --no-sandbox --disable-gpu --disable-dev-shm-usage %u' \
      'Icon=/opt/firefox/browser/chrome/icons/default/default128.png' \
      'Terminal=false' \
      'Type=Application' \
      'Categories=Network;WebBrowser;' > /usr/share/applications/firefox.desktop && \
    chmod 644 /usr/share/applications/firefox.desktop

# 安装 websockify + Xray
RUN pip3 install --no-cache-dir websockify && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip -d /usr/local/bin/ && \
    rm -f Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray && \
    mkdir -p /etc/xray

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080 8080

CMD ["/start.sh"]
