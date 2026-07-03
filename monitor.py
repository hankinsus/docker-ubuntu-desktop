import os, time, csv, base64, subprocess, socket

def test_node(host, port=443):
    try:
        with socket.create_connection((host, port), timeout=5):
            return True
    except:
        return False

def switch_vpn():
    # 强制清理旧进程
    os.system("pkill -9 openvpn")
    print("正在查找最优节点...")
    os.system("curl -sL https://www.vpngate.net/api/iphone/ > nodes.csv")
    try:
        with open('nodes.csv', 'r') as f:
            reader = list(csv.reader(f))
            for row in reader[2:]:
                if row[6] in ['Japan', 'Singapore'] and row[4] == '443':
                    if test_node(row[1]):
                        with open('/etc/openvpn/current.ovpn', 'wb') as f:
                            f.write(base64.b64decode(row[-1]))
                        print(f"切换至节点: {row[0]}")
                        return True
    except Exception as e:
        print(f"节点切换错误: {e}")
    return False

# 主循环
while True:
    if os.system("pgrep openvpn") != 0:
        if switch_vpn():
            subprocess.Popen(["openvpn", "--daemon", "--config", "/etc/openvpn/current.ovpn"])
    time.sleep(60)
