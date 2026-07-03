import time, json, requests, csv, subprocess, os, sys

XRAY_CONFIG = "/etc/xray/config.json"

def is_residential(ip):
    # 这里接入你的 ippure 查询逻辑
    try:
        # 注意：此处替换为实际查询逻辑
        r = requests.get(f"https://ippure.com/api/check?ip={ip}", timeout=5)
        return r.json().get("type") == "Residential"
    except: return False

def get_node():
    try:
        res = requests.get("https://www.vpngate.net/api/iphone/", timeout=10)
        lines = res.text.splitlines()[2:]
        for row in csv.reader(lines):
            if row[6] in ['Japan', 'Singapore']:
                if is_residential(row[1]): # 二次筛选住宅 IP
                    return {"ip": row[1], "port": "1080"}
        return None
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
    else:
        print("未找到满足条件的住宅节点")

if __name__ == "__main__":
    if "--once" in sys.argv: run_update()
    else:
        while True:
            run_update()
            time.sleep(3600)
