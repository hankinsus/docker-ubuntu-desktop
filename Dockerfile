FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境、工具、Firefox 和 Python 库
RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc python3-pip \
    curl unzip wget procps net-tools iputils-ping \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install websockify requests

# 2. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 3. 准备工作目录
RUN mkdir -p /etc/xray /opt/scripts
WORKDIR /opt/scripts

# 4. 拷贝脚本
COPY monitor.py .
RUN chmod +x monitor.py

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 5. 启动 VNC、Websockify 和 Python 监控脚本
CMD ["/bin/bash", "-c", "touch /root/.Xauthority && vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 && websockify --web=/usr/share/novnc 6080 localhost:5901 & python3 monitor.py"]
