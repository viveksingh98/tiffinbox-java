"""Course 9 unit 15's exercise: the harness's client of the harness's member route (Python urllib, loopback only).
Usage: python3 client.py PORT. As shipped it writes the member's path in; your turn is to make it follow the entry point's link."""
import json
import sys
import urllib.error
import urllib.request

port = sys.argv[1]
B = "http://127.0.0.1:" + port


def get(url):
    req = urllib.request.Request(url, headers={"Accept": "application/hal+json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        return e.code, None


status, body = get(B + "/probe/people/Ravi")   # the member's path, written in
print("the member -> %d" % status)
if status != 200:
    sys.exit(1)
print(body["name"])
