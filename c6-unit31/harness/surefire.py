"""The course's harness: Surefire's reports, read. surefire.py DIR prints, for every TEST-*.xml in DIR (sorted by name), the suite's
counts - tests, failures, errors, skipped, read off the testsuite element - and each test case: passed, FAILED (an assertion) or
ERROR (an exception), with the failure's type and the first two lines of its message (stack frames and blank lines dropped; the
other lines counted, "over 40" past forty), then each distinct "Caused by:" line of its trace, in the order they first appear, up
to six. An object's identity hash (@1a2b3c…) becomes "@…"; a line over 200 characters is cut there, the rest counted. No time is printed, and of the fork's system properties the reports hold
(paths among them) two: user.language and user.country, from each report, and whether every report agrees. With no report in DIR it says so."""
import glob
import os
import re
import sys
import xml.etree.ElementTree as ET

def mask(l):
    l = re.sub(r"@[0-9a-f]{4,}", "@…", l)
    return l if len(l) <= 200 else l[:200] + " … (%d more characters)" % (len(l) - 200)


d = sys.argv[1]
files = sorted(glob.glob(os.path.join(d, "TEST-*.xml")))
if not files:
    print("  Surefire's reports: none (no TEST-*.xml in %s)" % os.path.basename(d.rstrip("/")))
    sys.exit(0)
tot = [0, 0, 0, 0]
locs = []
for f in files:
    s = ET.parse(f).getroot()
    pr = {q.get("name"): q.get("value") for q in s.iter("property")}
    locs.append("user.language %s · user.country %s" % (pr.get("user.language"), pr.get("user.country")))
    c = [int(s.get(k, "0")) for k in ("tests", "failures", "errors", "skipped")]
    tot = [a + b for a, b in zip(tot, c)]
    print("  %s: tests %d · failures %d · errors %d · skipped %d" % (os.path.basename(f), c[0], c[1], c[2], c[3]))
    for tc in s.findall("testcase"):
        bad = None
        for kind, word in (("failure", "FAILED"), ("error", "ERROR")):
            e = tc.find(kind)
            if e is not None:
                bad = (word, e)
                break
        if tc.find("skipped") is not None:
            print("    skipped %s" % tc.get("name"))
            continue
        if bad is None:
            print("    passed  %s" % tc.get("name"))
            continue
        word, e = bad
        lines = [l.strip() for l in (e.get("message") or "").splitlines()]
        keep = [l for l in lines if l and not l.startswith("at ")]
        print("    %s  %s - %s" % (word, tc.get("name") or "(the class: no test method ran)", e.get("type")))
        for l in keep[:2]:
            print("      %s" % mask(l))
        cut = len(keep) - len(keep[:2])
        if cut:
            print("      (its message's other lines: %s - not shown)" % ("over 40" if cut > 40 else cut))
        causes = []
        for l in (e.text or "").splitlines():
            l = l.strip()
            if l.startswith("Caused by: ") and mask(l) not in causes:
                causes.append(mask(l))
        for c in causes[:6]:
            print("      %s" % c)
        if len(causes) > 6:
            print("      (other distinct Caused by lines: %d - not shown)" % (len(causes) - 6))
print("  the fork's locale, read from the reports' properties: %s · the same in every report: %s" % (locs[0], "yes" if len(set(locs)) == 1 else "no"))
print("  in all: %d reports · tests %d · failures %d · errors %d · skipped %d" % (len(files), tot[0], tot[1], tot[2], tot[3]))
