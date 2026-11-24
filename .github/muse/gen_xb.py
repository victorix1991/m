#!/usr/bin/env python3
"""Generate x (L×Box share links) from s (v2rayNG subscription). b (SFA) dropped 2026-11-24 (user: 太不灵活).
Muse 2026-11-23. s is read only, never written.
Usage: gen_xb.py <s> <out_x>
Prints only counts / field names, NEVER contents (public repo logs). Exit 0 ok, 1 fail.
Rules (user-approved):
- x: direct IP + SPKI pin, no port hopping (L×Box backend untouched; only node changes propagate).
- b: same structure as template; node servers keep s domains, hy2 port hopping copied from s mport.
"""
import base64, json, socket, sys, urllib.parse

# domain -> IP for x (fallback: DNS resolve A record)
IP_MAP = {
    "speedtest.nea.kdns.fr": "148.135.121.38",     # CloudCone hy2
    "speedtest-tc.nea.kdns.fr": "49.234.200.146",  # Tencent SS
    "speedtest.xlat.kdns.fr": "148.135.121.38",    # CloudCone hy2 (moved 2026-11-23)
    "speedtest-tc.xlat.kdns.fr": "49.234.200.146", # Tencent SS (moved 2026-11-23)
}
# hy2 cert SHA256 (hex, as in s/v2rayNG) -> SPKI SHA256 base64 (as in x/L×Box)
PIN_MAP = {
    "1bc83d0d8579daff7788f773080d8feab439221dff4d8fb874900c8fee9611a2": "T5ugK0KM8OvTnW5p7ooEsYyyKyCI0ePYomNXpVLxNw4=",
}


def fail(msg):
    print("gen-xb FAIL:", msg)
    sys.exit(1)


def b64d(raw):
    raw = raw.strip()
    return base64.b64decode(raw + b"=" * (-len(raw) % 4)).decode("utf-8")


def ip_of(host):
    if host.replace(".", "").isdigit():
        return host
    if host in IP_MAP:
        return IP_MAP[host]
    try:
        return socket.gethostbyname(host)
    except Exception:
        fail("cannot resolve a node host (not in IP_MAP)")


s_path, out_x = sys.argv[1:3]
try:
    txt = b64d(open(s_path, "rb").read())
except Exception:
    fail("s is not base64/utf-8")
lines = [l.strip() for l in txt.splitlines() if l.strip()]
if not lines:
    fail("s has no links")

x_lines, nodes, tags, kinds = [], [], [], []
for i, l in enumerate(lines, 1):
    u = urllib.parse.urlsplit(l)
    sch = u.scheme.lower()
    try:
        port = u.port
    except ValueError:
        fail(f"link {i}: bad port")
    if not u.hostname or not port:
        fail(f"link {i}: missing host/port")
    tag = urllib.parse.unquote(u.fragment) or f"node{i}"
    if tag in tags:
        fail(f"link {i}: duplicate name")
    q = urllib.parse.parse_qs(u.query)
    frag = u.fragment
    user = u.username or ""
    if sch in ("hysteria2", "hy2"):
        pw = urllib.parse.unquote(user)
        if not pw:
            fail(f"link {i} hy2: missing password")
        pin_hex = (q.get("pinSHA256") or [""])[0].replace(":", "").lower()
        if pin_hex and pin_hex not in PIN_MAP:
            fail(f"link {i} hy2: cert pin changed, PIN_MAP needs the new SPKI (ask Muse)")
        spki = PIN_MAP.get(pin_hex)
        if not spki:
            fail(f"link {i} hy2: no pinSHA256 in s")
        sni = (q.get("sni") or [""])[0]
        xq = f"pinSHA256={urllib.parse.quote(spki, safe='')}" + (f"&sni={sni}" if sni else "")
        x_lines.append(f"hysteria2://{user}@{ip_of(u.hostname)}:{port}?{xq}#{frag}")
        tls = {"enabled": True, "insecure": True}
        if sni:
            tls["server_name"] = sni
        ob = {"password": pw, "server": u.hostname, "server_port": port, "tag": tag, "tls": tls, "type": "hysteria2"}
        mport = (q.get("mport") or [""])[0]
        if mport:
            ob["server_ports"] = [p.strip().replace("-", ":") for p in mport.split(",") if p.strip()]
        nodes.append(ob)
        kinds.append("hy2" + ("+hop" if mport else ""))
    elif sch == "ss":
        ui = urllib.parse.unquote(user)
        try:
            dec = base64.urlsafe_b64decode(ui + "=" * (-len(ui) % 4)).decode()
        except Exception:
            dec = ui
        if ":" not in dec:
            fail(f"link {i} ss: bad userinfo")
        method, pw = dec.split(":", 1)
        if not method or not pw:
            fail(f"link {i} ss: missing method/password")
        x_lines.append(f"ss://{user}@{ip_of(u.hostname)}:{port}?#{frag}")
        nodes.append({"method": method, "password": pw, "server": u.hostname, "server_port": port, "tag": tag, "type": "shadowsocks"})
        kinds.append("ss")
    else:
        fail(f"link {i}: unsupported scheme for generator")
    tags.append(tag)

with open(out_x, "wb") as f:
    f.write(base64.b64encode(("\n".join(x_lines) + "\n").encode()))
print("gen-xb ok:", len(lines), "nodes", ",".join(kinds))
