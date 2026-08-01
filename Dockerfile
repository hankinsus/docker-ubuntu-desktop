FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai

RUN apt update && apt install -y \
    wget \
    curl \
    unzip \
    supervisor \
    net-tools \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    xvfb \
    novnc \
    python3 \
    python3-websockify \
    firefox \
    && rm -rf /var/lib/apt/lists/*


# 安装 Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install


COPY xray/config.json /usr/local/etc/xray/config.json


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


COPY start.sh /start.sh

RUN chmod +x /start.sh


EXPOSE 6080 8080


CMD ["/start.sh"]
