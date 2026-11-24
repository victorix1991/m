#!/bin/bash
# Muse 2026-11-24: startup test for b. `sing-box check` misses runtime errors (e.g. "detour to an
# empty direct outbound"), so start the config for 6s with tun swapped for a local mixed inbound.
# Fail on any FATAL except remote rule-set download (network noise, not a config error).
python3 - "$1" /tmp/r.json <<'EOF' || exit 1
import json, sys
c = json.load(open(sys.argv[1]))
c["inbounds"] = [{"type": "mixed", "tag": "t", "listen": "127.0.0.1", "listen_port": 17890}]
c["log"] = {"level": "warn"}
json.dump(c, open(sys.argv[2], "w"))
EOF
timeout 6 sing-box run -c /tmp/r.json >/tmp/r.log 2>&1
if grep FATAL /tmp/r.log | grep -v "initial rule-set" | grep -q .; then grep FATAL /tmp/r.log | cut -c1-200; rm -f /tmp/r.json /tmp/r.log; exit 1; fi
rm -f /tmp/r.json /tmp/r.log
exit 0
