#!/usr/bin/env python3
"""Validate the L×Box subscription file `x` (base64 of share links). Muse 2026-11-23.
Prints only counts / field names, NEVER the file contents (public repo logs).
Usage: check_x.py <file> [sing-box-config-out.json]
Exit 0 = valid, 1 = invalid.
"""
import base64, json, sys, urllib.parse

def fail(msg):
    print("x-check FAIL:", msg); sys.exit(1)

raw = open(sys.argv[1], "rb").read().strip()
if not raw:
    fail("empty file")
try:
    txt = base64.b64decode(raw + b"=" * (-len(raw) % 4), validate=False).decode("utf-8")
except Exception:
    fail("not base64/utf-8")
lines = [l.strip() for l in txt.splitlines() if l.strip()]
if not lines:
    fail("no links")
obs, kinds = [], []
for i, l in enumerate(lines, 1):
    u = urllib.parse.urlsplit(l)
    sch = u.scheme.lower()
    try:
        port = u.port
    except ValueError:
        fail(f"link {i}: bad port")
    if not u.hostname or not port:
        fail(f"link {i}: missing host/port")
    q = urllib.parse.parse_qs(u.query)
    tag = f"n{i}"
    if sch in ("hysteria2", "hy2"):
        pw = urllib.parse.unquote(u.username or "")
        if not pw:
            fail(f"link {i} hy2: missing password")
        pin = (q.get("pinSHA256") or q.get("pinsha256") or [""])[0]
        if not pin:
            fail(f"link {i} hy2: missing pinSHA256")
        try:
            if len(base64.b64decode(pin)) != 32:
                raise ValueError
        except Exception:
            fail(f"link {i} hy2: pinSHA256 not 32-byte base64")
        tls = {"enabled": True, "insecure": False, "certificate_public_key_sha256": [pin]}
        sni = (q.get("sni") or [""])[0]
        if sni:
            tls["server_name"] = sni
        obs.append({"type": "hysteria2", "tag": tag, "server": u.hostname, "server_port": port, "password": pw, "tls": tls})
        kinds.append("hy2")
    elif sch == "ss":
        ui = urllib.parse.unquote(u.username or "")
        try:
            dec = base64.urlsafe_b64decode(ui + "=" * (-len(ui) % 4)).decode()
        except Exception:
            dec = ui
        if ":" not in dec:
            fail(f"link {i} ss: bad userinfo")
        method, pw = dec.split(":", 1)
        if not method or not pw:
            fail(f"link {i} ss: missing method/password")
        obs.append({"type": "shadowsocks", "tag": tag, "server": u.hostname, "server_port": port, "method": method, "password": pw})
        kinds.append("ss")
    else:
        fail(f"link {i}: unsupported scheme {sch[:12]}")
cfg = {"log": {"level": "warn"}, "outbounds": obs + [{"type": "direct", "tag": "direct"}],
       "route": {"final": obs[0]["tag"]}}
if len(sys.argv) > 2:
    with open(sys.argv[2], "w") as f:
        json.dump(cfg, f)
print("x-check parse ok:", len(lines), "links", ",".join(kinds))
