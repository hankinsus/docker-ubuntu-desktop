import time, json, requests, csv, subprocess, os

XRAY_CONFIG = "/etc/xray/config.json"

def is_residential(ip):
    # 依然保留查询，但如果查询失败，默认视为“非住宅”，不影响后续机房 IP 逻辑
    try:
        r = requests.get(f"https://ippure.com/api/check?ip={ip}", timeout=2)
        return r.json().get("type") == "Residential"
    except: return False

def get_node():
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=10)
        lines = res.text.splitlines()[2:]
        nodes = []
        for row in csv.reader(lines):
            # 扩大搜索范围：不再限制地区
            nodes.append({"ip": row[1], "port": "1080"})
        
        # 排序：遍历所有节点，优先返回住宅 IP
        for node in nodes:
            if is_residential(node['ip']): return node
        
        # 兜底：返回第一个找到的节点
        return nodes[0] if nodes else None
    except: return None

def update_xray():
    node = get_node()
    if node:
        config = {
            "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
            "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": node['ip'], "port": int(node['port'])}]}}]
        }
        with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
        os.system("pkill -9 xray")
        subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])
        print(f"Xray已部署节点: {node['ip']}")

if __name__ == "__main__":
    while True:
        update_xray()
        time.sleep(3600)
