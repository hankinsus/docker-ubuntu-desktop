import time, json, requests, csv, subprocess, os

CONFIG_FILE = "/opt/scripts/proxy_pool.json"
XRAY_CONFIG = "/etc/xray/config.json"

def fetch_vpngate_nodes():
    """从 VPNGate API 抓取并提取节点"""
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=15)
        nodes = []
        for row in csv.reader(res.text.splitlines()[2:]):
            if len(row) > 10 and row[6] in ['Japan', 'Singapore']:
                # VPNGate 官方主要提供 OpenVPN，这里假设端口为 1080 进行测试
                nodes.append({"ip": row[1], "port": "1080", "user": "vpn", "pass": "vpn"})
        return nodes
    except: return []

def update_xray(proxy):
    """注入配置并重启 Xray"""
    config = {
        "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
        "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": proxy['ip'], "port": int(proxy['port']), "users": [{"user": proxy['user'], "pass": proxy['pass']}]}]}}]
    }
    with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
    os.system("pkill -9 xray")
    subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])

def main():
    while True:
        nodes = fetch_vpngate_nodes()
        if nodes:
            update_xray(nodes[0]) # 自动使用第一个抓取到的节点
        time.sleep(3600) # 每小时自动轮换

if __name__ == "__main__":
    main()
