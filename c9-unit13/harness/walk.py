"""THE HARNESS (Course 9 unit 13; the S3 probe's walk.py with a named diff): a reader walks in pages of 5 while 2 rows are inserted
between page 1 and page 2 - offset (the harness's offset route) and cursor (TiffinBox's /api/v1/orders), newest first or oldest first.
Prints duplicates, skips over the rows present at the start only, and new rows seen. One walk per JVM (a fresh database each).
Usage: walk.py PORT LABEL SORT MODE   (loopback only)"""
import json
import sys
import urllib.request

port, label, SORT, MODE = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
B = f"http://127.0.0.1:{port}"


def get(path):
    with urllib.request.urlopen(B + path, timeout=10) as r:
        return json.load(r)


def post(path):
    req = urllib.request.Request(B + path, data=b"", method="POST")
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)


def baseline(sort):
    return [i["id"] for i in get(f"/probe/u13/orders/by-page?sort={sort}&page=0&size=1000")["items"]]


def walk(sort, mode):
    before = baseline(sort)
    seen, pages, inserted = [], [], []
    if mode == "offset":
        page = 0
        while True:
            d = get(f"/probe/u13/orders/by-page?sort={sort}&page={page}&size=5")
            ids = [i["id"] for i in d["items"]]
            if not ids:
                break
            pages.append(ids); seen += ids
            if page == 0:
                inserted = post("/probe/u13/orders?n=2")["inserted"]
            page += 1
    else:
        cur = None
        while True:
            q = f"/api/v1/orders?sort={sort}&size=5" + (f"&cursor={cur}" if cur else "")
            d = get(q)
            ids = [i["id"] for i in d["items"]]
            if ids:
                pages.append(ids); seen += ids
            if len(pages) == 1 and not inserted:
                inserted = post("/probe/u13/orders?n=2")["inserted"]
            cur = d["next"]
            if not cur:
                break
    dups = sorted({i for i in seen if seen.count(i) > 1})
    skips = [i for i in before if i not in seen]
    new_seen = [i for i in inserted if i in seen]
    print(f"{label} sort={sort:6s} mode={mode:6s} rows-before={len(before)} pages={len(pages)} read={len(seen)} "
          f"duplicates={len(dups)} {dups} skips={len(skips)} {skips} inserted={inserted} new-rows-seen={len(new_seen)}")
    print(f"   pages: {pages}")


walk(SORT, MODE)
