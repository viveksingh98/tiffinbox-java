#!/usr/bin/env python3
"""table.py - the course's harness, never TiffinBox's: it reads one answer of Boot's Actuator from its standard input and prints
it for a person. curl fetches; this only reads. Keys are sorted (Jackson 2 and Jackson 3 order them differently).

  python3 harness/table.py               the routing table (/actuator/mappings): its contexts and kinds, every row, the counts
  python3 harness/table.py count         the same table's counts, on one line
  python3 harness/table.py row PATH ...  each row whose pattern is PATH, with every key the table gives it - nothing cut
  python3 harness/table.py links         the names of the links /actuator answers with
  python3 harness/table.py tiffinbox     TiffinBox's own rows, counted, and the verbs the table gives them

The table prints a row as "pattern -> handler", in the table's order - except that a run of rows with details (a
RequestMappingInfo's) is sorted by pattern: the table gives those in a hash's order, which moves from run to run. Two cuts, both declared and counted where they happen: a "produces [a || b
|| c]" list keeps its first type ("produces [a … 2 more]"), and a Java class name before "#" keeps its last part
("BasicErrorController#error(HttpServletRequest)"). "row" prints every key whole. An answer that is not a routing table (an
error body, say) is named by its status - never printed: Spring's error body carries a timestamp."""
import json
import re
import sys


def load():
    try:
        return json.loads(sys.stdin.buffer.read().decode("utf-8"))
    except ValueError:
        return None


def not_a_table(d):
    """A line for an answer that holds no routing table, or None when it holds one."""
    if not isinstance(d, dict):
        return "not a routing table: the answer is not JSON"
    if "contexts" not in d:
        return "not a routing table: status %s" % d.get("status", "unknown")
    return None


def patterns(row):
    return ((row.get("details") or {}).get("requestMappingConditions") or {}).get("patterns") or []


def rows_of(ctx):
    """[(servlet, row)] for the dispatcherServlets kind: each servlet's rows in the table's own order, except that a run of
    consecutive rows with details (a RequestMappingInfo's: Actuator's, /error's) is sorted by its patterns, then its predicate -
    the table gives those in the order of a hash that moves from run to run (measured: two runs, two orders)."""
    out = []
    for servlet, rows in sorted(ctx.get("mappings", {}).get("dispatcherServlets", {}).items()):
        done, run = [], []
        for r in rows + [None]:
            if r is not None and r.get("details"):
                run.append(r)
                continue
            done.extend(sorted(run, key=lambda x: (" ".join(patterns(x)), x.get("predicate", ""))))
            run = []
            if r is not None:
                done.append(r)
        out.extend((servlet, r) for r in done)
    return out


def cut_produces(p):
    def one(m):
        types = [t.strip() for t in m.group(1).split("||")]
        return "produces [%s%s]" % (types[0], "" if len(types) == 1 else " … %d more" % (len(types) - 1))
    return re.sub(r"produces \[([^\]]*)\]", one, p)


def cut_class(h):
    head, sep, tail = h.partition("#")
    return (head.rsplit(".", 1)[-1] + sep + tail) if sep and "." in head and " " not in head else h


def verbs(row):
    return ((row.get("details") or {}).get("requestMappingConditions") or {}).get("methods") or []


def tiffinbox_rows(rows):
    return [r for _, r in rows if str(r.get("handler", "")).startswith("TiffinBox route ")]


def counts(rows):
    det = sum(1 for _, r in rows if r.get("details"))
    vb = [v for _, r in rows for v in verbs(r)]
    tb = tiffinbox_rows(rows)
    named = sum(1 for r in tb if re.fullmatch(r"TiffinBox route /[a-z]+", r.get("handler", "")) and r.get("predicate") == r["handler"][len("TiffinBox route "):])
    lam = sum(1 for _, r in rows if "$$Lambda" in str(r.get("handler", "")))
    by = " ".join("%s %d" % (v, vb.count(v)) for v in sorted(set(vb)))
    return ["rows with details: %d · without: %d · naming a verb: %d%s"
            % (det, len(rows) - det, sum(1 for _, r in rows if verbs(r)), " (%s)" % by if by else ""),
            "TiffinBox's rows (a handler named \"TiffinBox route /…\"): %d · each named for its own path: %d · a lambda's name ($$Lambda): %d"
            % (len(tb), named, lam)]


def head_line(name, ctx):
    kinds = sorted(ctx.get("mappings", {}))
    return "contexts: 1 (%s) · kinds: %d%s" % (name, len(kinds), " (%s)" % " ".join(kinds) if kinds else "")


def table(d):
    for name, ctx in sorted(d["contexts"].items()):
        print("  " + head_line(name, ctx))
        m = ctx.get("mappings", {})
        rows = rows_of(ctx)
        cut_p = sum(1 for _, r in rows if cut_produces(r.get("predicate", "")) != r.get("predicate", ""))
        cut_h = sum(1 for _, r in rows if cut_class(r.get("handler", "")) != r.get("handler", ""))
        for servlet in sorted(m.get("dispatcherServlets", {})):
            rs = [r for s_, r in rows if s_ == servlet]
            print("  dispatcherServlets · %s: %d rows, in the table's order - a run of rows with details sorted by pattern"
                  " (produces lists cut: %d · class names cut to their last part: %d)" % (servlet, len(rs), cut_p, cut_h))
            for i, r in enumerate(rs, 1):
                print("  %3d  %s -> %s" % (i, cut_produces(r.get("predicate", "")), cut_class(r.get("handler", ""))))
        if rows:
            for l in counts(rows):
                print("  " + l)
        if "servletFilters" in m:
            fs = m["servletFilters"]
            print("  servletFilters: %d, by name: %s · on /* : %d" % (len(fs), ", ".join(sorted((f["name"] for f in fs), key=str.lower)),
                  sum(1 for f in fs if f.get("urlPatternMappings") == ["/*"])))
        if "servlets" in m:
            ss = m["servlets"]
            print("  servlets: %d · %s" % (len(ss), ", ".join("%s on %s" % (s["name"], " ".join(s.get("mappings", []))) for s in ss)))


def count(d):
    for name, ctx in sorted(d["contexts"].items()):
        m = ctx.get("mappings", {})
        parts = ["%s %d" % (s, len(rs)) for s, rs in sorted(m.get("dispatcherServlets", {}).items())]
        parts += ["%s %d" % (k, len(m[k])) for k in ("servletFilters", "servlets") if k in m]
        print("  " + head_line(name, ctx) + (" · rows: " + ", ".join(parts) if parts else ""))


def flat(prefix, v, out):
    if isinstance(v, dict):
        for k in sorted(v):
            flat("%s.%s" % (prefix, k) if prefix else k, v[k], out)
    elif isinstance(v, list) and any(isinstance(x, (dict, list)) for x in v):
        for i, x in enumerate(v):
            flat("%s[%d]" % (prefix, i), x, out)
    else:
        out.append("%s = %s" % (prefix, json.dumps(v) if isinstance(v, list) else ("null" if v is None else str(v).lower() if isinstance(v, bool) else v)))


def row(d, paths):
    for name, ctx in sorted(d["contexts"].items()):
        rows = rows_of(ctx)
        for p in paths:
            hit = [r for _, r in rows if r.get("predicate") == p or p in patterns(r)]
            print("  the row for %s: %d" % (p, len(hit)))
            for r in hit:
                out = []
                flat("", r, out)
                print("  %s - %d keys: %s" % (p, len(r), " ".join(sorted(r))))
                for l in out:
                    print("    " + l)


def main(argv):
    d = load()
    mode = argv[1] if len(argv) > 1 else "table"
    if mode == "links":
        links = (d or {}).get("_links") if isinstance(d, dict) else None
        print("  the links: " + (" ".join(sorted(links)) if links else "none - status %s" % ((d or {}).get("status", "unknown") if isinstance(d, dict) else "unknown")))
        return 0
    bad = not_a_table(d)
    if mode == "tiffinbox":
        if bad:
            print("TiffinBox's rows: 0 · %s" % bad)
            return 0
        tb = [r for _, ctx in sorted(d["contexts"].items()) for r in tiffinbox_rows(rows_of(ctx))]
        vb = sorted({v for r in tb for v in verbs(r)})
        print("TiffinBox's rows: %d · the verbs the table gives them: %s" % (len(tb), " ".join(vb) if vb else "none"))
        return 0
    if bad:
        print("  " + bad)
        return 0
    if mode == "table":
        table(d)
    elif mode == "count":
        count(d)
    elif mode == "row":
        row(d, argv[2:])
    else:
        print("table.py: no such mode: %s" % mode)
        return 2
    return 0


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")   # its own lines hold "·" and "…", whatever your locale
    sys.exit(main(sys.argv))
