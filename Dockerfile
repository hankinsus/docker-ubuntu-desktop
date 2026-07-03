import time, json, requests, csv, subprocess, os, sys

XRAY_CONFIG = "/etc/xray/config.json"

def is_residential(ip):
    try:
        # 如果 ippure 接口不可用，这里会捕获异常并默认返回 False
        r = requests.get(f"https://ippure.com/api/check?ip={ip}", timeout=3)
        return r.json().get("type") == "Residential"
    except: return False

def get_best_node():
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=10)
        lines = res.text.splitlines()[2:]
        all_nodes = []
        for row in csv.reader(lines):
            if row[6] in ['Japan', 'Singapore']:
                all_nodes.append({"ip": row[1], "port": "1080"})
        
        # 第一轮：优先找住宅 IP
        for node in all_nodes:
            if is_residential(node['ip']): return node
        
        # 第二轮：找不到则返回第一个可用节点 (兜底逻辑)
        return all_nodes[0] if all_nodes else None
    except: return None

def run_update():
    node = get_best_node()
    if node:
        config = {
            "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
            "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": node['ip'], "port": int(node['port'])}]}}]
        }
        with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
        # 仅在 config 文件存在时才尝试重启
        if os.path.exists(XRAY_CONFIG):
            os.system("pkill -9 xray")
            subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])
    else:
        print("未找到任何可用节点")

if __name__ == "__main__":
    if "--once" in sys.argv: run_update()
    else:
        while True:
            run_update()
            time.sleep(3600)
