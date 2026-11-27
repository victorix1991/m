// Encrypted report to the status hub (AES-256-GCM, AAD src|ts|nonce). Muse 2026-11-23.
// Usage: RK=<base64 key in env> [SRC=gh|muse|...] node hub_report.js <job> <ok|fail> [note] [dur_s]
// SRC must be a key of hub's REPORT_SRCS and select hub's RK_<SRC> secret; defaults to gh.
// Never prints the key; never fails the caller (exit 0 always).
const c = require("crypto");
const https = require("https");
const [job, res, note = "", dur = ""] = process.argv.slice(2);
const raw = process.env.RK || "";
const SRC = /^[a-z][a-z0-9]{1,15}$/.test(process.env.SRC || "") ? process.env.SRC : "gh";
if (!raw) { console.log("hub report skipped (no key)"); process.exit(0); }
try {
  const k = Buffer.from(raw, "base64");
  const ts = Math.floor(Date.now() / 1000), n = c.randomBytes(16).toString("hex"), iv = c.randomBytes(12);
  const d = { kind: "job", job, result: res === "ok" ? "ok" : "fail", note: String(note).slice(0, 200) };
  if (dur !== "" && isFinite(+dur)) d.dur_s = +dur;
  const ci = c.createCipheriv("aes-256-gcm", k, iv);
  ci.setAAD(Buffer.from(SRC + "|" + ts + "|" + n));
  const ct = Buffer.concat([ci.update(JSON.stringify(d)), ci.final(), ci.getAuthTag()]);
  const body = JSON.stringify({ src: SRC, ts, nonce: n, iv: iv.toString("base64"), ct: ct.toString("base64") });
  const r = https.request("https://status.xlat.kdns.fr/api/report", { method: "POST", timeout: 10000, headers: { "content-type": "application/json" } },
    (x) => { console.log("hub", x.statusCode); x.resume(); });
  r.on("error", () => console.log("hub error")); r.on("timeout", () => r.destroy());
  r.end(body);
} catch (e) { console.log("hub report error"); }
