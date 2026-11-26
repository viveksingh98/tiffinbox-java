"""THE HARNESS'S CLIENTS (Course 9 unit 15; the probe's follow.py with a named diff): two clients of one server - the harness's
written-path client (the path written in) and the harness's link follower (reads the entry point's link and sends that).
Usage: follow.py PORT LABEL  (loopback only). Python urllib; no HTTP-client claim. Ports masked in what it prints."""
import json
import re
import sys
import urllib.error
import urllib.request

port, label = sys.argv[1], sys.argv[2]
B = f"http://127.0.0.1:{port}"


def get(url):
    req = urllib.request.Request(url, headers={"Accept": "application/hal+json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return r.status, r.headers.get("Content-Type"), r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.headers.get("Content-Type"), e.read()


def members(raw):
    try:
        d = json.loads(raw)
    except Exception:
        return "not JSON (%d B)" % len(raw)
    return "members %s · name=%s" % (list(d), d.get("name"))


def mask(s):
    return re.sub(r':[0-9]{4,5}', ':<port>', s)


s1, t1, b1 = get(B + "/probe/people/Ravi")
print(f"{label} · written-path client GET /probe/people/Ravi -> {s1} {t1} · {members(b1)}")
s0, t0, b0 = get(B + "/probe/entry")
href = json.loads(b0)["_links"]["ravi"]["href"]
s2, t2, b2 = get(href)
print(f"{label} · link-following client GET /probe/entry -> {s0}, its link 'ravi' -> {mask(href)} -> {s2} {t2} · {members(b2)}")
