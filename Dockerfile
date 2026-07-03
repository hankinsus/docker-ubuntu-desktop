FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc python3-pip xauth \
    curl unzip wget procps net-tools iputils-ping \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install websockify requests

RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 创建配置目录并确保 start.sh 可执行
RUN mkdir -p /etc/xray /opt/scripts
COPY monitor.py /opt/scripts/monitor.py
COPY start.sh /start.sh
RUN chmod +x /start.sh /opt/scripts/monitor.py

CMD ["/start.sh"]
