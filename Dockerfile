FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 安装核心组件
RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc python3-pip \
    curl unzip wget procps net-tools iputils-ping \
    fonts-wqy-microhei fonts-wqy-zenhei language-pack-zh-hans \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install websockify requests

# 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

RUN mkdir -p /etc/xray /opt/scripts /root/.vnc
WORKDIR /opt/scripts

# 写入 VNC 初始密码 (解决启动拒绝问题)
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

COPY monitor.py .
RUN chmod +x monitor.py

ENV LANG=zh_CN.UTF-8

# 启动流程：清理锁文件 -> 启动 VNC -> 启动 Web 桥接 -> 启动监控脚本
CMD ["/bin/bash", "-c", "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 && vncserver :1 -localhost no -geometry 1280x720 && websockify --web=/usr/share/novnc 6080 localhost:5901 & python3 monitor.py"]
