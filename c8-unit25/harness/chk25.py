"""Unit 25's checks (python3 -I -B harness/chk25.py NAME ARG...), each re-deriving its numbers from a capture or from the shipped files,
never from the README's prose; every check prints "ok ..." or "FAIL ...", and one "VALUES ..." line (what the video may say), and exits 1
on a FAIL. Names:
  static AFTER    the family base: s825.py's lines 10-403 = s824.py's lines 22-415 (md5), its XFAM_S5 slice = the S5 probe's xfam5b.py
                  lines 10-125 (md5 pinned below); tree25.py's code = tree24.py's; every line H25.java and K25.java print says "the
                  harness's"; the patch for verify touches five test files and nothing under src/main; the exercise's copy is after/'s
  windows DIR L.. one harness JVM's witness windows (DIR: jvm.log, pg.log, monitor.txt): per label, PostgreSQL's non-empty statements
                  (the raw count beside), Redis's commands, the Elasticsearch client's requests between the label's two markers
  exercise F W Q  bash and zsh: broken (0 orders, SCARD 0, solved: no), solved (30, SCARD 30, solved: yes); the two wrong solutions fail
  wib F FILE      what FILE's "What it prints" block must be: the bash run's lines of that file's block, from the capture F
  jars F          the interfaces' members, each module's interface, the factory key in six jars, five creators, the domain types
  hierarchy F     six repositories by name, five factory beans, one fragment each, every chain ending at Commons' Repository
  parse F         the same parsed lines (x4, x6), the @Query sums refused, the five requests by their witnesses' counts
  strict F        x6 strict-mode lines, 12 "Could not safely identify" lines by module, the Found lines
  types F         Window and ScrollPosition in Commons' jar; the first window's four names, hasNext false, its SQL
  hole F          the table: each call's outcome and the commands in its own window; redis-cli and mongosh after; the sockets
  saveall F       5 statements (JPA, JDBC), 21 commands (Redis), 3 updates beside 1 insert (MongoDB), 2 requests (Elasticsearch)
  seven F MD5     7 lines, md5 = MD5 (read off ../c7-unit31/receipts.sh)
  verify F        18 + 13, 0 failures; five IT BINDINGS lines, every host IP 127.0.0.1; nothing pulled; nothing left
  readme R V      README.md's values block = V; every line of its text blocks is a line a capture printed (R.302)"""
import hashlib, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__)); U = os.path.dirname(HERE); REPO = os.path.dirname(U)
FAILS = []; VALUES = []
XFAM5B_SLICE_MD5 = "6e76327e6767b6549aaa9c517c81505d"   # fam/xfam5b.py (md5 0446c3fbc813fdda73785a9013a4a205), lines 10-125


def ok(c, msg):
    print(("ok " if c else "FAIL ") + msg)
    if not c: FAILS.append(msg)


def rd(p): return open(p, encoding="utf-8").read()


def md5(s): return hashlib.md5(s.encode()).hexdigest()


def static(after):
    s5 = rd(os.path.join(HERE, "s825.py")).split("\n"); s4 = rd(os.path.join(REPO, "c8-unit24", "harness", "s824.py")).split("\n")
    a5, a4 = "\n".join(s5[9:403]), "\n".join(s4[21:415])
    ok(s5[9].startswith("import hashlib") and md5(a5) == md5(a4), "s825.py's family base (lines 10-403) = s824.py's lines 22-415, byte for byte (md5 %s)" % md5(a5))
    b5 = "\n".join(s5[408:524])
    ok(s5[408].startswith("MOD = ") and md5(b5) == XFAM5B_SLICE_MD5, "s825.py's XFAM_S5 + TIMEPAT_S5 slice (lines 409-524) = the S5 probe's fam/xfam5b.py lines 10-125 (md5 %s)" % md5(b5))
    ok(re.search(r"^XEXEMPT_S5\s*=", "\n".join(s5), re.M) is None, "no XEXEMPT_S5 in s825.py")
    t5 = rd(os.path.join(HERE, "tree25.py")).split('"""', 2)[2]; t4 = rd(os.path.join(REPO, "c8-unit24", "harness", "tree24.py")).split('"""', 2)[2]
    ok(t5 == t4, "tree25.py's code = tree24.py's, byte for byte (only the docstring differs)")
    for f in ("H25.java", "K25.java"):
        j = rd(os.path.join(HERE, "src", "probe", "u25", f))
        lits = re.findall(r'System\.out\.println\("([^"]*)', j) + re.findall(r'\bp\("([^"]*)', j)
        ok(len(lits) > 0 and all(l.startswith("the harness's ") for l in re.findall(r'System\.out\.println\("([^"]*)', j)), "every line %s prints starts with \"the harness's\" (%d print calls, through H25.p)" % (f, len(lits)))
        ok("@Enable" not in re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", j), "%s: no @Enable...Repositories (S8.101)" % f)
    pt = rd(os.path.join(HERE, "it-bindings.patch"))
    files = re.findall(r"^\+\+\+ b/(\S+)", pt, re.M)
    ok(len(files) == 5 and all("/src/test/java/" in f for f in files), "it-bindings.patch: five files, every one under src/test/java (%s)" % ", ".join(f.split("/")[-1] for f in files))
    ok(pt.count("bindIp(\"127.0.0.1\")") == 3, "it-bindings.patch: bindIp(\"127.0.0.1\") on three ITs")
    ok(pt.count("System.out.println(\"IT BINDINGS ") == 5, "it-bindings.patch: five IT BINDINGS lines")
    ok(rd(os.path.join(U, "exercise", "KitchenOrder.java")) == rd(os.path.join(U, after, "tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenOrder.java")), "exercise/KitchenOrder.java = after/'s, byte for byte (the broken copy)")
    VALUES.append("the family base carried from s824.py and XFAM_S5 from xfam5b.py, md5-equal")


# ---- the witness windows -------------------------------------------------------------------------------------------------------
def pg_entries(path):
    out = []
    for l in open(path, encoding="utf-8", errors="replace").read().splitlines():
        m = re.match(r"^\S+ \S+ \S+ \[\d+\] (LOG|DETAIL|ERROR|STATEMENT|WARNING):\s+(.*)$", l)
        if m:
            out.append([m.group(1), m.group(2)])
        elif out and (l.startswith("\t") or l.startswith(" ")):
            out[-1][1] += " " + l.strip()
    return [x[1] for x in out if x[0] == "LOG" and re.match(r"(statement|execute [^:]*):", x[1])]


def stmt_text(e): return re.sub(r"^(statement|execute [^:]*):\s?", "", e)


def norm_redis(l):
    l = re.sub(r"^[0-9.]+ \[\d+ [^\]]+\] ", "", l)
    l = re.sub(r"\b(?:h25|[A-Z][a-z]+)-\d+\b", "<id>", l)
    if l.startswith('"HMSET"'): l = " ".join(l.split(" ")[:2]) + " …"
    return l


def windows(d, labels):
    jv = open(os.path.join(d, "jvm.log"), encoding="utf-8", errors="replace").read().splitlines()
    mo = open(os.path.join(d, "monitor.txt"), encoding="utf-8", errors="replace").read().splitlines()
    pg = pg_entries(os.path.join(d, "pg.log"))
    for lab in labels:
        b, e = "S5MARK-%s-begin" % lab, "S5MARK-%s-end" % lab
        def cut(lines, isb, ise):
            o, on, seen = [], False, False
            for l in lines:
                if isb(l): on = True; seen = True; continue
                if ise(l) and on: return o, True
                if on: o.append(l)
            return o, False
        sp, okp = cut(pg, lambda x: b in x, lambda x: e in x)
        sr, okr = cut(mo, lambda x: '"ECHO" "%s"' % b in x, lambda x: '"ECHO" "%s"' % e in x)
        sj, okj = cut(jv, lambda x: x == "the harness's MARK %s-begin" % lab, lambda x: x == "the harness's MARK %s-end" % lab)
        ne = [stmt_text(x) for x in sp if stmt_text(x).strip()]
        es = [re.sub(r"^.*? : curl -iX ", "", x) for x in sj if "low_level.Request : curl -iX " in x]
        es = [re.sub(r"'http://127\.0\.0\.1:\d+", "'<es>", x) for x in es]
        rr = [norm_redis(x) for x in sr if x.strip()]
        print("  window %s: markers %s · PostgreSQL %d non-empty statement(s) (raw %d) · Redis %d command(s) · Elasticsearch %d request(s)"
              % (lab, "found" if okp and okr and okj else "MISSING (pg %s, redis %s, jvm %s)" % (okp, okr, okj), len(ne), len(sp), len(rr), len(es)))
        for x in ne: print("    PostgreSQL: " + x[:260])
        i = 0
        while i < len(rr):
            j = i
            while j + 1 < len(rr) and rr[j + 1] == rr[i]: j += 1
            print("    Redis: " + rr[i][:200] + ("" if j == i else " (x%d)" % (j - i + 1))); i = j + 1
        for x in es: print("    Elasticsearch: " + x[:420])


# ---- capture checks ------------------------------------------------------------------------------------------------------------
def lines(p): return rd(p).splitlines()


def win(L, lab):
    for l in L:
        m = re.match(r"^  window %s: markers (\S+) · PostgreSQL (\d+) non-empty statement\(s\) \(raw (\d+)\) · Redis (\d+) command\(s\) · Elasticsearch (\d+) request\(s\)$" % re.escape(lab), l)
        if m: return m.group(1) == "found", int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5))
    return None


def winlines(L, lab):
    i = next((k for k, l in enumerate(L) if l.startswith("  window %s: " % lab)), None)
    if i is None: return []
    o = []
    for l in L[i + 1:]:
        if not l.startswith("    "): break
        o.append(l.strip())
    return o


def jars(p):
    L = lines(p); t = "\n".join(L)
    def blk(h):
        i = next((k for k, l in enumerate(L) if l == h), None)
        if i is None: return []
        o = []
        for l in L[i + 1:]:
            if l.startswith("--") or l.startswith("=="): break
            o.append(l)
        return o
    rep = blk("-- org.springframework.data.repository.Repository")
    ok(any("public interface org.springframework.data.repository.Repository<T, ID> {" in l for l in rep) and not [l for l in rep if "(" in l], "Repository<T, ID>: no members - the body empty, a marker (javap -p)")
    crud = [l for l in blk("-- org.springframework.data.repository.CrudRepository") if "public abstract" in l]
    ok(len(crud) == 12, "CrudRepository: %d abstract methods (12)" % len(crud))
    names = sorted(set(re.search(r" (\w+)\(", l).group(1) for l in crud))
    ok(names == sorted(["save", "saveAll", "findById", "existsById", "findAll", "findAllById", "count", "deleteById", "delete", "deleteAllById", "deleteAll"]), "CrudRepository's names: " + ", ".join(names))
    ps = [l for l in blk("-- org.springframework.data.repository.PagingAndSortingRepository") if "public abstract" in l]
    ok(len(ps) == 2 and any("findAll(org.springframework.data.domain.Sort)" in l for l in ps) and any("findAll(org.springframework.data.domain.Pageable)" in l for l in ps), "PagingAndSortingRepository: findAll(Sort), findAll(Pageable)")
    jpa = blk("-- spring-data-jpa-4.1.2.jar"); jab = [l for l in jpa if "public abstract" in l]
    ok(any("JpaRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID>, org.springframework.data.repository.query.QueryByExampleExecutor<T>" in l for l in jpa), "JpaRepository extends ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor")
    ok(len(jab) == 11, "JpaRepository adds %d abstract methods (11)" % len(jab))
    mon = blk("-- spring-data-mongodb-5.1.2.jar")
    ok(any("MongoRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID>, org.springframework.data.repository.query.QueryByExampleExecutor<T>" in l for l in mon) and any(" insert(" in l for l in mon), "MongoRepository: the same three + insert")
    es = blk("-- spring-data-elasticsearch-6.1.2.jar")
    ok(any("ElasticsearchRepository<T, ID> extends org.springframework.data.repository.PagingAndSortingRepository<T, ID>, org.springframework.data.repository.CrudRepository<T, ID>" in l for l in es) and any("searchSimilar(" in l for l in es) and any("RefreshPolicy" in l for l in es), "ElasticsearchRepository extends PagingAndSortingRepository + CrudRepository (no List forms), adds searchSimilar and the refresh-policy overloads")
    ok("CustomerAggregates.java:18:public interface CustomerAggregates extends ListCrudRepository<CustomerRow, Long>, ListPagingAndSortingRepository<CustomerRow, Long>" in t and "KitchenOrders.java:17:public interface KitchenOrders extends CrudRepository<KitchenOrder, String>" in t, "TiffinBox's JDBC and Redis repositories extend Commons' interfaces directly")
    fac = {}
    for l in L:
        m = re.match(r"^  (spring-data-[a-z]+-[0-9.]+\.jar) +(\S+)$", l)
        if m: fac[m.group(1)] = m.group(2)
    six = [k for k, v in fac.items() if v != "none"]
    ok(len(fac) == 8 and len(six) == 6 and fac.get("spring-data-commons-4.1.2.jar") == "none" and fac.get("spring-data-relational-4.1.2.jar") == "none", "the factory key in %d jars, none in commons and relational" % len(six))
    ok(fac.get("spring-data-redis-4.1.2.jar") == "org.springframework.data.redis.repository.support.RedisRepositoryFactory" and fac.get("spring-data-mongodb-5.1.2.jar") == "org.springframework.data.mongodb.repository.support.MongoRepositoryFactory", "Redis's and MongoDB's factories by name")
    cr = [l for l in L if re.match(r"^  (public |abstract |final )*class .*QueryCreator.* extends org\.springframework\.data\.repository\.query\.parser\.AbstractQueryCreator", l)]
    ok(len(cr) == 5, "five query creators extend Commons' AbstractQueryCreator (%d)" % len(cr))
    dom = [l for l in L if l.startswith("  org/springframework/data/domain/")]
    ok(len(dom) == 10, "Commons' domain types: %d (Window, ScrollPosition, KeysetScrollPosition, OffsetScrollPosition, Page, Slice, Sort, Pageable, PageRequest, Example)" % len(dom))
    ok("%s is not supported for Redis query derivation" in t, "RedisQueryCreator holds \"%s is not supported for Redis query derivation\"")
    ok("spring.docker.compose.skip.in-tests default true" in t, "Compose's skip.in-tests default true (Compose stays off in tests)")
    ok("md5 equal to the seed's: yyyyyyyy" in t, "the eight jars in after/'s BOOT-INF/lib = the seed's, md5")
    VALUES.append("CrudRepository %d methods · JpaRepository adds %d · the factory key in %d jars (%s), none in commons and relational · %d query creators extend AbstractQueryCreator · %d domain types"
                  % (len(crud), len(jab), len(six), ", ".join(k.split("-")[2] for k in six), len(cr), len(dom)))


SIX = ["CustomerAggregates", "CustomerEntityRepository", "DishEntityRepository", "Dishes", "KitchenOrders", "OrderDocuments"]


def hierarchy(p):
    L = lines(p); t = "\n".join(L)
    ok("the harness's repositories (org.springframework.data.repository.support.Repositories over the context): 6" in L, "Commons' Repositories over the dev context: 6")
    reps = [re.match(r"^the harness's REPO (\w+) ", l).group(1) for l in L if l.startswith("the harness's REPO ")]
    ok(sorted(reps) == SIX, "the six by name, the harness's two not among them (S8.101): " + ", ".join(sorted(reps)))
    ok(any(l.startswith("the harness's repositories built by the factories before the listing: RValue by RedisRepositoryFactory (true), MValue by MongoRepositoryFactory (true)") for l in L), "the harness's RValue and MValue built through the factories before the listing")
    fb = sorted(set(re.search(r"· factory bean (\S+) ·", l).group(1) for l in L if l.startswith("the harness's REPO ")))
    ok(len(fb) == 5, "five factory-bean classes = five modules: " + ", ".join(x.split(".")[-1] for x in fb))
    ko = next((l for l in L if l.startswith("the harness's REPO KitchenOrders ")), "")
    ok(ko.endswith("base class org.springframework.data.keyvalue.repository.support.SimpleKeyValueRepository"), "KitchenOrders' base: Spring Data KeyValue's SimpleKeyValueRepository")
    root = [l for l in L if l == "the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []"]
    ok(len(root) == 6, "every chain ends at org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] (%d)" % len(root))
    fr = [l for l in L if l.startswith("the harness's   composition's fragments 1 [StructuralRepositoryFragment Simple")]
    ok(len(fr) == 6, "each composition: one fragment, the base class (%d)" % len(fr))
    inj = {}
    for l in L:
        m = re.match(r"^    (\w+) +main: (.*) · test: (.*)$", l)
        if m: inj[m.group(1)] = (m.group(2), m.group(3))
    used = [k for k, v in inj.items() if v[0] != "none"]
    ok(len(inj) == 6 and sorted(used) == ["CustomerEntityRepository", "DishEntityRepository", "Dishes", "KitchenOrders"], "injected in src/main: %d (%s) · OrderDocuments and CustomerAggregates only by their tests (%s; %s)" % (len(used), ", ".join(sorted(used)), inj.get("OrderDocuments", ("?", "?"))[1], inj.get("CustomerAggregates", ("?", "?"))[1]))
    VALUES.append("repositories 6 · factory beans 5 · one fragment each · chains ending at Commons' Repository 6 · injected in src/main 4 (OrderDocuments, CustomerAggregates: their tests only) · KitchenOrders' base SimpleKeyValueRepository")


NAME = "name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By"; MEAL = "mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By"


def parse(p):
    L = lines(p)
    n = [l for l in L if l.startswith("the harness's   PartTree(") and l.endswith(") = " + NAME)]
    ok(len(n) == 4, "findByName on CustomerEntity, CustomerRow, Dish and Dishes.searchByName: the same line x%d (4)" % len(n))
    m = [l for l in L if l.startswith("the harness's PARSE findByMealType on ") and l.endswith(" = " + MEAL)]
    ok(len(m) == 6, "findByMealType on all six domain types: the same line x%d (6)" % len(m))
    ok("the harness's   PartTree(\"findByCustomerAndMealType\", KitchenOrder) = customer SIMPLE_PROPERTY (1): [Is, Equals] NEVER and mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By" in L, "findByCustomerAndMealType: its two-part line")
    ok("the harness's   PartTree(\"findAllByOrderByNameAsc\", CustomerEntity) = Order By name: ASC" in L, "findAllByOrderByNameAsc: Order By name: ASC")
    rf = [l for l in L if re.search(r"PartTree\(\"(monthRevenue|pausedDays)\", \w+\) refused: org\.springframework\.data\.core\.PropertyReferenceException: No property '(monthRevenue|pausedDays)' found for type", l)]
    ok(len(rf) == 4, "the @Query sums refused by the parser, PropertyReferenceException (org.springframework.data.core): %d (two methods x two repositories)" % len(rf))
    w = {k: win(L, k) for k in ("jpa-findByName", "jdbc-findByName", "redis-findByMealType", "redis-findByCustomerAndMealType", "mongo-findByMealType", "es-findByName")}
    ok(all(v and v[0] for v in w.values()), "every window's markers found in all three witnesses")
    ok(w["jpa-findByName"][1:2] == (1,) and any(x.startswith("PostgreSQL: select ce1_0.id,") and x.endswith("from customer ce1_0 where ce1_0.name=$1") for x in winlines(L, "jpa-findByName")), "Spring Data JPA's findByName: PostgreSQL 1 non-empty statement (select ... where ce1_0.name=$1)")
    jl = winlines(L, "jdbc-findByName")
    ok(w["jdbc-findByName"][1] == 2 and any("FROM \"customer\"" in x or "FROM customer" in x for x in jl) and any("pause" in x for x in jl), "Spring Data JDBC's findByName: PostgreSQL 2 non-empty statements (the customer, then its pauses)")
    rl = winlines(L, "redis-findByMealType")
    ok(w["redis-findByMealType"][3] == 61 and rl[:2] == ['Redis: "SINTER" "kitchen-order:mealType:VEG"', 'Redis: "HGETALL" "kitchen-order:<id>" (x60)'], "Spring Data Redis's findByMealType: SINTER + 60 HGETALL = 61 commands (MONITOR)")
    ok(w["redis-findByCustomerAndMealType"][3] == 31 and winlines(L, "redis-findByCustomerAndMealType")[0] == 'Redis: "SINTER" "kitchen-order:customer:Ravi" "kitchen-order:mealType:VEG"', "findByCustomerAndMealType: SINTER of two sets + 30 HGETALL = 31 commands")
    pf = [l for l in L if l.startswith("the harness's   the profiler [OrderDocuments.findByMealType] ")]
    ok(len(pf) == 2 and 'op=query ns=tiffinbox.orders command=find filter={"mealType": "VEG"} docsExamined=120 nreturned=60' in pf[0] and pf[1].endswith("entries 1"), "Spring Data MongoDB's findByMealType: the profiler, 1 find, filter {\"mealType\": \"VEG\"}, 120 examined, 60 returned")
    el = winlines(L, "es-findByName")
    ok(w["es-findByName"][4] == 2 and len(el) == 2 and '"size":0' in el[0] and "track_total_hits" in el[0] and '"size":1' in el[1] and all('"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}' in x for x in el), "Spring Data Elasticsearch's findByName: 2 requests (size 0 with track_total_hits, then size 1), each query_string default_operator and, fields [name]")
    ok(all(w[k][3] == 0 and w[k][4] == 0 for k in ("jpa-findByName", "jdbc-findByName")) and all(w[k][1] == 0 and w[k][4] == 0 for k in ("redis-findByMealType", "redis-findByCustomerAndMealType", "mongo-findByMealType")) and w["es-findByName"][1] == 0 and w["es-findByName"][3] == 0, "each window holds its own store's work alone (0 in the other witnesses)")
    for want in ('CALL Spring Data JPA CustomerEntityRepository.findByName("Ravi") -> Ravi VEG', 'CALL Spring Data JDBC CustomerAggregates.findByName("Ravi") -> Ravi id 1',
                 'CALL Spring Data Redis KitchenOrders.findByMealType("VEG") -> 60 orders, customers [Ravi, Sunil]', 'CALL Spring Data Redis KitchenOrders.findByCustomerAndMealType("Ravi", "VEG") -> 30 orders',
                 'CALL Spring Data MongoDB OrderDocuments.findByMealType("VEG") -> 60 documents, customers [Ravi, Sunil]', 'CALL Spring Data Elasticsearch Dishes.findByName("veg") -> [1 Vegetarian Lunch Box]'):
        ok(("the harness's " + want) in L, want)
    raw = sum(v[2] - v[1] for v in w.values())
    VALUES.append("the name line x%d, the mealType line x%d, @Query sums refused %d · JPA 1 statement · JDBC 2 · Redis 61 and 31 commands · MongoDB 1 find (120 examined, 60 returned) · Elasticsearch 2 requests · empty statements filtered %d" % (len(n), len(m), len(rf), raw))


def strict(p):
    L = lines(p); c = {}
    tot = 0; mult = 0; byte = {}
    for l in L:
        m = re.match(r"^  \(x(\d+)\) (.*)$", l)
        if not m: continue
        k, s = int(m.group(1)), m.group(2)
        if s == "Multiple Spring Data modules found, entering strict repository configuration mode": mult += k
        mm = re.match(r"^Spring Data ([A-Za-z ]+?) - Could not safely identify store assignment for repository candidate interface ", s)
        if mm: tot += k; byte[mm.group(1)] = byte.get(mm.group(1), 0) + k
    ok(mult == 6, "\"Multiple Spring Data modules found, entering strict repository configuration mode\" x%d (6)" % mult)
    ok(tot == 12, "\"Could not safely identify store assignment\" lines: %d (12)" % tot)
    want = {"JPA": 4, "Elasticsearch": 2, "Reactive Elasticsearch": 2, "MongoDB": 2, "Redis": 2}
    ok(byte == want, "by module: " + ", ".join("%s %d" % (k, v) for k, v in sorted(byte.items())))
    red = [l for l in L if "Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes; If you want this repository to be a Redis repository, consider annotating your entities with one of these annotations: org.springframework.data.redis.core.RedisHash (preferred), or consider extending one of the following types with your repository: org.springframework.data.keyvalue.repository.KeyValueRepository" in l]
    ok(len(red) == 1, "the Redis line on Dishes, whole, once")
    found = {}
    for l in L:
        m = re.search(r"Found (\d+) (JPA|JDBC|Redis|MongoDB|Elasticsearch|Reactive Elasticsearch) repository interfaces?\.", l)
        if m: found[m.group(2)] = int(m.group(1))
    ok(found == {"JPA": 2, "JDBC": 1, "Redis": 1, "MongoDB": 1, "Elasticsearch": 1, "Reactive Elasticsearch": 0}, "the Found lines: " + ", ".join("%s %d" % (k, v) for k, v in sorted(found.items())))
    VALUES.append("strict-mode lines x%d · Could not safely identify %d (JPA 4, Elasticsearch 2, Reactive Elasticsearch 2, MongoDB 2, Redis 2) · Found JPA 2, JDBC 1, Redis 1, MongoDB 1, Elasticsearch 1, Reactive Elasticsearch 0" % (mult, tot))


def types(p):
    L = lines(p)
    ok("the harness's TYPES Window's class org.springframework.data.domain.Window from spring-data-commons-4.1.2.jar · ScrollPosition's org.springframework.data.domain.ScrollPosition from spring-data-commons-4.1.2.jar" in L, "Window and ScrollPosition load from spring-data-commons-4.1.2.jar")
    ok(any(l.startswith("the harness's TYPES CustomerEntityRepository.findFirst10ByOrderByNameAsc(ScrollPosition.keyset()) -> the first window [Meera, Priya, Ravi, Sunil] · size 4 · hasNext false") for l in L), "the first window: [Meera, Priya, Ravi, Sunil], hasNext false")
    w = win(L, "keyset-jpa"); wl = winlines(L, "keyset-jpa")
    ok(w is not None and w[0] and w[1] == 1 and wl and wl[0].endswith("order by ce1_0.name,ce1_0.id fetch first $1 rows only"), "its SQL: one statement, ... order by ce1_0.name,ce1_0.id fetch first $1 rows only")
    VALUES.append("Window and ScrollPosition from spring-data-commons-4.1.2.jar · the first window [Meera, Priya, Ravi, Sunil], hasNext false, 1 statement")


HOLE_R = {"RValue": ("call -> 0 results", 1), "RValueGt": ("CALL threw java.lang.IllegalArgumentException: GREATER_THAN (1): [IsGreaterThan, GreaterThan] is not supported for Redis query derivation", 0),
          "RTypo": ("CALL threw org.springframework.data.core.PropertyReferenceException: No property 'mealTypo' found for type 'KitchenOrder'; Did you mean 'mealType'", 0),
          "RNot": ("CALL threw java.lang.IllegalArgumentException: NEGATING_SIMPLE_PROPERTY (1): [IsNot, Not] is not supported for Redis query derivation", 0),
          "RIn": ("CALL threw java.lang.IllegalArgumentException: IN (1): [IsIn, In] is not supported for Redis query derivation", 0),
          "RStart": ("CALL threw java.lang.IllegalArgumentException: STARTING_WITH (1): [IsStartingWith, StartingWith, StartsWith] is not supported for Redis query derivation", 0),
          "RIgnore": ("call -> 0 results", 1), "ROrder": ("call -> 60 results", 61), "RCount": ("call -> 60", 1), "RExists": ("call -> true", 1),
          "RFirst": ("call -> 3 results", 4), "ROr": ("call -> 60 results", 61)}
HOLE_M = {"MValue": ("call -> 30 results", '{"value": 240}', 30), "MValueGt": ("call -> 60 results", '{"value": {"$gt": 200}}', 60),
          "MNot": ("call -> 60 results", '{"mealType": {"$ne": "VEG"}}', 60), "MStart": ("call -> 30 results", '{"customer": {"$regularExpression": {"pattern": "^Ra", "options": ""}}}', 30)}


def hole(p):
    L = lines(p); t = "\n".join(L); cells = []
    for k, (out, nc) in HOLE_R.items():
        ln = "the harness's HOLE redis %s build ok · %s" % (k, out)
        w = win(L, "call-redis-" + k)
        ok(ln in L and w is not None and w[0] and w[3] == nc and w[1] == 0 and w[4] == 0, "Spring Data Redis %s: %s · %s command(s) in its own window" % (k, out.split(": ")[0] if "threw" in out else out, nc))
    ok(winlines(L, "call-redis-RValue") == ['Redis: "SINTER" "kitchen-order:value:240"'], "findByValue(240)'s one command: SINTER kitchen-order:value:240")
    ok(winlines(L, "call-redis-RIgnore") == ['Redis: "SINTER" "kitchen-order:mealType:veg"'], "findByMealTypeIgnoreCase(\"veg\")'s one command: SINTER kitchen-order:mealType:veg")
    ok(any(x.startswith('Redis: "SUNION"') for x in winlines(L, "call-redis-ROr")), "findByMealTypeOrCustomer: SUNION")
    for k, (out, flt, n) in HOLE_M.items():
        ln = "the harness's HOLE mongo %s build ok · %s" % (k, out)
        pf = [l for l in L if l.startswith("the harness's   the profiler [%s] " % k)]
        ok(ln in L and len(pf) == 2 and ("command=find filter=%s " % flt) in pf[0] and (" nreturned=%d " % n) in pf[0] and pf[1].endswith("entries 1"), "Spring Data MongoDB %s: %d documents, one find, filter %s (the profiler)" % (k, n, flt))
    ok("the harness's HOLE mongo MTypo BUILD refused: org.springframework.data.repository.query.QueryCreationException: No property 'mealTypo' found for type 'OrderDocument'; Did you mean 'mealType'" in t, "Spring Data MongoDB refuses findByMealTypo at the build (QueryCreationException)")
    ok(not any(l.startswith("the harness's   the profiler [MTypo]") for l in L), "MTypo: no call, no profiler window")
    ok("the harness's Redis index sets for kitchen-order (KEYS kitchen-order:*:*, the per-order :idx sets left out): [kitchen-order:customer:Meera, kitchen-order:customer:Priya, kitchen-order:customer:Ravi, kitchen-order:customer:Sunil, kitchen-order:mealType:NON_VEG, kitchen-order:mealType:VEG, kitchen-order:mealType:VEGAN]" in L, "the index sets: customer and mealType, no value")
    ok("    redis-cli EXISTS kitchen-order:value:240 -> 0 · SCARD kitchen-order:value:240 -> 0 · SCARD kitchen-order:mealType:VEG -> 60 · SCARD kitchen-order -> 120" in L, "redis-cli after: the set kitchen-order:value:240 absent (EXISTS 0, SCARD 0), mealType:VEG 60, 120 orders")
    ok(any(l.startswith("    redis-cli KEYS 'kitchen-order:*:*' (the per-order :idx sets left out) -> kitchen-order:customer:Meera kitchen-order:customer:Priya kitchen-order:customer:Ravi kitchen-order:customer:Sunil kitchen-order:mealType:NON_VEG kitchen-order:mealType:VEG kitchen-order:mealType:VEGAN") for l in L), "redis-cli KEYS: the same seven sets")
    ok("    mongosh: db.orders.countDocuments() -> 120 · countDocuments({value: 240}) -> 30 · countDocuments({value: {$gt: 200}}) -> 60" in L, "mongosh after: 120 · 30 · 60")
    sk = next((l for l in L if l.startswith("    the sockets: ")), "")
    ok(sk.startswith("    the sockets: listening (TCP) on 9200, 9300 · connections from another local port (outbound): 0 · UDP sockets: 0"), "the Elasticsearch container's sockets: listening 9200 and 9300, 0 outbound, 0 UDP")
    ok("    its interfaces (/proc/net/dev): eth0,lo" in L, "its interfaces: eth0, lo")
    VALUES.append("Redis findByValue(240) 0, no exception, 1 command · findByValueGreaterThan(200) throws, 0 commands · findByMealTypo throws at the first call, 0 commands · MongoDB 30 · 60 · refused at the build · redis-cli SCARD kitchen-order:value:240 0 · mongosh 30 and 60 · Not/In/StartingWith throw with 0 commands · IgnoreCase 0 with 1 · OrderByValueDesc 61 · count 1 · exists 1 · First3 4 · Or 61 (SUNION)")


def saveall(p):
    L = lines(p)
    for k in ("saveall-jpa", "saveall-jdbc"):
        w = win(L, k); wl = winlines(L, k)
        ins = [x for x in wl if re.match(r"PostgreSQL: (insert|INSERT) ", x)]
        ok(w is not None and w[0] and w[1] == 5 and wl[0] == "PostgreSQL: BEGIN" and wl[-1] == "PostgreSQL: COMMIT" and len(ins) == 3, "%s: BEGIN + 3 INSERT + COMMIT (%s non-empty statements)" % (k, w[1] if w else "?"))
    w = win(L, "saveall-redis"); wl = winlines(L, "saveall-redis")
    ok(w is not None and w[3] == 21 and sum(1 for x in wl if x.startswith('Redis: "DEL"')) == 3 and sum(1 for x in wl if x.startswith('Redis: "HMSET"')) == 3 and sum(1 for x in wl if x.startswith('Redis: "SADD"')) == 15, "saveall-redis: 21 commands (per entity DEL, HMSET, 5 SADD)")
    up = [l for l in L if l.startswith("the harness's   the profiler [MongoRepository.saveAll(three, ids assigned)] op=update ")]
    ins = [l for l in L if l.startswith("the harness's   the profiler [MongoTemplate.insertAll(three)] op=insert ")]
    ok(len(up) == 3 and all("nUpserted=1" in l for l in up), "MongoRepository.saveAll: 3 update commands, each an upsert (the ids are assigned)")
    ok(len(ins) == 1 and "ninserted=3" in ins[0], "MongoTemplate.insertAll: 1 insert, ninserted 3")
    w = win(L, "saveall-es"); wl = winlines(L, "saveall-es")
    ok(w is not None and w[4] == 2 and wl[0].startswith("Elasticsearch: POST '<es>/_bulk?refresh=false'") and wl[1].startswith("Elasticsearch: POST '<es>/dishes/_refresh'"), "saveall-es: _bulk?refresh=false + _refresh (2 requests)")
    VALUES.append("saveAll of three: JPA 5 statements, JDBC 5 (BEGIN, 3 INSERT, COMMIT) · Redis 21 commands · MongoDB 3 updates (upserts) beside insertAll's 1 insert (ninserted 3) · Elasticsearch 2 requests")


def seven(p, want):
    L = lines(p)
    m = [l for l in L if re.match(r"^  exit 0 · the seven responses: 7 lines · md5 [0-9a-f]{32} · listening on 20640 now: 0$", l)]
    ok(len(m) == 1 and want in m[0], "the seven on after/'s jar: 7 lines, md5 = %s (read off ../c7-unit31/receipts.sh)" % want)
    VALUES.append("the seven: 7 lines, md5 = the course's")


def verify(p):
    L = lines(p); t = "\n".join(L)
    ok(any(l.startswith("  the copy against after/ (diff -rq, target and secrets left out): ") and l.endswith("tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java") for l in L), "the tests' copy differs from after/ in the five IT files alone")
    ok(re.search(r"· under src/main: 0$", t, re.M) is not None, "the copy: nothing under src/main")
    ok("  the modifier, per IT file (grep -c withCreateContainerCmdModifier): CustomerEntityRepositoryIT 1 · CustomerAggregatesIT 1 · RedisDatastoreIT 1 · MongoDatastoreIT 1 · ElasticsearchIT 1" in L, "the static check: the modifier in all five IT files")
    ok(re.search(r"^  exit 0 · BUILD SUCCESS · offline: yes$", t, re.M) is not None, "mvn verify: exit 0, BUILD SUCCESS, offline")
    res = re.findall(r"^  the Results line: Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", t, re.M)
    ok(len(res) == 2 and res[0] == ("18", "0", "0", "0") and res[1] == ("13", "0", "0", "0"), "the tests: %s" % " + ".join("%s run, %s failures, %s errors" % r[:3] for r in res))
    b = [l.strip() for l in L if l.startswith("    IT BINDINGS ")]
    cls = sorted(set(x.split()[2] for x in b)); hosts = re.findall(r"-> ([^:\]]+):", "\n".join(b))
    ok(len(cls) == 5 and len(b) == 5, "five IT BINDINGS lines, five distinct classes (%s)" % ", ".join(cls))
    ok(len(hosts) >= 5 and all(h == "127.0.0.1" for h in hosts), "every entry's host IP 127.0.0.1 (%d entries, not 127.0.0.1: %d)" % (len(hosts), sum(1 for h in hosts if h != "127.0.0.1")))
    ok(re.search(r"each distinct host address: 127\.0\.0\.1 · ", t) is not None, "the Testcontainers containers' ports while verify ran: 127.0.0.1 alone (dk ps)")
    ok(re.search(r"· 18881-18884 bound during it: no$", t, re.M) is not None, "18881-18884 free during verify (Compose stays off in tests)")
    m = re.search(r"ElasticsearchIT: 'Timed out waiting' lines (\d+) · its container started: (\d+) · 'Creating container for image' (\d+) · 'Pulling' (\d+) · Testcontainers containers after it: (\d+) · listening on 20578 and 20615 after it: (\d+)", t)
    ok(m is not None and m.group(1) == "0" and m.group(4) == "0" and m.group(5) == "0" and m.group(6) == "0", "ElasticsearchIT did not time out; nothing pulled; no Testcontainers container left; 20578 and 20615 free after")
    VALUES.append("tests 18 + 13, 0 failures · IT BINDINGS 5 classes, every host IP 127.0.0.1 · containers created %s · pulled 0" % (m.group(3) if m else "?"))


def exercise(p, w, q):
    L = lines(p)
    ok(w == "22" and len(q.split()) == 22, "the spoken exercise line: 22 words (wc -w %s)" % w)
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in " + sh + " (")), None)
        ok(i is not None, "the %s run is in the capture" % sh)
        if i is None: continue
        j = next((k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines")), len(L))
        e = next((k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:")), len(L))
        br, so = [x.strip() for x in L[i:j]], [x.strip() for x in L[j:e]]
        ok("the lab's KitchenOrder: @Indexed fields [customer, mealType]" in br and "the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 0 orders" in br and "check: the lab's call findByValue(240) -> 0 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no" in br, sh + ": broken - @Indexed on customer and mealType, findByValue(240) 0, SCARD 0, solved: no")
        ok("the lab's KitchenOrder: @Indexed fields [customer, mealType, value]" in so and "the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 30 orders" in so and "check: the lab's call findByValue(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: yes" in so, sh + ": solved - @Indexed on value too, findByValue(240) 30, SCARD 30, solved: yes")
        ok(e < len(L) and re.search(r"listening on 20641-20645 afterwards: 0 · the exercise's containers afterwards: 0 · volumes (\d+) \(before the shell: \1\) · java processes of the exercise: 0 · images afterwards: the same list yes", L[e]) is not None, sh + ": nothing left - no listener, no container, the volumes back, no JVM, the images the same")
    t = "\n".join(L)
    ok("    check: the lab's call findByCustomer(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no" in L, "another method's name: findByCustomer finds thirty - the check refuses it (the call's name, and SCARD 0)")
    ok("    check: the lab's call findByValue(480) -> 0 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: no" in L, "another number: findByValue(480) - the check refuses it (the call), though SCARD is 30")
    VALUES.append("broken findByValue(240) 0, SCARD 0 · solved 30, SCARD 30 · another name refused · another number refused · the spoken line 22 words")


def wib(p, f):
    L = lines(p)
    i = next(k for k, l in enumerate(L) if l.startswith("in bash ("))
    j = next(k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines"))
    e = next(k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:"))
    seg = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(x[4:] if x.startswith("    ") else x for x in seg))


def readme(r, v):
    R = rd(r); V = rd(v).rstrip("\n")
    m = re.search(r"<!-- values: begin -->\n```text\n(.*?)\n```\n<!-- values: end -->", R, re.S)
    ok(m is not None and m.group(1) == V, "the values block = the captures' VALUES lines, byte for byte")
    caps = set()
    for f in os.listdir(U):
        if f.startswith(".r-") and f.endswith(".out"): caps.update(x.rstrip() for x in rd(os.path.join(U, f)).splitlines())
    caps.update(V.split("\n"))
    blocks = re.findall(r"```text\n(.*?)\n```", R, re.S); n = 0; bad = []
    for b in blocks:
        for l in b.split("\n"):
            n += 1
            if l.rstrip() not in caps and l.strip() != "…": bad.append(l[:100])
    ok(not bad, "every line of README.md's %d text blocks is a line a capture printed (%d lines; not found: %s)" % (len(blocks), n, bad[:3]))
    holetable(R)


TROW = {"findByValue(240)": ("RValue", "MValue"), "findByValueGreaterThan(200)": ("RValueGt", "MValueGt"), "findByMealTypo(\"VEG\")": ("RTypo", "MTypo"),
        "findByMealTypeNot(\"VEG\")": ("RNot", "MNot"), "findByCustomerStartingWith(\"Ra\")": ("RStart", "MStart"), "findByMealTypeIn(VEG, VEGAN)": ("RIn", None),
        "findByMealTypeIgnoreCase(\"veg\")": ("RIgnore", None)}


def holetable(R):
    """S8.95's numbers check on the hole table: every cell's number is the hole capture's, for that call and that store."""
    L = rd(os.path.join(U, ".r-hole.out")).splitlines(); rows = 0
    for l in R.splitlines():
        if not l.startswith("| `find"): continue
        c = [x.strip() for x in l.strip("|").split("|")]
        m = re.match(r"^`([^`]+)`$", c[0])
        if m and m.group(1) in TROW:
            rows += 1; ri, mi = TROW[m.group(1)]
            hl = next((x for x in L if x.startswith("the harness's HOLE redis %s " % ri)), "")
            mr = re.search(r"call -> (\d+) results$", hl)
            want = ("`%s` results" % mr.group(1)) if mr else ("throws" if "CALL threw" in hl else "?")
            ok(c[1].startswith(want) or (want == "throws" and c[1].startswith("builds; the first call throws")), "the hole table, %s, Spring Data Redis's cell: %s (the capture: %s)" % (m.group(1), c[1][:40], want))
            w = win(L, "call-redis-" + ri)
            ok(w is not None and c[2].startswith("`%d`" % w[3]), "the hole table, %s, commands in its window: %s (the capture: %s)" % (m.group(1), c[2][:20], w[3] if w else "?"))
            if mi:
                ml = next((x for x in L if x.startswith("the harness's HOLE mongo %s " % mi)), "")
                mm = re.search(r"call -> (\d+) results$", ml)
                mw = ("`%s`" % mm.group(1)) if mm else ("refused at the build" if "BUILD refused" in ml else "?")
                ok(c[3].startswith(mw), "the hole table, %s, Spring Data MongoDB's cell: %s (the capture: %s)" % (m.group(1), c[3][:30], mw))
                pf = next((x for x in L if x.startswith("the harness's   the profiler [%s] op=" % mi)), "")
                nr = re.search(r" nreturned=(\d+) ", pf)
                ok((nr and c[4].startswith("`%s`" % nr.group(1))) or (not nr and c[4] == "no call"), "the hole table, %s, documents: %s (the profiler: %s)" % (m.group(1), c[4][:20], nr.group(1) if nr else "no call"))
            else:
                ok(c[3] == "not run", "the hole table, %s: MongoDB not run" % m.group(1))
        elif c[0].startswith("`findByMealTypeOrderByValueDesc"):
            rows += 1
            got = " · ".join("`%d`" % (win(L, "call-redis-" + k) or (0, 0, 0, -1))[3] for k in ("ROrder", "RCount", "RExists", "RFirst", "ROr"))
            ok(c[2].startswith(got), "the hole table, the five supporting rows' commands: %s (the capture: %s)" % (c[2][:40], got))
    ok(rows == 8, "the hole table: %d rows checked against the capture (8)" % rows)


def inject(after):
    """Who names each repository in after/'s code, its comments stripped (/* */ and //), the repository's own file left out."""
    src = {}
    for part in ("main", "test"):
        for root in ("tiffinbox-core", "tiffinbox-web"):
            base = os.path.join(after, root, "src", part, "java")
            for d, ds, fs in os.walk(base):
                for f in fs:
                    if f.endswith(".java"):
                        t = re.sub(r"(?s)/\*.*?\*/", "", rd(os.path.join(d, f))); t = re.sub(r"//[^\n]*", "", t)
                        src.setdefault(part, {})[f[:-5]] = t
    for r in SIX_ORDER:
        row = []
        for part in ("main", "test"):
            w = sorted(k for k, t in src.get(part, {}).items() if k != r and re.search(r"\b%s\b" % r, t))
            row.append(", ".join(w) or "none")
        print("    %-25s main: %s · test: %s" % (r, row[0], row[1]))


SIX_ORDER = ["CustomerEntityRepository", "DishEntityRepository", "CustomerAggregates", "KitchenOrders", "OrderDocuments", "Dishes"]


def main():
    a = sys.argv[1:]; nm = a[0]
    if nm == "windows": windows(a[1], a[2:]); return
    if nm == "inject": inject(a[1]); return
    if nm == "wib": wib(a[1], a[2]); return
    {"static": lambda: static(a[1]), "jars": lambda: jars(a[1]), "hierarchy": lambda: hierarchy(a[1]), "parse": lambda: parse(a[1]), "strict": lambda: strict(a[1]),
     "types": lambda: types(a[1]), "hole": lambda: hole(a[1]), "saveall": lambda: saveall(a[1]), "seven": lambda: seven(a[1], a[2]), "verify": lambda: verify(a[1]),
     "exercise": lambda: exercise(a[1], a[2], a[3]), "readme": lambda: readme(a[1], a[2])}[nm]()
    print("VALUES " + " · ".join(VALUES))
    sys.exit(1 if FAILS else 0)


main()
