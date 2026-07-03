import time, json, requests, csv, subprocess, os, signal

CONFIG_FILE = "/opt/scripts/proxy_pool.json"
XRAY_CONFIG = "/etc/xray/config.json"

def fetch_vpngate_nodes():
    """抓取 VPNGate 节点"""
    url = "https://www.vpngate.net/api/iphone/"
    try:
        res = requests.get(url, timeout=15)
        reader = csv.reader(res.text.splitlines()[2:])
        nodes = []
        for row in reader:
            # 筛选日本/新加坡节点，假设端口为 1080 (VPNGate 若提供 socks 需调整)
            if row[6] in ['Japan', 'Singapore']:
                nodes.append({"ip": row[1], "port": "1080", "user": "vpn", "pass": "vpn"})
        return nodes
    except: return []

def check_proxy(proxy):
    """测试代理可用性"""
    try:
        proxies = {"http": f"socks5://{proxy['user']}:{proxy['pass']}@{proxy['ip']}:{proxy['port']}"}
        requests.get("https://www.google.com", proxies=proxies, timeout=5)
        return True
    except: return False

def update_xray(proxy):
    """动态写入 Xray 配置并重启进程"""
    config = {
        "inbounds": [{"port": 8080, "protocol": "vless", "settings": {"clients": [{"id": "9b191c56-d0fd-6889-ac99-3016ba36a189"}], "decryption": "none"}}],
        "outbounds": [{"protocol": "socks", "settings": {"servers": [{"address": proxy['ip'], "port": int(proxy['port']), "users": [{"user": proxy['user'], "pass": proxy['pass']}]}]}}]
    }
    with open(XRAY_CONFIG, 'w') as f: json.dump(config, f)
    
    # 优雅重启 Xray
    os.system("pkill -9 xray")
    subprocess.Popen(["/usr/local/bin/xray", "run", "-c", XRAY_CONFIG])

def main():
    while True:
        # 1. 维护节点池
        pool = []
        if os.path.exists(CONFIG_FILE): pool = json.load(open(CONFIG_FILE))
        valid_pool = [p for p in pool if check_proxy(p)]
        
        # 2. 补齐节点
        if len(valid_pool) < 5:
            for node in fetch_vpngate_nodes():
                if len(valid_pool) >= 10: break
                if check_proxy(node): valid_pool.append(node)
            json.dump(valid_pool, open(CONFIG_FILE, 'w'))
        
        # 3. 监控出口，如果失效自动切换
        if valid_pool:
            if not check_proxy(valid_pool[0]):
                update_xray(valid_pool[0])
                
        time.sleep(60) # 每分钟检测一次

if __name__ == "__main__":
    main()
