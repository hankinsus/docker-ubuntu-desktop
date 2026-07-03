#!/bin/bash
# 清理锁文件
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 启动 VNC：添加 --I-KNOW-THIS-IS-INSECURE 跳过所有认证检查
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# 启动 Web 桥接
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &

# 关键：先执行一次 monitor 生成节点配置，再后台运行
python3 /opt/scripts/monitor.py --once
/usr/local/bin/xray run -c /etc/xray/config.json &

# 后台持续运行监控
python3 /opt/scripts/monitor.py &

tail -f /dev/null
