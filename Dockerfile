FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. 合并安装基础桌面组件，并引入本地化包（locales）与文泉驿中文字体
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    locales fonts-wqy-zenhei && rm -rf /var/lib/apt/lists/*

# 2. 强行在系统底层生成 zh_CN.UTF-8 语言包
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen zh_CN.UTF-8

# 3. 注入系统级环境变量，强行让 VNC 启动时的进程树全部采用中文 UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 4. 兼容性：同时将语言环境写入所有的用户配置文件中
RUN echo 'export LANG=zh_CN.UTF-8' >> /etc/profile && \
    echo 'export LC_ALL=zh_CN.UTF-8' >> /etc/profile && \
    echo 'export LANGUAGE=zh_CN:zh' >> /etc/profile && \
    echo 'export LANG=zh_CN.UTF-8' >> /root/.bashrc && \
    echo 'export LC_ALL=zh_CN.UTF-8' >> /root/.bashrc

# 5. 原有的 Firefox PPA 软件源及浏览器安装（保持不变）
RUN apt update -y && apt install software-properties-common -y
RUN add-apt-repository ppa:mozillateam/ppa -y
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
RUN apt update -y && apt install -y firefox xubuntu-icon-theme

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj \"/C=JP\" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null"
