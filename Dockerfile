FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 基础环境
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
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ========== 强制安装真正的 deb 版 Firefox ==========
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null

RUN echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla

RUN apt-get update && \
    apt-get install -y --no-install-recommends firefox && \
    rm -rf /var/lib/apt/lists/*

# 安装 websockify
RUN pip3 install --no-cache-dir websockify

# 安装 Xray
RUN wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip -d /usr/local/bin/ && \
    rm -f Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

RUN mkdir -p /etc/xray /opt/scripts

COPY start.sh /start.sh
COPY monitor.py /opt/scripts/monitor.py
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
