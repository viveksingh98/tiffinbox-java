#!/usr/bin/env python3
# sql.py FILE...: the SQL a Java source file writes by hand. The file is read as Java's own tokens would split it - a // or /* */
# comment is skipped, a "string literal" and a """text block""" are each one string - and a string counts as SQL when its text
# starts with an SQL statement's first word (SELECT, INSERT, UPDATE, DELETE, MERGE, CREATE, DROP, ALTER). Prints, per file: its
# name and the count; then each statement, its whitespace collapsed, in the file's order; then the tables a CREATE TABLE names.
import re, sys
KW = re.compile(r"(SELECT|INSERT|UPDATE|DELETE|MERGE|CREATE|DROP|ALTER)\b")
def strings(src):
    out, i, n = [], 0, len(src)
    while i < n:
        if src.startswith("//", i):
            j = src.find("\n", i); i = n if j < 0 else j
        elif src.startswith("/*", i):
            j = src.find("*/", i + 2); i = n if j < 0 else j + 2
        elif src.startswith('"""', i):
            j = src.find('"""', i + 3); out.append(src[i + 3:j]); i = j + 3
        elif src[i] == '"':
            j = i + 1
            while src[j] != '"':
                j += 2 if src[j] == "\\" else 1
            out.append(src[i + 1:j]); i = j + 1
        elif src[i] == "'":
            j = i + 1
            while src[j] != "'":
                j += 2 if src[j] == "\\" else 1
            i = j + 1
        else:
            i += 1
    return out
for f in sys.argv[1:]:
    sql = [re.sub(r"\s+", " ", s).strip() for s in strings(open(f, encoding="utf-8").read())]
    sql = [s for s in sql if KW.match(s)]
    tables = [m.group(1) for s in sql for m in [re.match(r"CREATE TABLE (?:IF NOT EXISTS )?(\w+)", s)] if m]
    print(f"{f.rsplit('/', 1)[-1]}: {len(sql)} SQL strings")
    for s in sql: print(f"  {s}")
    print(f"  the tables its CREATE TABLE strings make: {len(tables)}{' - ' + ', '.join(tables) if tables else ''}")
