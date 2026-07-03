import time, json, requests, csv, subprocess, os

XRAY_CONFIG = "/etc/xray/config.json"

def get_vpngate_node():
    # 简单的节点抓取逻辑
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=10)
        for row in csv.reader(res.text.splitlines()[2:]):
            if row[6] in ['Japan', 'Singapore']:
                return {"ip": row[1], "port": "1080"} # 假设端口
    except: return None

def update_and_run():
    node = get_vpngate_node()
    if node:
        config = {
            "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
            "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": node['ip'], "port": int(node['port'])}]}}]
        }
        with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
        os.system("pkill -9 xray")
        subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])
        print(f"Xray 已切换至节点: {node['ip']}")

if __name__ == "__main__":
    update_and_run()
