FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基础环境安装
RUN apt update && apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server novnc python3-pip \
    curl unzip wget procps net-tools iputils-ping \
    firefox firefox-locale-zh-hans \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 Python 工具库
RUN pip3 install websockify requests

# 3. 安装 Xray Core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && rm Xray-linux-64.zip && \
    chmod +x /usr/local/bin/xray

# 4. 创建必要目录
RUN mkdir -p /etc/xray /opt/scripts

WORKDIR /opt/scripts
COPY monitor.py .
RUN chmod +x monitor.py

# 5. 启动指令：
# - 强制清理 X11 锁文件
# - 启动 vncserver 并指定不使用密码访问
# - websockify 桥接端口
# - 启动 Python 监控脚本
CMD ["/bin/bash", "-c", "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 && vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 && websockify --web=/usr/share/novnc 6080 localhost:5901 & python3 monitor.py"]
