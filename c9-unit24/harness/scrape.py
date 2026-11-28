"""Course 9 unit 23's scrape reader (python3 -I harness/scrape.py MODE FILE...): reads the text /actuator/prometheus answered and prints
only what the unit may say. No value of a duration line is ever printed (R.552, D10): every line that is not an
http_server_requests_seconds_count line keeps its metric name and label set, its value becomes <v>.
MODE mask FILE      the masked scrape (the filed form): # HELP / # TYPE lines kept, _count lines kept whole, every other value <v>
MODE families FILE  one line per family: name · TYPE word · number of series lines (http_server_requests* first)
MODE rows FILE      the http_server_requests_seconds_count rows: method status outcome uri error exception count (sorted)
MODE buckets FILE   the number of lines whose metric name ends in _bucket
MODE diff A B       the _count rows of B that A does not hold, or holds with another count (added / changed)
MODE selftest       the mask and the bucket count on planted lines; exits 1 if either is wrong
Any line it cannot parse is a FAIL line and exit 1, never a traceback."""
import re, sys

LINE = re.compile(r'^([a-zA-Z_:][a-zA-Z0-9_:]*)(\{(.*)\})? (\S+)( \S+)?$')
LAB = re.compile(r'([a-zA-Z_][a-zA-Z0-9_]*)="((?:[^"\\]|\\.)*)"')
COUNT = "http_server_requests_seconds_count"


def parse(text):
    out = []
    for n, l in enumerate(text.splitlines(), 1):
        if not l.strip() or l.startswith("#"):
            out.append(("#", l, None, None)); continue
        m = LINE.match(l)
        if not m:
            print("FAIL scrape.py: line %d cannot be parsed: %r" % (n, l[:80])); sys.exit(1)
        out.append((m.group(1), l, dict(LAB.findall(m.group(3) or "")), m.group(4)))
    return out


def mask(text):
    res = []
    for name, l, labels, v in parse(text):
        if name == "#":
            if l.startswith("# HELP") or l.startswith("# TYPE"): res.append(l)
            continue
        if name == COUNT:
            res.append(l); continue
        res.append(l[: len(l) - len(l.split(" ")[-1])] + "<v>" if " " in l else l)
    return "\n".join(res) + "\n"


def rows(text):
    r = []
    for name, l, labels, v in parse(text):
        if name != COUNT: continue
        try:
            c = int(float(v))
        except ValueError:
            print("FAIL scrape.py: a _count value is not a number: %r" % l[:80]); sys.exit(1)
        r.append((labels.get("method", "?"), labels.get("status", "?"), labels.get("outcome", "?"), labels.get("uri", "?"),
                  labels.get("error", "?"), labels.get("exception", "?"), c, tuple(sorted(labels))))
    return sorted(r)


def families(text):
    fam, order = {}, []
    for name, l, labels, v in parse(text):
        if name == "#":
            m = re.match(r"^# TYPE (\S+) (\S+)", l)
            if m:
                fam.setdefault(m.group(1), [m.group(2), 0]); order.append(m.group(1))
            continue
        base = name
        for suf in ("_count", "_sum", "_max", "_bucket", "_total", "_created"):
            if name.endswith(suf) and name[: -len(suf)] in fam: base = name[: -len(suf)]; break
        fam.setdefault(base, ["(no TYPE)", 0]); fam[base][1] += 1
        if base not in order: order.append(base)
    return [(k, fam[k][0], fam[k][1]) for k in sorted(order, key=lambda k: (not k.startswith("http_server_requests"), k))]


def buckets(text):
    return sum(1 for name, l, labels, v in parse(text) if name != "#" and name.endswith("_bucket"))


def selftest():
    t = ('# HELP http_server_requests_seconds  \n# TYPE http_server_requests_seconds summary\n'
         'http_server_requests_seconds_count{method="GET",status="200",uri="/x"} 3\n'
         'http_server_requests_seconds_sum{method="GET",status="200",uri="/x"} 0.0123\n'
         'http_server_requests_seconds_max{method="GET",status="200",uri="/x"} 0.004\n'
         'application_ready_time_seconds{main_application_class="a.B"} 4.381\n')
    m = mask(t)
    ok1 = "0.0123" not in m and "0.004" not in m and "4.381" not in m and 'uri="/x"} 3' in m and m.count("<v>") == 3
    ok2 = buckets(t) == 0 and buckets(t + 'http_server_requests_seconds_bucket{le="0.1",uri="/x"} 1\n') == 1
    left = mask(t).replace("<v>", "0.0123", 1)   # the plant: a _sum value left in a filed text
    ok3 = re.search(r"_(sum|max)\{[^}]*\} [0-9]", left) is not None
    print("scrape.py self-test: the mask hides the _sum, _max and start-time values and keeps the _count (%s) · a planted _bucket line counted 1, none in the plain text (%s) · a _sum value left in a filed text is found by the static pattern (%s)"
          % ("ok" if ok1 else "FAIL", "ok" if ok2 else "FAIL", "ok" if ok3 else "FAIL"))
    sys.exit(0 if ok1 and ok2 and ok3 else 1)


def main():
    a = sys.argv[1:]
    if not a: print("FAIL scrape.py: no mode"); sys.exit(1)
    if a[0] == "selftest": selftest()
    if a[0] == "diff":
        A = {r[:6]: r[6] for r in rows(open(a[1], encoding="utf-8").read())}
        for r in rows(open(a[2], encoding="utf-8").read()):
            k = r[:6]
            if k not in A: print("added   %s %s %s %s · count %d" % (k[0], k[1], k[2], k[3], r[6]))
            elif A[k] != r[6]: print("changed %s %s %s %s · count %d -> %d" % (k[0], k[1], k[2], k[3], A[k], r[6]))
        return
    t = open(a[1], encoding="utf-8").read()
    if not t.strip(): print("FAIL scrape.py: %s is empty (R.564)" % a[1]); sys.exit(1)
    if a[0] == "mask": sys.stdout.write(mask(t))
    elif a[0] == "rows":
        for r in rows(t): print("%s %s %s %s error=%s exception=%s count=%d keys=%s" % (r[0], r[1], r[2], r[3], r[4], r[5], r[6], ",".join(r[7])))
    elif a[0] == "families":
        for f in families(t): print("%s · %s · %d" % f)
    elif a[0] == "buckets": print(buckets(t))
    else: print("FAIL scrape.py: unknown mode %r" % a[0]); sys.exit(1)


main()
