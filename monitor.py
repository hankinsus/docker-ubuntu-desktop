import time, json, requests, csv, subprocess, os

CONFIG_FILE = "/opt/scripts/proxy_pool.json"
XRAY_CONFIG = "/etc/xray/config.json"

def fetch_vpngate_nodes():
    url = "https://www.vpngate.net/api/iphone/"
    try:
        res = requests.get(url, timeout=10)
        # 简单解析逻辑，跳过前两行
        nodes = []
        for row in csv.reader(res.text.splitlines()[2:]):
            if len(row) > 10 and row[6] in ['Japan', 'Singapore']:
                nodes.append({"ip": row[1], "port": "1080", "user": "vpn", "pass": "vpn"})
        return nodes
    except Exception as e:
        print(f"抓取失败: {e}")
        return []

def update_xray(proxy):
    config = {
        "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
        "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": proxy['ip'], "port": int(proxy['port']), "users": [{"user": proxy['user'], "pass": proxy['pass']}]}]}}]
    }
    with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
    
    # 强制杀掉旧进程并启动新配置
    os.system("pkill -9 xray")
    subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])
    print(f"Xray 已切换至出口: {proxy['ip']}")

def main():
    print("监控脚本已启动...")
    while True:
        nodes = fetch_vpngate_nodes()
        if nodes:
            # 默认取第一个可用节点
            update_xray(nodes[0])
        else:
            print("未获取到节点，等待 60 秒后重试...")
        time.sleep(60)

if __name__ == "__main__":
    main()
