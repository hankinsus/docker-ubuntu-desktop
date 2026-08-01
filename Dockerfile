FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt update && apt install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    supervisor \
    curl \
    wget \
    unzip \
    net-tools \
    firefox \
    && apt clean


# 安装 Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"


# 创建目录
RUN mkdir -p /etc/xray


# 下载 Xray 配置
COPY start.sh /start.sh

RUN chmod +x /start.sh


# Railway需要
EXPOSE 6080 8080


CMD ["/start.sh"]
