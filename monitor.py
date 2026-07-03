import time, json, requests, csv, subprocess, os, sys

XRAY_CONFIG = "/etc/xray/config.json"

def is_residential(ip):
    try:
        r = requests.get(f"https://ippure.com/api/check?ip={ip}", timeout=3)
        return r.json().get("type") == "Residential"
    except: return False

def get_node():
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=10)
        lines = res.text.splitlines()[2:]
        nodes = []
        for row in csv.reader(lines):
            nodes.append({"ip": row[1], "port": "1080"})
        # 搜索：优先住宅，无则使用列表第一个节点兜底
        for node in nodes:
            if is_residential(node['ip']): return node
        return nodes[0] if nodes else None
    except: return None

def run_update():
    node = get_node()
    if node:
        config = {
            "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
            "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": node['ip'], "port": int(node['port'])}]}}]
        }
        with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
        os.system("pkill -9 xray")
        subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])

if __name__ == "__main__":
    if "--once" in sys.argv: run_update()
    else:
        while True:
            run_update()
            time.sleep(3600)
