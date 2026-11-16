"""Unit 36: V1 and V2 derived from the retired Database.java, never retyped.

python3 -I harness/mkv.py DATABASE_JAVA v1|v2   prints the migration file's text: V1 = Database's CREATE statements (its text
blocks and strings, in order, dedented, each ended by ';'), V2 = its seed (the four customers in the seed's order, one INSERT
each; the two pauses by name). Each file starts with one comment line, this script's own. The receipt compares the output with
after/'s db/migration files byte for byte.
"""
import re
import sys
import textwrap

src = open(sys.argv[1], encoding="utf-8").read()
what = sys.argv[2]
if what == "v1":
    stmts = []
    for m in re.finditer(r'st\.execute\((?:"""\n(.*?)"""|"([^"]*)")\);', src, re.S):
        s = textwrap.dedent(m.group(1)).rstrip() if m.group(1) is not None else m.group(2)
        if s.startswith("DROP "):
            continue
        stmts.append(s + ";")
    print("-- TiffinBox's schema, as the retired Database class created it (Course 7 units 06, 27 and 34): the two tables, the version column, the index.")
    print("\n".join(stmts))
elif what == "v2":
    ins = re.search(r'"(INSERT INTO customer \([^)]*\)) VALUES \(\?, \?, \?, \?\)"', src).group(1)
    cust = re.findall(r'new Customer\("([A-Za-z]+)", (\d+), (\d+), "([A-Z_]+)"\)', src)
    pins = re.search(r'"(INSERT INTO pause \(customer_id, days\)) SELECT id, \? FROM customer WHERE name = \?"', src).group(1)
    pauses = re.findall(r'ps\.setInt\(1, (\d+)\);\s*ps\.setString\(2, "([A-Za-z]+)"\);', src)
    print("-- The four customers and two pauses the retired Database class seeded at every start - now once per database.")
    for n, m, p, t in cust:
        print(f"{ins} VALUES ('{n}', {m}, {p}, '{t}');")
    for d, n in pauses:
        print(f"{pins} SELECT id, {d} FROM customer WHERE name = '{n}';")
else:
    sys.exit("v1 or v2")
