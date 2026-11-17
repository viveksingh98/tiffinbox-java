"""Unit 07's harness copies, derived from the shipped files at run time - never typed copies (python3 -I -B harness/variants.py TREE).
TREE is a copy of after/; each variant is written into TREE's test sources beside the shipped IT, each a rename of the shipped IT plus
the named change, and each asserted to differ from its source by exactly that change (else exit 1, nothing written):
  slice/JdbcSliceNoQ           JdbcSlice without @Import(JdbcNames.class) (and its two import lines)
  NoServiceConnectionIT        the shipped IT, @ServiceConnection removed, @Container kept           (nocontainer, the exercise's broken state)
  NoServiceConnectionNoQIT     the same, started from JdbcSliceNoQ                                    (nocontainer, H2 without Q)
  NoQIT                        the shipped IT started from JdbcSliceNoQ, @ServiceConnection kept      (nocontainer, PostgreSQL without Q)
  WrongSliceIT                 the shipped IT started from Spring Data JPA's DataSlice                (wrongslice)
  AfterTheClassIT              the shipped IT plus an @AfterAll hook: a JdbcTemplate of its own on the container, after the class (sql)
It prints each file's added and removed lines (diff-style, < removed, > added)."""
import difflib, os, sys
tree = sys.argv[1]
T = os.path.join(tree, "tiffinbox-web/src/test/java")
IT = open(os.path.join(T, "com/tiffinbox/jdbc/CustomerAggregatesIT.java"), encoding="utf-8").read()
SL = open(os.path.join(T, "slice/JdbcSlice.java"), encoding="utf-8").read()


def one(src, old, new):
    assert src.count(old) == 1, "the shipped line moved: " + old.strip()
    return src.replace(old, new)


def rename(src, name):
    return one(src, "class CustomerAggregatesIT {", "class %s {" % name)


def noq_slice(src):
    s = one(src, "import com.tiffinbox.jdbc.JdbcNames;\n", "")
    s = one(s, "import org.springframework.context.annotation.Import;\n", "")
    s = one(s, "@Import(JdbcNames.class)\n", "")
    return one(s, "public class JdbcSlice {", "public class JdbcSliceNoQ {")


def slice_to(src, name):
    s = one(src, "import slice.JdbcSlice;", "import slice.%s;" % name)
    s = one(s, "@ContextConfiguration(classes = JdbcSlice.class)", "@ContextConfiguration(classes = %s.class)" % name)
    return one(s, " · \" + JdbcSlice.class.getName());", " · \" + %s.class.getName());" % name)


nosc = lambda s: one(s, "    @Container\n    @ServiceConnection\n", "    @Container\n")
AFTER = '''
    /** Harness only: after the class, a JdbcTemplate of its own on the container - no test transaction left to roll back. */
    @org.junit.jupiter.api.AfterAll
    static void afterTheClass() {
        var after = new JdbcTemplate(new org.springframework.jdbc.datasource.DriverManagerDataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword()));
        System.out.println("JDBC IT after the class, a JdbcTemplate of its own on the container: customers " + after.queryForObject("select count(*) from customer", Integer.class)
                + " · Kavya " + after.queryForObject("select count(*) from customer where name = 'Kavya'", Integer.class));
    }
}
'''
assert IT.endswith("\n}\n"), "the shipped IT's last line moved"
out = {
    "slice/JdbcSliceNoQ.java": (SL, noq_slice(SL), 4),
    "com/tiffinbox/jdbc/NoServiceConnectionIT.java": (IT, rename(nosc(IT), "NoServiceConnectionIT"), 2),
    "com/tiffinbox/jdbc/NoServiceConnectionNoQIT.java": (IT, rename(slice_to(nosc(IT), "JdbcSliceNoQ"), "NoServiceConnectionNoQIT"), 5),
    "com/tiffinbox/jdbc/NoQIT.java": (IT, rename(slice_to(IT, "JdbcSliceNoQ"), "NoQIT"), 4),
    "com/tiffinbox/jdbc/WrongSliceIT.java": (IT, rename(slice_to(IT, "DataSlice"), "WrongSliceIT"), 4),
    "com/tiffinbox/jdbc/AfterTheClassIT.java": (IT, rename(IT[:-2] + AFTER, "AfterTheClassIT"), 1),
}
for rel, (src, dst, want) in out.items():
    d = [l for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    rem = [l for l in d if l.startswith("-")]
    if rel.endswith("AfterTheClassIT.java"):
        ok = len(rem) == 1 and rem[0] == "-class CustomerAggregatesIT {" and sum(1 for l in d if l.startswith("+")) == 9
    else:
        ok = len(rem) == want
    if not ok:
        print("variant %s: its change is not the named one (%d lines removed)" % (rel, len(rem))); sys.exit(1)
for rel, (src, dst, want) in out.items():
    open(os.path.join(T, rel), "w", encoding="utf-8").write(dst)
    print("%s - from %s:" % (rel, "slice/JdbcSlice.java" if rel.startswith("slice/") else "CustomerAggregatesIT.java"))
    for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0):
        if l[:1] in "+-" and not l.startswith(("+++", "---")):
            print("  " + ("< " if l[0] == "-" else "> ") + l[1:].strip())
