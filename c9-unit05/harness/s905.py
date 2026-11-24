"""Course 9 unit 05's prose gate, per sentence (python3 -I -B harness/s905.py harness/dur9.py FILE...), with a self-test that must pass first.
Carried from Course 9 unit 04's s904.py byte for byte from the line after its docstring through the XFAM_S9S1 end marker (as U01's s901.py,
U02's s902.py and U03's s903.py carried it - copied from U03's harness): the family base (Course 8 unit 27's s827.py lines 10-403 and 409-524,
as U04 carried them) and XFAM_S9S1, Course 9 Section 1's delimited family - chk05.py static asserts that slice equal to s903.py's and
s904.py's, and prints the block's md5. U04's own XU04 family is NOT carried (it is U04's), nor XU01-XU03; U05's own refused readings follow
(XU05). The duration pattern is dur9 (S9.18), loaded from harness/dur9.py, which receipts.sh pins to java9_series.py's DUR9_MD5 before this
runs. Lines inside a fenced block, the values block and the exercise's **Your turn:** line are not judged here; code spans are masked."""


import hashlib, importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|after a while|"
                 r"briefly|short(?:ly|er)?|(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|est|ly)?|quick(?:er|ly)?|fast(?:er|est)?)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|cheaper|costlier|expensive|overhead|efficient|inefficient|bloat\w*)\b", re.I)
WORKS = re.compile(r"\b(?:the cache works|caching works|it just caches|just caches|it caches it)\b", re.I)
OWNER = re.compile(r"\bSpring Data(?:'s)? (?:cache|caches|caching)\b|\bHibernate's (?:cache|caching)\b|\bJPA's cache\b", re.I)
OWNNEG = re.compile(r"\bnot (?:a |the )?(?:Spring Data|Hibernate's)\b|\bnever (?:Spring Data|Hibernate's)\b|second-level cache", re.I)
HITW = re.compile(r"\b(?:cache hits?|a hit|the hits?|cached read|from the cache|served from)\b", re.I)
STORE = re.compile(r"ConcurrentMap|ConcurrentHashMap|Caffeine|Redis|in the JVM|H2|PostgreSQL|the harness's|harness bean|SimpleKey", re.I)
WARNS = re.compile(r"\bSpring warns\b|\bwarns you\b|\ba warning\b|\bwarns\b", re.I)
LRU = re.compile(r"\bLRU\b|\bleast[- ]recently[- ]used\b|\bthe same eviction\b|\bthe same customer (?:leaves|goes|is dropped)\b|\bdrops the same\b|\bevicts the same\b", re.I)
POLICY = re.compile(r"TinyLFU|\bW-?TinyLFU\b|\bfrequency sketch\b|\bleast[- ]frequently[- ]used\b|\bLFU\b", re.I)
METER = re.compile(r"\bmeters?\b|cache_gets_total|cache_size|cache_evictions_total|\bcache_ lines?\b|\bprometheus line|\bhit line\b", re.I)
NAMED = re.compile(r"cache-names|named at the start|names? (?:given|set|listed)|caches named|the names", re.I)
SINGLE = re.compile(r"cache=\"customer\"|\bthe customer cache\b|`customer` cache|\bcache `customer`", re.I)
PUTS = re.compile(r"cache_puts_total", re.I)
PUTSOK = re.compile(r"\b(?:not|never) voiced\b|\bnever said\b|\bnot said\b", re.I)
HARNUM = re.compile(r"\[Meera, Nina, Ravi\]|maximumSize\(3\)|\bnonames\b|the copy's", re.I)
HARLAB = re.compile(r"harness|Caffeine's own API|not TiffinBox's|the copy|a copy|nonames|Course 2", re.I)
RMF = re.compile(r"\brm -f(?![a-z]*v)\b")
PLNOAM = re.compile(r"-pl tiffinbox-web(?! -am)")
ASYNC = re.compile(r"\bRedis (?:is|writes|works) asynchronous(?:ly)?\b|\basynchronous Redis\b|\bRedis is async\b", re.I)
REDISOP = re.compile(r"\b(?:stale|@CacheEvict|evict(?:s|ed|ion)?|clear\(\)|read right after|read after a write|right after a write)\b", re.I)
WRITER = re.compile(r"\bwriter\b|immediateWrites|enableLocking", re.I)
REDISW = re.compile(r"\bRedis\b")
BYTES = re.compile(r"\bthe bytes\b|\bbytes Redis\b|\bthe JSON (?:bytes|text)\b", re.I)
BYTESOK = re.compile(r"redis-cli|\bGET\b", re.I)
CLASSOK = re.compile(r"\bclass(?:es)?\b|ArrayList|read back|@class", re.I)
SILENT = re.compile(r"\b(?:silent(?:ly)?|without a word|no exception)\b", re.I)
SILCREDIT = re.compile(r"\b(?:Redis|JSON|Jackson) (?:hides|swallows|ignores|drops|silences)\b|\bRedis(?:'s)? fault\b|\bJSON(?:'s)? fault\b", re.I)
SILOK = re.compile(r"FAIL_ON_UNKNOWN_PROPERTIES|unknown-property check|the serializer(?:'s)?|its own setting|strict", re.I)
CKEY = re.compile(r"\bcustomer::|`customer`(?: cache)?|\bthe customer cache\b|cache=\"customer\"", re.I)
TTLT = re.compile(r"\bexpires? (?:quickly|soon|after)\b|\bafter (?:two|\d+) seconds?\b|\bTTL of \d+ ?s\b", re.I)
HEALTH = re.compile(r"/actuator/health\b|\bhealth (?:answers|is|turns)\b|\b503\b", re.I)
HEALTHOK = re.compile(r"no Redis|without Redis|default run|indicator|Redis absent|Redis down|is down", re.I)
DSTORE = re.compile(r"\bRedis as a (?:datastore|data store|database)\b|\bas a datastore\b", re.I)
DSTOREOK = re.compile(r"C8-15|Section 3|not a datastore|as a cache, not", re.I)
DOWNNV = re.compile(r"\bdown(?! -v)\b(?=[`\s.,;)]|$)")
DOWNCTX = re.compile(r"compose[^.]*\bdown\b", re.I)
PULLV = re.compile(r"(?:viewer's|the anchor's) `?compose\.yaml`?[^.]*(?:pull_policy|redis@sha256)", re.I)
DRKEY = re.compile(r"spring\.data\.redis\.\w+`?[^.]*\b(?:in|from) `?(?:the anchor's|application(?:-dev)?\.yaml)", re.I)
DRKEYOK = re.compile(r"\bno\b|\bnot\b|\bnever\b|\b0\b", re.I)
PAGE = re.compile(r"\b(?:the dashboard|the page|GET /dashboard) is cached\b|\bcaches the (?:dashboard|page)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
TYPED = re.compile(r"(?<![\w.#:=/\[-])\d+\s+(?:tests?|customers?|rows?|calls?|statements?|invocations?|reads?|containers?|beans?|jars?|libraries|entries|keys?|words|lines?|hits?|misses|evictions?)\b"
                   r"|(?<![\w.#:=/-])(?:18|23|103|122|503|19)(?![\w:/\]-]|\.\d)"
                   r"|\bTTL -?\d|\bstale in \d|\b\d+ of 10\b"
                   r"|\b\d+ of \d+\b|\b(?:hit|miss|size|evictions?|hitCount|missCount)\s*=?\s*\d"
                   r"|\[\d+(?:, \d+)+\]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|c130857a|0befc453|466c20ed|256c7752", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"|select count\(", re.I)
TITLES = ["MongoDB: Documents, Not Rows", "Repositories, MongoTemplate and Aggregation", "Transactions, Indexes and Embedding vs Referencing", "Choosing a Broker", "Delivery Guarantees", "What's Next: Not Everything Is a Relation", "Redis Data Structures From Java", "Spring Data Redis Repositories", "Pub/Sub and Streams", "Distributed Locks and Rate Counters", "Docker Compose for Development", "Cache Invalidation", "Conditional Caching, sync and Nulls", "Secrets: What Not to Commit", "N+1, Measured", "@Cacheable, @CacheEvict, @CachePut", "Caffeine",
          "The Cache Abstraction's Machinery", "Redis as a Cache", "The Second-Level Cache"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7|13)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|recipe|form|precedent|probe|IT|pinned|statistics|script|LinkedHashMap|own))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|units|recipe|form|precedent|builders|scripts|capstone|final|probe|IT|pinned|statistics)|c7-unit\d+|`c7-unit|`java[2578]_series\.py`|c2-unit04|core-java-2/", re.I)

C83 = "A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value."
C83X = re.compile(r"second-level cache holds", re.I)
NN = re.compile(r"\b(16|32) threads?\b[^.;]*?(?:→|->|, |give |gives |make |makes )\s*\1 (?:reads?|calls?|invocations?|statements?)\b|\b(16|32) threads?,? \2 reads?\b", re.I)
H2ST = re.compile(r"\bstampede\b[^.]*\bH2\b|\bH2\b[^.]*\bstampede\b", re.I)
H2OK = re.compile(r"\bnever\b|\bnot (?:voiced|run|said)\b|\bno\b", re.I)
HOLD = re.compile(r"\bstampede\b[^.]*\b(?:sleep|hold|Thread\.sleep)\b|\b(?:sleep|hold)\b[^.]*\bstampede\b", re.I)
HOLDOK = re.compile(r"\bno (?:hold|sleep)\b|\bwithout (?:a )?(?:hold|sleep)\b|\bnever\b|\bnaming sleep\b|\bno `sleep`", re.I)
CLEARI = re.compile(r"clear\(\)`? (?:is|was|empties)[^.]*\b(?:immediate|before it returns|at once)\b", re.I)
CLEAROK = re.compile(r"\bCaffeine\b|the anchor's writer|the cache writer TiffinBox gives", re.I)
DOCKUNP = re.compile(r"\bdocker (?:run|exec|rm|ps|pull|compose|volume|images?)\b")
NUM12 = re.compile(r"\b(?:keys|invocations|calls|rows|reads?|statements)\s+\d+\s*(?:→|->)\s*\d|\b\d+\s*(?:→|->)\s*\d+\b|\bsays [0-9]\b|\b\d+ \+ \d+\b|\b\d+ vs \d+\b", re.I)
TTLT2 = re.compile(r"\bafter a few seconds\b|\bexpires? (?:quickly|soon|fast|in)\b|\bshort-lived\b|\bthe entry (?:dies|ages) (?:quickly|soon)\b", re.I)


H13 = re.compile(r"(?<![\w-])o[123](?![\w-])|\bthe three orders\b|\btwo timed\b", re.I)
H13OK = re.compile(r"harness|labelled|a copy|the copy|the exercise", re.I)
SYNCX = re.compile(r"\bsync\b[^.;]*\bacross (?:servers|JVMs|instances|processes|nodes|machines)\b|\bacross (?:servers|JVMs|instances|processes)\b[^.;]*\bsync\b", re.I)
SYNCOK = re.compile(r"\b(?:not|never|no)\b|two-JVM capture", re.I)
NULLX = re.compile(r"cache-null-values", re.I)
QUIET = re.compile(r"\bquieter\b|\bnot cached\b|\bnot stored\b|\bskips?\b|\bsilently\b|\bnothing happens\b", re.I)
THROWS = re.compile(r"\bthrows?\b|IllegalArgumentException|\bnot a quieter\b", re.I)
ADDEV = re.compile(r"\badd\b`?(?:'s)?[^.;]*\bevicts?\b[^.;]*`customer`|\badd\b`?[^.;]*\bevicts?\b[^.;]*\bthe customer cache\b|\badd\b`? evicts `?customer\b(?!s)", re.I)
ADDOK = re.compile(r"\b(?:nothing|not|never|no)\b", re.I)
EVERY = re.compile(r"\b\d+ (?:in|at) every (?:round|count)\b|\binvocations \d+\b|\b\d+ → invisible\b", re.I)

C822 = "A cache holds what the method last returned; a write that never passes through the cache leaves it serving the old value."
C822X = re.compile(r"cache holds what the method", re.I)
MANGLE = re.compile(r"\bRedis(?:'s)? (?:mangles?|mangled|corrupts?|corrupted|scrambles?|garbles?)\b|\b(?:mangled|corrupted|garbled) by Redis\b", re.I)
R500 = re.compile(r"/leaderboard`?[^.;]*\b500\b|\b500\b[^.;]*/leaderboard", re.I)
R500OK = re.compile(r"\bstruck\b|\bnever\b|\brefused\b|\bnot\b|\bprobe's\b|`lb`", re.I)
DEFNEED = re.compile(r"\bdefault run\b[^.;]*\b(?:needs|requires|wants) Redis\b", re.I)
DEFOK = re.compile(r"\bnever\b|\bnot\b|\bno\b|\bnone\b|\bstill needs no\b", re.I)
RQUERY = re.compile(r"\b(?:query|queries|statements?|N\+1)\b", re.I)
RNAME = re.compile(r"\bRedis\b|redis-cli|ZINCRBY|ZREVRANGE|ZSCORE|\bsorted set\b|\bleaderboard\b|SINTER|HGETALL|SMEMBERS|SCARD|HMSET|@RedisHash|\bfinders?\b|KitchenOrders|\brepository\b", re.I)
IDXOK = re.compile(r"\bindex(?:es| sets?)?\b|kitchen-order|\brepository\b|KitchenOrders|`stale`|\bcapture\b", re.I)   # unit 15: a stale index is the repository's, not the cache writer's (R.378 narrowed, not dropped)
SELFCLEAN = re.compile(r"\bcleans? up after itself\b|\bfresh (?:start|JVM|TiffinBox) (?:cleans|repairs|fixes|removes)\b|\b(?:cleans|repairs) (?:the )?stale index(?:es)? (?:on|at) (?:every|each|the next) start\b", re.I)
SELFOK = re.compile(r"\b(?:never|not|refused|re-saves?|saves? (?:the same|those) ids)\b", re.I)
ONCLEAN = re.compile(r"\bON_STARTUP\b[^.;]*\b(?:cleans?|removes?|repairs?|forgets?)\b|\b(?:cleans?|removes?|repairs?)\b[^.;]*\bON_STARTUP\b", re.I)
ONCOND = re.compile(r"\brunning\b|\blisten(?:s|ing|er)?\b|\bwhile\b|\bhears?\b|\btells? it\b|\bre-saves?\b|\bstays? up\b", re.I)
SETTLE = re.compile(r"\bsettle\b|\bsleep\b[^.;]*\b(?:clean|read)\b|\bwait(?:ed|s)? (?:a bit|before (?:the )?(?:clean )?read)\b", re.I)
SETTLEOK = re.compile(r"\bnever\b|\bno\b|\bnot\b|\brefused\b|\bwithout\b|\bpoll", re.I)
B500 = re.compile(r"\b500\b[^.;]*\b(?:beside|while|and) (?:a |health )?(?:stays )?200\b", re.I)
GUAR = re.compile(r"\bguarantee[ds]?\b|\bdurable\b|\bdurability\b|\bnever lost\b|\bat-(?:least|most)-once\b|\bexactly-once\b|\breliable delivery\b|\bdelivers? reliably\b", re.I)
WAITW = re.compile(r"\btimes? out\b|\btimeouts?\b|\blater\b|\bwaits? for\b|\bblocks? for\b|\bin real time\b", re.I)
ONEW = re.compile(r"\b(?:redis-cli|Java) (?:alone|only) (?:reads|says|shows)\b|\bone witness\b(?![^.;]*\b(?:refused|never|not)\b)", re.I)
ACKRM = re.compile(r"\backnowledg\w*[^.;]*\b(?:removed|deleted|removes|deletes|gone|drops?)\b|\b(?:removed|deleted|removes|deletes)\b[^.;]*\backnowledg\w*", re.I)
ACKOK = re.compile(r"\bnot\b|\bnever\b|\bstays?\b|\bno entry\b|\bnothing\b|\bkept\b", re.I)
KAFKA = re.compile(r"\b(?:like|unlike|than|versus|vs\.?) Kafka\b|\bKafka (?:is|was|does|has|keeps|guarantees|delivers|would)\b|\bKafka-like\b", re.I)
CRASH = re.compile(r"\bcrash(?:ed|es)?\b", re.I)
CRASHOK = re.compile(r"\bnot (?:measured|said|claimed)\b|\bnever\b|\bunsaid\b|\brefused\b|\bwas not\b", re.I)
SIGC = re.compile(r"\bSIGINT\b[^.;]*\b(?:consumer|c1)\b|\b(?:consumer|c1)\b[^.;]*\bSIGINT\b", re.I)
SIGOK = re.compile(r"\bholds?\b|\bplanted\b|\bthe harness\b", re.I)
MAPOF = re.compile(r"\bMap\.of\b")
MAPOK = re.compile(r"\brefused\b|\bmoved\b|\bnot\b|\bnever\b|\bplant|\bmapof\b", re.I)
LOST = re.compile(r"\b(?:message|event|entry)s? (?:is |was |are |were |gets? )?lost\b|\bloses? the message\b", re.I)
DUALM = re.compile(r"\bdual write\b", re.I)
DUALOK = re.compile(r"\bnot measured\b|\bnamed\b|\bunmeasured\b|\bnot (?:a )?capture\b|\bno capture\b", re.I)
SID = re.compile(r"\b\d{13}-\d+\b")
H16R = re.compile(r"(?<![\w-])c[123](?![\w-])|\bentry-\d+\b|\bthe ten entries\b")
H16OK = re.compile(r"harness|labelled|a copy|the copy|the exercise|planted", re.I)
SAFE = re.compile(r"\b(?:the|a|this|that) lock is (?:now )?safe\b|\bsafe lock\b|\bmakes? the lock safe\b|\bRedlock is (?:safe|broken|wrong|unsafe|flawed|correct)\b|\block is (?:correct|unsafe)\b", re.I)
LUAC = re.compile(r"\b(?:Lua release|compare-and-delete|the script)\b[^.;]*\b(?:fix(?:es|ed)?|prevents?|protects?|guards?|solves?)\b|\b(?:fix(?:es|ed)?|prevents?|protects?|solves?)\b[^.;]*\b(?:Lua release|compare-and-delete)\b", re.I)
LUAOK = re.compile(r"\bnot\b|\bonly\b|held at once|together|overlap|\bstill ran\b", re.I)
OVER = re.compile(r"\boutliv(?:ed|es)\b|\bpast its (?:lock|time to live)\b|\bran past\b|\boverr?an\b|\boverrun\b|\bheld past\b", re.I)
OVEROK = re.compile(r"\bthe harness holds\b|\bplanted\b|\bthe program holds\b|\bon purpose\b", re.I)
ATOM = re.compile(r"\batomic(?:ally|ity)?\b", re.I)
ATOMOK = re.compile(r"\bLua\b|\bMULTI\b|\bSET\b|\bINCR\b|\bEXPIRE\b|\bone command\b|\bone step\b", re.I)
TTLNUM = re.compile(r"\b(?:PX|EX|PTTL|TTL)\s+[1-9]\d*|\bEXPIRE\s+\S+\s+[0-9]+\b|Duration\.ofMillis\(\d|\(integer\) [1-9]")
CITE = re.compile(r"\bKleppmann\b|\bantirez\b|\bSanfilippo\b", re.I)
CITEOK = re.compile(r"\bunchecked\b", re.I)
H17R = re.compile(r"\bholders? [ABC]\b|\bthe counter\b|\bthe rate counter\b", re.I)
H17OK = re.compile(r"harness|the exercise|the program|labelled|planted|\bcopy\b", re.I)
DRIFT = re.compile(r"\bclock[\s-]drift\b|\bclocks? (?:drift|skew)\b", re.I)
DRIFTOK = re.compile(r"\bno\b|\bnot\b|\bnever\b|\bwithout\b|\brefused\b|\blimit", re.I)
KFACT = re.compile(r"\bKafka\b", re.I)
KFACTOK = re.compile(r"\*Choosing a Broker\*|\*Delivery Guarantees\*|\bno Kafka fact\b|\bnot a Kafka\b|\brefused\b|\bnever\b|Course 13", re.I)
X17D = re.compile(r"\bdistributed lock\w*", re.I)
X17DOK = re.compile(r"one key many processes agree to wait on|\bthe harness's\b", re.I)
X17J = re.compile(r"\bacross two JVMs\b", re.I)
X17JOK = re.compile(r"\bsync\b[^.;]*(?:customers~lock|\.\./c8-unit17)|(?:customers~lock|\.\./c8-unit17)[^.;]*\bsync\b", re.I)
CUR = [""]   # the file being judged: the exercise's own consumers (c1, c2) are the exercise's, by its own files
XFAMRX = {}
XFAM_S2 = {
    "S2: the cache works / caching works - a slogan for a hit (R.375)": (r"\b(?:the )?cache works\b|\bcaching works\b|\bcache is working\b", None),
    "S2: it just caches - a slogan for a hit (R.375)": (r"\bjust caches?\b|\bsimply caches?\b|\bit caches it\b", None),
    "S2: Spring Data caches - the abstraction is spring-context's (R.348)": (r"\bSpring Data(?:'s)?(?: J-P-A| J-D-B-C| JPA| JDBC)?(?:'s)? (?:caches|caching|cache|cached)\b", None),
    "S2: Redis is asynchronous - only the writer Boot builds over Lettuce is (R.378, RED #11)": (r"\bRedis\b[^.;]*\basync(?:hronous(?:ly)?)?\b|\basync(?:hronous(?:ly)?)?\b[^.;]*\bRedis\b", r"^(?![^.;]*\bRedis (?:is|writes|stays|runs|answers)\b[^.;]*\basync)(?![^.;]*\b(?:so is|and so|unlike|like)\b)[^.;]*\bthe writer Boot builds over Lettuce\b[^.;]*\basync"),
    "S2: always warns - a WARN only where one is captured (R.377)": (r"\balways (?:warns?|logs?|tells? you|complains?)\b", None),
    "S2: the same eviction - Course two's LRU and Caffeine drop different customers (R.385)": (r"\b(?:the )?same eviction\b|\bevicts? the same\b|\bsame (?:victim|customer) (?:leaves|dropped|evicted)\b", None),
    "S2: LRU for Caffeine - say only what the capture shows (R.385)": (r"\bL-?R-?U\b|\bleast[\s-]recently[\s-]used\b", r"^(?![^.;]*\bCaffeine\b)(?![^.;]*\b(?:cache|caches|so is|too|like|as well)\b)(?=[^.;]*\b(?:Course two|Course 2|LinkedHashMap)\b)"),
    "S2: faster - a hit is counts, never a speed (R.388)": (r"\bfast(?:er|est)?\b", None),
    "S2: instantly - a duration meaning dur8 misses (R.388)": (r"\binstant(?:ly|aneous(?:ly)?)?\b", None),
    "S2: across servers - sync is one JVM (R.382)": (r"\bacross (?:servers?|machines?|nodes?|instances?|JVMs?|processes|the cluster|a cluster)\b|\bdistributed lock\w*|\bcluster[\s-]wide\b", None),
    "S2: Hibernate's cache - the abstraction is not Hibernate's (R.348, C8-16)": (r"\bHibernate(?:'s)? (?:own )?(?:caches|caching|cache|cached)\b", None),
    "S2: after a while - a duration dur8 misses (R.388, RED #10)": (r"\b(?:after|for|in) a (?:while|bit|little)\b|\bafter some time\b", None),
    "S2: short - a duration dur8 misses (R.388, RED #10)": (r"\bshort(?:ly|er|est|[\s-]lived)?\b", None),
    "S2: briefly - a duration dur8 misses (R.388, RED #10)": (r"\bbrief(?:ly)?\b", None),
    "S2: in a moment - a duration dur8 misses (R.388, RED #10)": (r"\bin a (?:moment|second|minute|jiffy|flash|heartbeat)\b|\bmomentar(?:y|ily)\b", None),
    "S2: expires - expiry is counts, keys and invocations (R.380, R.395; RED-S2-SCRIPTS #108, #202, #209)": (r"\bexpir(?:es|ed|y|ing)\b|\bexpire[\s-]after\b", None),
    "S2: immediate - a duration meaning dur8 misses (R.388, R.395; RED-S2-SCRIPTS #200)": (r"\bimmediate(?:ly)?\b", None),
    "S2: right after - a time meaning dur8 misses (R.388, R.395; RED-S2-SCRIPTS #200)": (r"\bright (?:after|away|then|before)\b", None),
    "S2: more often / runs out / at last - a frequency or time meaning (R.388, R.395; RED-S2-SCRIPTS #203, #216, #218)": (r"\b(?:more|less) often\b|\bruns? out\b|\bat last\b", None),
}


def s3(s, raw):
    out = []
    if C822X.search(raw) and C822 not in raw and re.sub(r"^[>*\s]+|[*\s]+$", "", raw) not in C822: out.append("C8-22: Section 2's sentence that is not c8-unit12/pinned.txt's, byte for byte")
    if MANGLE.search(s): out.append("R.399: \"Redis mangles\" - credit the serializer")
    if R500.search(raw) and not R500OK.search(raw): out.append("R.413: /leaderboard answers 500 - under dev the start stops")
    if DEFNEED.search(raw) and not DEFOK.search(raw): out.append("R.400: the default run needs Redis - it does not")
    if RQUERY.search(s) and RNAME.search(raw): out.append("R.401: SQL's words for Redis: " + RQUERY.search(s).group(0))
    sg = s.replace("*Delivery Guarantees*", "*…*")   # Course 13's title, by title only (R.405)
    if GUAR.search(sg): out.append("R.404: a delivery or durability word: " + GUAR.search(sg).group(0))
    if WAITW.search(s): out.append("R.402: a wait word: " + WAITW.search(s).group(0))
    if ONEW.search(s): out.append("R.398: a Redis claim with one witness")
    if SELFCLEAN.search(raw) and not SELFOK.search(raw): out.append("R.403: the cleanup said without its condition - " + SELFCLEAN.search(raw).group(0))
    if ONCLEAN.search(raw) and not ONCOND.search(raw): out.append("R.403: an ON_STARTUP cleanup without its condition (a running repository, listening)")
    if SETTLE.search(raw) and not SETTLEOK.search(raw): out.append("R.412: a settle sleep behind a clean read - a receipt polls a count")
    if B500.search(raw) and not R500OK.search(raw): out.append("R.413: 500 beside 200 - under dev the start stops")
    if ACKRM.search(raw) and not ACKOK.search(raw): out.append("unit 16: an acknowledged entry said as removed - it stays (XLEN unchanged)")
    if KAFKA.search(raw): out.append("R.405: Kafka as a comparison - Course 13's titles only")
    if CRASH.search(raw) and not CRASHOK.search(raw): out.append("R.406: \"crashed\" - the harness holds, then SIGINT (planted)")
    if SIGC.search(raw) and not SIGOK.search(raw): out.append("R.406: a SIGINT'd consumer without the hold's label (the harness holds, planted)")
    if MAPOF.search(raw) and not MAPOK.search(raw): out.append("R.411: Map.of said as a writer - its order moved; refused")
    if LOST.search(raw): out.append("R.404: \"lost\" - say the receiver count, the list and the empty key space")
    if DUALM.search(raw) and not DUALOK.search(raw): out.append("C8-20: the dual write said as measured - it is named only")
    if SID.search(raw): out.append("R.402: a stream id with its time part")
    if H16R.search(raw) and not H16OK.search(raw) and not CUR[0].startswith("exercise/"): out.append("R.392: the harness's consumers or entries without their label")
    if SAFE.search(raw): out.append("R.407/XFAM_S3: a lock or Redlock verdict: " + SAFE.search(raw).group(0))
    if LUAC.search(raw) and not LUAOK.search(raw): out.append("R.407/R.350: the Lua release credited without what it does not guarantee (the overlap)")
    if OVER.search(raw) and not OVEROK.search(raw): out.append("R.406: a hold or overrun without its label (the harness holds, planted)")
    if ATOM.search(raw) and not ATOMOK.search(raw): out.append("unit 17: atomic without Lua, MULTI or a one-command name")
    if TTLNUM.search(raw): out.append("R.402: a time to live with its number: " + TTLNUM.search(raw).group(0))
    if CITE.search(raw) and not CITEOK.search(raw): out.append("RED #13: a citation outside the unchecked label")
    if H17R.search(raw) and not H17OK.search(raw): out.append("R.392: a holder or the counter without its label (the harness's)")
    if DRIFT.search(raw) and not DRIFTOK.search(raw): out.append("unit 17: a clock-drift claim - the sketch has no drift term")
    if KFACT.search(raw) and not KFACTOK.search(raw): out.append("R.405: a Kafka fact")
    if re.search(r"\bacross servers?\b", raw, re.I): out.append("R.409: across servers - never")
    if X17J.search(raw) and not X17JOK.search(raw): out.append("R.409: across two JVMs outside the sentences that quote sync's capture")
    sx = s.replace("*Distributed Locks and Rate Counters*", "*…*")   # XEXEMPT_S3: unit 17's title, by title only (R.409)
    sx = re.sub(r"(?i)\bthe (?:Section \d )?brief(?:'s)?(?! ?ly)\b", "the …", sx)   # the document named "brief", never the duration word
    if X17D.search(sx) and X17DOK.search(raw): sx = X17D.sub("…", sx)   # XEXEMPT_S3: "distributed lock" glossed or named the harness's
    if X17J.search(sx) and X17JOK.search(raw): sx = X17J.sub("…", sx)   # XEXEMPT_S3: "across two JVMs" beside sync's capture
    for name, (rx, okr) in XFAM_S2.items():
        if re.search(rx, sx, re.I) and not (okr and re.search(okr, s, re.I)): out.append("XFAM_S2: " + name)
    return out

XFAM_S4 = {
    "S4: schemaless (XFAM_S4, R.430)": (r"\bschema-?less\b|\bno schema\b|\bwithout a schema\b", None),
    "S4: web scale (XFAM_S4)": (r"\bweb[\s-]scale\b", None),
    "S4: a speed or a verdict beside Mongo or PostgreSQL - no time was measured (R.433)": (r"(?=[^.;]*\b(?:Mongo(?:DB)?|PostgreSQL|Postgres|the document|the tables?)\b)[^.;]*\b(?:faster|slower|scales?|scaling|better than|worse than|outperforms?)\b", None),
    "S4: joins are slow (R.433)": (r"\bjoins? (?:are|is) (?:slow|expensive|costly)\b", None),
    "S4: N+1 for Mongo or a reference - one command per reference (R.424)": (r"(?=[^.;]*\b(?:Mongo(?:DB)?|references?|@DocumentReference|@DBRef)\b)[^.;]*\bN\+1\b", None),
    "S4: ACID / atomic / safe without the manager and the topology (R.427)": (r"(?=[^.;]*\b(?:Mongo(?:DB)?|documents?|transactions?|menu|the write)\b)[^.;]*(?:\bACID\b|\batomic(?:ally|ity)?\b|\bsafe(?:ly)?\b)", r"(?=.*\b(?:MongoTransactionManager|Mongo's transaction manager|a JDBC transaction manager|JpaTransactionManager)\b)(?=.*\b(?:replica set|standalone)\b)"),
    "S4: telemetry off / sends nothing (R.422)": (r"\btelemetry (?:is )?off\b|\bsends nothing\b|\bno telemetry\b|\bnothing (?:is )?sent\b", None),
    "S4: @Indexed creates / automatically indexed without auto-index-creation": (r"(?<!\w)@Indexed creates\b|\bautomatically indexed\b", r"auto-index-creation"),
    "S4: Mongo mangles / corrupts": (r"\bMongo(?:DB)?(?:'s)? (?:mangles?|corrupts?|garbles?|scrambles?)\b", None),
    "S4: a wait with a number (R.426)": (r"\b(?:times? out|waits?|hangs?|gives? up)\b[^.;]*\b\d+\b|\b(?:after|in) (?:\d+|thirty|ten|five) (?:seconds?|ms|milliseconds?)\b", None),
    "S4: the dead health key (R.425)": (r"management\.health\.mongo\.enabled", r"\b(?:dead|never written|refused|does nothing|not Boot's)\b"),
    "S4: today's menu - every capture reads day-19 (RED #9)": (r"\btoday'?s menu\b", None),
    "S4: the default run needs Mongo (R.425)": (r"\bdefault run\b[^.;]*\b(?:needs|requires) (?:Mongo|MongoDB)\b", r"\b(?:needs|requires) no\b|\bnot\b"),
    "S4: the default run never touches Mongo - the health key alone still tries 27017 (R.425)": (r"\bnever touches Mongo(?:DB)?\b", r"\brefused\b|\bwould be false\b"),
    "S4: docker exec ... mongosh (R.422)": (r"\bdocker\b[^.;`]*\bexec\b[^.;`]*\bmongosh\b", r"\b(?:refused|never|no)\b"),
    "S4: a dropCollection as the reset (R.431)": (r"\bdropCollection\b|\bdrops? the collection\b", r"\b(?:never|not|refused|no)\b"),
}
TIMEPAT_S4 = re.compile(r"executionTimeMillis(?:Estimate)?|\bmillis: ?\d|\"ts\"|Remaining time: \d|\b\w+MS=\d+|'\d+ ms'|ObjectId\('[0-9a-f]{8,}|\b[0-9a-f]{24}\b|Timestamp\(\{ ?t: \d|\"\$date\"|\belectionDate\b|\boptimeDate\b|\buptime\b")
XEXEMPT_S4_Q = re.compile(r"\b(?:a|one)\s+`?query`?\s+ops?\b|`query`", re.I)
MQUERY = re.compile(r"\b(?:query|queries)\b", re.I)
MNAME = re.compile(r"\bMongo(?:DB)?\b|mongosh|system\.profile|\bdocuments?\b|findById|MongoTemplate", re.I)


def s4(s, raw):
    out = []
    for name, (rx, okr) in XFAM_S4.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XFAM_S4: " + name)
    if TIMEPAT_S4.search(raw): out.append("TIMEPAT_S4: " + TIMEPAT_S4.search(raw).group(0))
    sq = XEXEMPT_S4_Q.sub("…", s)   # XEXEMPT_S4 (a): system.profile's op name
    if MQUERY.search(sq) and MNAME.search(raw): out.append("XEXEMPT_S4 (a): \"query\" for MongoDB outside the op's name: " + MQUERY.search(sq).group(0))
    return out


XU19 = {
    "U19: a fourth witness - the orders collection is a copy, grouped by the server (RED #16)": (r"\bfourth witness\b|\bfourth source\b", r"\bnever\b|\bnot\b|\brefused\b"),
    "U19: the pipeline sums any field - $sum over a String is 0, silently (silent)": (r"\bsums? (?:any|every) field\b|\bworks on any field\b", None),
    "U19: Mongo hides or swallows the error - say: returns zeros, no error": (r"\bMongo(?:DB)?(?:'s)? (?:hides?|swallows?)\b", None),
    "U19: N+1 beside a finder or a repository (R.424, S8.64)": (r"(?=[^.;]*\b(?:finder|repository|findByMealType|OrderDocuments)\b)[^.;]*\bN\+1\b", None),
}
PARA = [""]


def u19(s, raw):
    out = []
    for name, (rx, okr) in XU19.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU19: " + name)
    if re.search(r"\b(?:the|its) revenue\b|\brevenue pipeline\b", raw, re.I) and not re.search(r"\bcop(?:y|ied|ies)\b|\bthe same (?:120 )?orders\b", PARA[0], re.I):
        out.append("XU19: the revenue without \"the same orders copied\" in its paragraph (RED #16)")
    return out


XU20 = {
    "U20: Boot configures the Mongo transaction manager - the jar read says none (RED #27)": (r"\bBoot(?:'s)? (?:configures|auto-configures|makes|creates|gives|ships|registers)\b[^.;]*\b(?:MongoTransactionManager|Mongo(?:DB)?(?:'s)? transaction manager)", r"\bno\b|\bnot\b|\bnever\b|\bnone\b|\b0\b"),
    "U20: transactions work / the rollback works without the manager and the topology (S8.67)": (r"\b(?:transactions?|the rollback|rollback) works?\b", r"(?=.*\b(?:MongoTransactionManager|JpaTransactionManager|Mongo's transaction manager)\b)(?=.*\b(?:replica set|standalone)\b)"),
    "U20: @Indexed makes the index without the key": (r"(?<!\w)@Indexed (?:makes|builds|adds|gives)\b", r"auto-index-creation"),
    "U20: TiffinBox's orders said to send the harness's commands (R.392)": (r"\bTiffinBox(?:'s)? (?:orders?|order documents?)\b[^.;]*\b(?:sends?|costs?|needs?|does|do)\b[^.;]*\b(?:commands?|ops?|queries)\b", None),
    "U20: a JDBC transaction manager - the receipt ran JpaTransactionManager (RED #7)": (r"\ba JDBC transaction manager\b|\bDataSourceTransactionManager\b", r"\bprobe(?:'s)?\b"),
}


def u20(s, raw):
    out = []
    for name, (rx, okr) in XU20.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU20: " + name)
    return out


XFAM_S4B = {
    "S4B: real-time / instant (XFAM_S4B)": (r"\breal[\s-]?time\b|\binstant(?:ly)?\b|\bimmediately (?:searchable|visible|found)\b", None),
    "S4B: relevance as a quality (XFAM_S4B)": (r"\b(?:more |most |less )?relevant\b|\brelevance\b(?![^.;]*\bscore\b)|\b(?:best|better) match(?:es)?\b|\bsmart(?:er)? search\b|\bunderstands?\b", None),
    "S4B: a way to say so that fixes veg, without its wrong ids (S8.80)": (r"^(?=[^.;]*\bveg\b)[^.;]*\b(?:fuzz\w*|stem\w*|prefix|wildcard|n-?grams?|edge)\b[^.;]*\b(?:finds?|fix(?:es)?|solves?|matches?)\b(?![^.;]*\b(?:vegan box|egg|not|never|no)\b)", None),
    "S4B: in sync / always in sync (S8.82)": (r"\b(?:always|stays?|kept|keeps?)\s+(?:\w+\s+)?in sync\b|\bnever drifts?\b|\bautomatically (?:synced|syncs?|updated)\b", None),
    "S4B: best database / right tool (U23)": (r"\bbest database\b|\bright tool for the job\b|\bNoSQL is (?:faster|better)\b|\bSQL (?:doesn't|does not|can't|cannot) scale\b|\buse \w+ for \w+\b", None),
    "S4B: a vector store promise (flag 10)": (r"\bvector (?:store|database|search)\b(?![^.;]*\bthis course does not build\b)", None),
    "S4B: the dual write solved here (flag 12)": (r"^(?![^.;]*\bCourse 13\b)[^.;]*\bdual write\b[^.;]*\b(?:solved|fixed|handled|safe)\b", None),
    "S4B: the chained manager as a fix (S8.88)": (r"\bChainedTransactionManager\b[^.;]*\b(?:fix|solves?|atomic|both or neither)\b", None),
    "S4B: security off is safe (flag 4)": (r"^(?=[^.;]*\bsecurity\b)[^.;]*\b(?:safe|harmless|fine|secure)\b", None),
    "S4B: singular time words (RED S4B #4)": (r"\b(?:a|one|1|half a)\s+(?:second|millisecond|minute|hour)\b(?!-)(?!\s+(?:write|store|manager|copy|index|run|start|query|time|one|dish|document|row))|\b\d+(?:\.\d+)?\s?(?:s|ms|sec)\b(?!\w)", None),
}
TIMEPAT_S4B = re.compile(r"\"took\"\s*:\s*\d|\btook\[\d|\brefresh_interval\"?\s*[:=]?\s*\"?\d|\"after\"\s*:\s*\"\d|\bconnection-timeout\s+\d|\bsocket-timeout\s+\d|\bstart_time_in_millis\b|\buptime_in_millis\b|\brequest_interval\s*=\s*\d|\bjitter\s*=\s*\d|\bpoll\.interval\s*=\s*\d|\"@timestamp\"\s*:\s*\"\d")


def s4b(s, raw):
    out = []
    for name, (rx, okr) in XFAM_S4B.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XFAM_S4B: " + name)
    if TIMEPAT_S4B.search(raw): out.append("TIMEPAT_S4B: " + TIMEPAT_S4B.search(raw).group(0))
    return out


XU21 = {
    "U21: veg matches vegetarian without the analyzer named": (r"\bveg\b[^.;]*\bmatch(?:es)?\b[^.;]*\bvegetarian\b", r"\banalyz\w*|\bsynonym\b|\bdish-settings|\bnever\b|\bnot\b|\bnothing\b|\bzero\b|\bnone\b"),
    "U21: Elasticsearch finds it, alone - say which index, which analyzer": (r"\bElasticsearch finds it\b", None),
    "U21: fuzzy fixes it - two wrong hits": (r"\bfuzz\w* (?:fixes|solves)\b", None),
    "U21: the synonym fixes it without the vegetarian box's one hit beside": (r"\bsynonym\b[^.;]*\b(?:fixes|solves)\b", r"\bvegetarian box\b|\bone hit\b|`1 \[1\]`|\bonly\b"),
    "U21: a speed or a verdict beside a store (R.433)": (r"(?=[^.;]*\b(?:Elasticsearch|PostgreSQL|Postgres|Mongo(?:DB)?|Redis|the index)\b)[^.;]*\b(?:faster|slower|scales?|better than|worse than|outperforms?)\b", None),
    "U21: telemetry / phones home (S8.92's form only)": (r"\btelemetry (?:is )?off\b|\bsends nothing\b|\bphones? home\b|\bno telemetry\b", None),
    "U21: TiffinBox searches PostgreSQL - the index answered, the rows are the source": (r"\b(?:TiffinBox )?searches PostgreSQL\b|\bPostgreSQL (?:answers|answered) (?:the )?search\b", r"\bnot\b|\bnever\b"),
    "U21: the index stays in sync - unit 22's": (r"\bindex (?:stays|is kept|remains) (?:in sync|up to date)\b", None),
    "U21: @Document creates the index without the start and the repository": (r"(?<!\w)@Document creates\b", r"\bat the start\b[^.;]*\brepository\b"),
    "U21: the health key alone builds no client - its scans still run": (r"\bhealth key alone\b[^.;]*\b(?:builds no client|is enough|turns it off|switches it off)\b", None),
    "U21: docker exec ... curl (§BUILDERS 9)": (r"\bdocker\b[^.;`]*\bexec\b[^.;`]*\bcurl\b", r"\b(?:refused|never|no)\b"),
    "U21: a port on every interface (S8.94)": (r"0\.0\.0\.0:\d|\[::\]:\d", r"\b(?:refused|never|not|no)\b"),
}
HL = [None]


def hinglish():
    if HL[0] is None:
        import os
        f = os.path.expanduser("~/Desktop/PromptVidya-Automation/check_unit8.py")
        HL[0] = False
        if os.path.exists(f):
            for l in open(f, encoding="utf-8"):
                if re.match(r"HINGLISH\s*=\s*r[\"']", l):
                    HL[0] = re.compile(eval(l.split("=", 1)[1].strip(), {}), re.I)   # the line's own raw string, read at run time
                    break
    return HL[0]


def u21(s, raw):
    out = []
    for name, (rx, okr) in XU21.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU21: " + name)
    h = hinglish()
    if h and h.search(raw): out.append("HINGLISH (S8.90, check_unit8.py's list): " + h.search(raw).group(0))
    return out


XU22 = {
    "U22: in sync without the drift beside (S8.82)": (r"\bin sync\b", r"\bdrift\b|\bnever\b|\bnot\b|\brefused\b"),
    "U22: visible / not visible without the count (S8.81)": (r"\b(?:not (?:yet )?)?visible\b", r"\bcount\b|`[^`]*`|\b[01]\b"),
    "U22: the listener keeps the copy right / solves the dual write": (r"\blistener\b[^.;]*\b(?:keeps? (?:the copy|it) (?:right|correct|consistent)|solves?|fixes|guarantees?|makes? (?:it|the copy) safe)\b", None),
    "U22: PostgreSQL searches - Elasticsearch answered the search, PostgreSQL holds the rows (§4)": (r"\bPostgreSQL (?:searches|finds the dish|answers the search)\b|\bTiffinBox searches PostgreSQL\b", None),
    "U22: both or neither / a manager that spans both (unit 24's, a replica set's)": (r"\bboth or neither\b|\bspans? both\b", r"\bno manager spans both\b|\bnever\b|\bnot\b|\brefused\b|\bunit 24\b"),
    "U22: the dual write solved (any form)": (r"\bdual write\b[^.;]*\b(?:solved|fixed|handled|safe|closed|gone)\b|\b(?:solves?|fixes|handles?) the dual write\b", None),
    "U22: the copy is the source - the rows are (§4)": (r"\b(?:the )?index is the (?:source|system of record)\b|\bElasticsearch (?:is|holds) the (?:source|system of record)\b", r"\bnot\b|\bnever\b"),
}


def u22(s, raw):
    out = []
    for name, (rx, okr) in XU22.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU22: " + name)
    return out


XU23 = {
    "U23: a feature word (S8.86, u23check.py's FEATURE list)": (r"\b(?:powerful|fast|scalable|flexible|rich|robust|easy|modern|blazing|real-time|instant|smart|seamless|best|better|faster|right tool)\b", None),
    "U23: a ranking of stores (S8.86: no cell, no row ranks)": (r"\b(?:wins?|beats?|loses? to|outranks?|ranks? (?:first|higher|lower)|better than|worse than|the winner)\b", r"\bno row ranks\b|\bnever ranks?\b|\brefused\b|\bnot a ranking\b|\bnever a ranking\b|\bnor ranks?\b"),
    "U23: the table as a verdict (which database is best / pick / choose)": (r"\bthe table (?:shows|says|tells|proves|picks)\b[^.;]*\b(?:best|which (?:store|database) to (?:use|pick|choose)|the winner)\b|\b(?:pick|choose) (?:PostgreSQL|Postgres|Caffeine|Redis|MongoDB|Mongo|Elasticsearch)\b", r"\bnever\b|\bnot\b|\brefused\b|\bno\b"),
    "U23: unmeasured explained as a pass (a cell with no capture is not a store that would pass)": (r"\bunmeasured\b[^.;]*\b(?:because|since)\b[^.;]*\b(?:never|cannot|can't|would not|wouldn't|does not|doesn't) (?:fail|break)\b|\b(?:would|will) (?:pass|be fine|hold)\b", None),
    "U23: a later unit's capture (S8.97)": (r"`unit2[4-9]/[a-z0-9]+`", r"\brefused\b|\bnever\b|\bplant\b"),
}


def u23(s, raw):
    out = []
    for name, (rx, okr) in XU23.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU23: " + name)
    return out


# U24 (S8.89): the pinned hand-off sentence, md5 a6581dab7e33c458146b1f0e9cb114bc, is refused by two carried rules - R.224's call-back
# without its title (Course 13 is named by section, never by a lesson title: roadmap :922) and Part A's C8-20 rule (every "dual write"
# sentence must say "named" - written before unit 24 measured it). A line that IS that sentence, byte for byte, is not judged; any other
# wording of it is (the self-test shows the pinned sentence refused by the rules and a one-byte change of it refused as a line).
HANDOFF_MD5 = "a6581dab7e33c458146b1f0e9cb114bc"

XU24 = {
    "U24: Course 13 by a unit number, or 'solves' (S8.89: by section, 'comes back to')": (r"\bCourse 13\b[^.;]*\b(?:unit|lesson|episode|U)\s*\d+\b|\b(?:unit|lesson)\s*\d+ of (?:course|Course) 13\b|\bCourse 13\b[^.;]*\bsolv(?:es|ed|ing)\b|\bsolved in (?:course|Course) 13\b", None),
    "U24: the dual write atomic, both or neither, one transaction over both stores": (r"\bboth writes?\b[^.;]*\batomic(?:ally)?\b|\bdual write\b[^.;]*\batomic(?:ally)?\b|\batomic(?:ally)?\b[^.;]*\bboth (?:writes|stores)\b|\bone transaction (?:over|across|for) both\b", r"\bnever\b|\bnot\b|\brefused\b|\bno\b"),
    "U24: the chained manager as the answer (S8.88: deprecated, in the jar, not measured here)": (r"\bChainedTransactionManager\b[^.;]*\b(?:makes|keeps|gives|answers|use|works)\b", r"\bdeprecated\b|\brefused\b|\bnot\b|\bnever\b"),
    "U24: the listener or the hand-off as the answer to the dual write": (r"\bdual write\b[^.;]*\b(?:by|with) the listener\b|\blistener\b[^.;]*\b(?:answers|closes|ends)\b[^.;]*\bdual write\b", None),
    "U24: Boot keeps JPA's manager beside Mongo's (mtm: the bean list holds one)": (r"\bBoot keeps JPA'?s manager\b|\bJPA'?s manager stays\b|\bBoot adds Mongo'?s manager\b|\bBoot makes (?:a|the) Mongo manager\b", r"\bnot\b|\bnever\b|\bno\b|\brefused\b"),
    "U24: the misnamed manager called a fix or safe (S8.96: the row lost, no exception)": (r"\bnam(?:e|ed|ing) (?:it |Mongo'?s (?:bean|manager) )?`?transactionManager`?\b[^.;]*\b(?:fix(?:es)?|solves?|safe|works)\b", r"\bnot\b|\bnever\b|\brefused\b|\bfails?\b"),
}


def u24(s, raw):
    out = []
    for name, (rx, okr) in XU24.items():
        if re.search(rx, raw, re.I) and not (okr and re.search(okr, raw, re.I)): out.append("XU24: " + name)
    return out





import ast as _ast, os as _os
_T = _os.path.expanduser("~/Desktop/PromptVidya-Automation")
def _titles(f):
    for n in _ast.parse(open(_os.path.join(_T, f), encoding="utf-8").read()).body:
        if isinstance(n, _ast.Assign) and any(getattr(x, "id", "") == "TITLES" for x in n.targets): return _ast.literal_eval(n.value)
    raise SystemExit("no TITLES in " + f)
C9TITLES = list(_titles("java9_series.py").values()) + [_titles("java4_series.py")["30"]] + [_titles("java8_series.py")[k] for k in ("08", "14", "27")]
TITLES.extend(C9TITLES)   # R.224: Course 9's titles (units 01-26) and the call-backs' (Course 4 unit 30, Course 8 units 08, 14, 27), read off the series files

MOD = r"(?:J-P-A|J-D-B-C|JPA|JDBC|Redis|MongoDB|Elasticsearch|Commons|KeyValue|modules?)"
NUMW = (r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|"
        r"twenty(?:[- ](?:one|two|three|four|five|six))?)")
ORD = (r"(?:first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth|eleventh|twelfth|thirteenth|fourteenth|fifteenth|sixteenth|"
       r"seventeenth|eighteenth|nineteenth|twentieth|twenty[- ](?:first|second|third|fourth|fifth|sixth)|last)")
NEXT = r"(?:Course (?:9|nine|10|ten|13|thirteen)|the next course|the next one)"

XFAM_S5 = {
    "S5: the umbrella as the actor - Spring Data (no module named) runs / sends / writes / generates / handles / caches / turns it into (S8.99, contract §4.2, §10)":
        (r"\bSpring Data\b(?!(?:'s)? " + MOD + r"\b)[^.;]*?\b(?:handles?|generates?|implements?|takes care of|does (?:it|this|that|the work)|for you|figures? out|"
         r"sends?|runs?|writes?|executes?|queries|caches?|creates?|builds? (?:the|a|your) (?:query|request|SQL|statement|method)|talks? to|turns?\b[^.;]*\binto)\b", None),
    "S5: Commons as a runtime - Commons sends / runs / queries / writes, with no module between (S8.99: the parser is Commons', the request is the module's)":
        (r"\bCommons\b(?:'s?)?(?:(?!\b(?:module|modules|J-P-A|J-D-B-C|JPA|JDBC|Redis|MongoDB|Elasticsearch)\b)[^.;])*?\b(?:sends?|runs?|executes?|talks? to|queries|writes?|caches?)\b",
         r"\bCommons\b(?:'s?)? (?:never|does not|doesn't) (?:sends?|runs?|executes?|quer(?:y|ies)|writes?|talks?)\b"),
    "S5: one API, every store - every store supports / works the same on every store / store-agnostic / portable / swap the database (S8.100)":
        (r"\b(?:every|all|each|any) (?:of )?(?:the )?(?:stores?|modules?|databases?)(?: here)? (?:supports?|accepts?|runs?|understands?|handles?) (?:the same|every|all|any)\b"
         r"|\bsupported (?:by|on|in) (?:every|all|each|any) (?:stores?|modules?|databases?)\b"
         r"|\b(?:works|behaves|runs|acts|answers) the same (?:on|for|with|in|across) (?:every|all|any|each)\b|\b(?:store|database|vendor)[- ]agnostic\b|\bportab(?:le|ility)\b"
         r"|\bswap(?:ping)? (?:the|your|a) (?:database|store)\b|\bone API for (?:every|all|any)\b|\bwrite (?:it )?once\b|\bany (?:store|database) you (?:like|want)\b|\binterchangeabl[ey]\b", None),
    "S5: slogans - magic / seamless / unified / just works / out of the box / for free / production-ready (contract §10)":
        (r"\bmagic(?:al|ally)?\b|\bseamless(?:ly)?\b|\bunified\b|\bjust works\b|\bout of the box\b|\bfor free\b|\bproduction[- ]ready\b|\bbattle[- ]tested\b|\bbest[- ]in[- ]class\b|\bpowerful\b|\belegant(?:ly)?\b", None),
    "S5: automatically - the actor hidden (name the module, the factory or Boot's auto-configuration class)":
        (r"\bautomatic(?:ally)?\b|\bauto-?magic(?:ally)?\b", None),
    "S5: every copy kept in step - all stores in sync / consistent / every store gets the write (S8.106, R.442)":
        (r"\b(?:all|every|each|the) (?:five |four |other )?(?:stores?|copies|databases?) (?:stay|stays|are kept|kept|remain|remains|is kept|get|gets|receive|receives) (?:in sync|consistent|in step|up to date|the (?:same )?write)\b"
         r"|\b(?:eventually |strongly )?consistent\b(?![^.;]*\b(?:not|never|no)\b)|\bin step\b|\bevery other store\b", None),
    "S5: scale and speed verdicts - scales / scalable / high-performance / performant / blazing":
        (r"\bscal(?:es|able|ability|ing)\b|\bhigh[- ]performance\b|\bperformant\b|\bblazing\b|\blightning\b|\bat scale\b", None),
    "S5: REST verdicts - RESTful / best practice / the right way (Course 9 measures, U28 hands over)":
        (r"\bRESTful\b|\bbest practices?\b|\bthe right way\b|\bproperly designed\b|\bwell[- ]designed\b|\bclean API\b", None),
    "S5: a forward reference by number or ordinal (S8.109, roadmap §3b: Course 9's lessons by title only)":
        (r"\b" + NEXT + r"(?:'s)? (?:unit|lesson|video|episode)s? " + NUMW + r"\b"
         r"|\b(?:unit|lesson|video)s? " + NUMW + r" (?:of|in) " + NEXT + r"\b"
         r"|\b" + ORD + r"(?: \w+)? (?:unit|lesson|video)s? (?:of|in) " + NEXT + r"\b"
         r"|\b" + NEXT + r"(?:'s)? " + ORD + r" (?:unit|lesson|video)s?\b"
         r"|\bC(?:9|10|13) ?U\d+\b", None),
    "S5: a fragment said to be generated or derived; Spring Data said to write your method (S8.103)":
        (r"\bfragment(?:'s)? (?:method|implementation)s? (?:is|are) (?:generated|derived)\b"
         r"|\bSpring Data(?: " + MOD + r")? (?:writes|generates|derives|implements|creates) (?:your|the|a) (?:hand-written |custom |fragment(?:'s)? )?(?:method|implementation|class|Impl)\b"
         r"|\bgenerates? the (?:Impl|implementation class)\b", None),
    "S5: Caffeine said to run under \"dev\" - either word order (S8.105: one jar, two runs)":
        (r"\bCaffeine\b[^.;]*\b(?:under|in|on|during) (?:the )?\"?dev\"?\b|\b(?:under|in|on|during) (?:the )?\"?dev\"?\b[^.;]*\bCaffeine\b"
         r"|\bthe dev run\b[^.;]*\bCaffeine\b|\bCaffeine\b[^.;]*\bthe dev run\b",
         r"\bbuilds no Caffeine cache\b|\bCaffeine is absent\b|\bno Caffeine (?:cache|manager)\b"),
    "S5: safety verdicts - safe / secure / not vulnerable / unaffected (RED #12: the advisories are documentation, never a verdict)":
        (r"\b(?:safe|secure|not vulnerable|unaffected|immune|risk-free|patched)\b", None),
}

# what dur8 (plural "seconds", "ms", "milli…", "minutes") and TIMEPAT_S3/S4/S4B do not already mask in Section 5's captures
TIMEPAT_S5 = re.compile(r"\bTime elapsed: ?[\d.]+ ?s\b|\bstarted in PT(?:\d+H)?(?:\d+M)?[\d.]+S\b|\bexpireAfter(?:Write|Access)=\d+[smhd]?\b|\btime-to-live:\s*\d+[smhd]?\b"
                        r"|\bkitchen-order-ttl:\s*\d+[smhd]?\b|\bTotal time:\s+[\d.:]+ ?(?:s|min)\b|\bin \d+ ?ms\b|\b(?:Started|Finished) [^\n]*? in [\d.]+ (?:seconds|ms)\b"
                        r"|\bprocess running for [\d.]+\b|\"millis\"\s*:\s*\d|\bmillis=\d")

RED1 = [  # RED-C8-S5 #1's sentences - each must HIT (before: 0 of 8 on the probe's xfam5.py)
    "Spring Data sends the query to PostgreSQL.", "Spring Data writes your method.", "Every store supports the same derived names.",
    "Under dev, Caffeine holds the customer list.", "The dev run caches the customer list in Caffeine.",
    "Commons parses the name and sends the query to PostgreSQL.", "Course nine's lesson four adds the key.", "The second lesson of Course nine measures it.",
]
RULES = [  # the rules' own named sentences, said as a script would (cross-family: none is a family's own wording)
    "Spring Data runs the query on PostgreSQL.",                          # S8.99
    "Spring Data turns the method's name into SQL.",                     # S8.99
    "All the modules support every derived name.",                       # S8.100 ("every store supports")
    "Each store supports the same method names.",                        # S8.100
    "Spring Data writes the fragment's method.",                          # S8.103
    "The dev run keeps the customer list in Caffeine and Redis.",        # S8.105 (both as one run)
    "In dev, Caffeine and Redis both cache the list.",                   # S8.105
    "Every other store gets the write in the same transaction.",         # S8.106 (RED #4's wider spine)
    "Lesson three of the next course fixes the PATCH.",                  # S8.109
    "The next course's fourth lesson adds an idempotency key.",          # S8.109
    "TiffinBox is not vulnerable to either advisory.",                   # RED #12
    "With no string queries, the app is safe.",                          # RED #12
]
OWN = [  # the probe's 22 plants, kept
    "Spring Data handles the query for you.", "Spring Data generates the implementation.", "Commons sends the query to PostgreSQL.",
    "The same repository works the same on every store.", "Spring Data makes your code store-agnostic.", "You can swap the database without changing a line.",
    "One API for every database.", "It is magic.", "The fragment slots in seamlessly.", "Spring Data automatically finds your class.",
    "All five stores stay in sync.", "The copies are eventually consistent.", "TiffinBox scales across five stores.", "The API is RESTful.",
    "That is best practice.", "Course 9's lesson 4 adds the key.", "Unit 4 of Course 9 measures it.", "The fragment's method is generated.",
    "Caffeine caches the customers under dev.", "A powerful repository layer.",
]
PLANTS = RED1 + RULES + OWN
NEAR = [  # one near miss per family at least, each a measured sentence of the brief or its exact shape
    "Spring Data J-P-A sends PostgreSQL one statement for findByName; Spring Data J-D-B-C sends two, the customer and her pauses.",
    "Six repositories in TiffinBox, five Spring Data modules, one root: every interface ends at Spring Data Commons' Repository, Commons' parser reads each method's name the same way, and each module turns that name into its own store's request.",
    "Commons parses the name; each module writes its own store's request.", "Commons never sends a command; each module does.",
    "Each module writes a different request for the same name.", "The same name parses the same way on all six domain types.",
    "The default run loads ninety-three Caffeine classes; the dev run loads two and builds no Caffeine cache.",
    "On the default run Caffeine holds the customer list.", "Under dev Caffeine is absent: no Caffeine cache.",
    "PostgreSQL is the system of record; every copy is written after its commit.", "The second write lands in the index.",
    "So, the next course: Course nine of nineteen, REST APIs Done Right, twenty-six lessons in five sections.",
    "It opens with What REST Actually Says, then Resources, URIs and the Method Table, then Status Codes That Mean Something.",
    "This course pins a sentence for the next one's lesson called Resources, URIs and the Method Table, byte for byte.",
    "The lesson called Idempotency, Safety and Retries adds the key.", "Spring Security comes later in the track.",
    "Boot's auto-configuration builds the RedisCacheManager.", "The hand-written method runs; the derived ones still go to the store.",
    "Name the class wrong, and Spring Data MongoDB reads the method's name instead.", "The start stops at the first call's store.",
]
TIME_HIT = ("Time elapsed: 3.982 s", "started in PT3.48S", "started in PT1M34.764508S", "started in PT2M24.78502S", "expireAfterWrite=10m", "time-to-live: 10m",
            "kitchen-order-ttl: 10m", "Total time:  12.345 s", "Finished Spring Data repository scanning in 23 ms.", "\"millis\" : 12")
TIME_PASS = ("18 + 14", "heap_max_in_bytes 536870912", "exit 1", "Ravi-1", "TTL -1", "9 lines", "the second write", "PT1M34 is a token, not a sentence")

def hits(s, fam=None):
    fam = fam or XFAM_S5; out = []
    for name, (rx, okr) in fam.items():
        if re.search(rx, s, re.I) and not (okr and re.search(okr, s, re.I)): out.append("XFAM_S5: " + name.split(" - ")[0])
    return out

def selftest():
    bad = [(p, "no hit") for p in PLANTS if not hits(p)] + [(n, hits(n)) for n in NEAR if hits(n)]
    bad += [(t, "TIMEPAT_S5 misses") for t in TIME_HIT if not TIMEPAT_S5.search(t)]
    bad += [(t, "TIMEPAT_S5 over-matches") for t in TIME_PASS if TIMEPAT_S5.search(t)]
    per = {}
    for p in PLANTS:
        for h in hits(p): per[h] = per.get(h, 0) + 1
    missing = [n for n in XFAM_S5 if ("XFAM_S5: " + n.split(" - ")[0]) not in per]
    if missing: bad.append(("families with no plant", missing))
    return bad, per

# ---- end of the xfam5b.py slice ----------------------------------------------------------------------------------------------


def s5(s, raw):
    out = []
    for name, (rx, okr) in XFAM_S5.items():
        if re.search(rx, s, re.I) and not (okr and re.search(okr, s, re.I)): out.append("XFAM_S5: " + name.split(" - ")[0])
    if TIMEPAT_S5.search(raw): out.append("TIMEPAT_S5: " + TIMEPAT_S5.search(raw).group(0))
    return out














def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("R.388's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in COST.finditer(s): out.append("R.355: a cost word: " + w.group(0))
    if WORKS.search(s): out.append("R.375: \"the cache works\" - a hit is two witnesses from one run, never a slogan")
    if OWNER.search(s) and not OWNNEG.search(s): out.append("R.348: the abstraction credited to Spring Data or Hibernate: " + OWNER.search(s).group(0))
    if HITW.search(s) and not STORE.search(raw): out.append("R.376: a hit or a cached read without its store, its manager or the database that answered")
    if WARNS.search(s): out.append("R.377: Spring warns - no WARN line is captured for the cache in this unit")
    if LRU.search(s): out.append("R.385: \"LRU\" / \"the same eviction\" for Caffeine - the two maps drop different customers")
    if POLICY.search(s): out.append("R.385: Caffeine's policy named - the receipt prints none")
    if METER.search(raw) and not NAMED.search(raw): out.append("R.384: a meter sentence without spring.cache.cache-names")
    if PUTS.search(raw) and not PUTSOK.search(raw): out.append("R.375: cache_puts_total voiced")
    if HARNUM.search(raw) and not HARLAB.search(raw): out.append("R.392: a harness or copy number without its label")
    if RMF.search(raw): out.append("R.387: rm -f without -v")
    if PLNOAM.search(raw): out.append("R.391: -pl tiffinbox-web without -am")
    if ASYNC.search(raw): out.append("flag 5: \"Redis is asynchronous\" - the writer's calls are")
    if REDISW.search(raw) and REDISOP.search(raw) and not WRITER.search(raw) and not IDXOK.search(raw): out.append("R.378: a Redis evict / clear / read-after-write sentence without the writer named")
    if BYTES.search(raw) and REDISW.search(raw) and not (BYTESOK.search(raw) and CLASSOK.search(raw)): out.append("R.379: the bytes without redis-cli's GET and the class read back")
    if SILCREDIT.search(raw) or (SILENT.search(raw) and re.search(r"\brenamed\b", raw, re.I) and not SILOK.search(raw)): out.append("R.379/R.370: the silence credited to Redis or JSON, not the serializer's own setting")
    if H13.search(raw) and not H13OK.search(raw): out.append("R.392: the harness's keys, fills or bytes without its label")
    if SYNCX.search(raw) and not SYNCOK.search(raw): out.append("R.382: sync said to work across servers, JVMs or processes - it is in one JVM")
    if NULLX.search(raw) and QUIET.search(raw) and not THROWS.search(raw): out.append("R.383: cache-null-values=false called not cached or quieter - it throws")
    if ADDEV.search(raw) and not ADDOK.search(raw): out.append("RED #8: add said to evict the customer cache - it evicts customers only")
    if EVERY.search(s): out.append("R.302: a capture's number typed in prose: " + EVERY.search(s).group(0))
    if TTLT.search(s): out.append("R.380: a TTL said as a time")
    if HEALTH.search(raw) and not HEALTHOK.search(raw): out.append("R.386: a health sentence without the default run that has no Redis")
    if DSTORE.search(raw) and not DSTOREOK.search(raw): out.append("C8-15: Redis as a datastore - this unit is Redis as a cache")
    if DOWNCTX.search(raw) and DOWNNV.search(raw): out.append("R.387: Compose down without -v")
    if PULLV.search(raw): out.append("flag 7: pull_policy or a digest as the viewer's compose.yaml line")
    if DRKEY.search(raw) and not DRKEYOK.search(raw): out.append("flag 7: a spring.data.redis key in the anchor's YAML")
    if PAGE.search(s): out.append("R.389: a cached read set beside the page")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if PORT.search(raw): out.append("R.319: a port printed raw: " + PORT.search(raw).group(0))
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if SQL.search(raw): out.append("R.225/R.365: a typed SQL string in the prose")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    if C83X.search(raw) and C83 not in raw and re.sub(r"^[>*\s]+|[*\s]+$", "", raw) not in C83: out.append("C8-3: a second-level-cache sentence that is not Course 7's, byte for byte")
    if NN.search(raw): out.append("R.381: N threads, N reads for 16 or 32 - more than one in every round, up to all of them")
    if H2ST.search(raw) and re.search(r"\d", s) and not H2OK.search(raw): out.append("R.381: a stampede number from H2")
    if HOLD.search(raw) and not HOLDOK.search(raw): out.append("READ FIRST 14: a hold or a sleep in the stampede")
    if CLEARI.search(raw) and not CLEAROK.search(raw): out.append("unit 11's writer: clear() is not immediate on Boot's default writer")
    if DOCKUNP.search(raw): out.append("R.344: the docker CLI without its socket (docker -H)")
    if NUM12.search(s): out.append("R.302: a capture's number typed in prose: " + NUM12.search(s).group(0))
    if TTLT2.search(s): out.append("R.380: a TTL said as a time")
    out.extend(s3(s, raw))
    out.extend(s4(s, raw))
    out.extend(u19(s, raw))
    out.extend(u20(s, raw))
    out.extend(s4b(s, raw))
    out.extend(u21(s, raw))
    out.extend(u22(s, raw))
    out.extend(u23(s, raw))
    out.extend(u24(s, raw))
    out.extend(s5(s, raw))
    out.extend(s9s1(s, raw))
    out.extend(u04(s, raw))
    return out


CASES = [("Elasticsearch is real-time.", 1), ("The dish is instantly searchable.", 1), ("A document is immediately searchable.", 1),
         ("The relevant dishes come first.", 1), ("Relevance decides it.", 1), ("The relevance score, read off `_explain`.", 0), ("It gives the best match.", 1), ("A better match.", 1),
         ("Smart search.", 1), ("Elasticsearch understands veg.", 1),
         ("A prefix query fixes veg.", 1), ("A prefix finds veg's dishes.", 1), ("A prefix for veg finds four, two of them vegan.", 1),
         ("A prefix for veg finds four, one of them the vegan box.", 0), ("Fuzziness two on veg finds the egg dish and the vegan box.", 0),
         ("The index stays in sync.", 1), ("The copy is always in sync.", 1), ("It never drifts.", 1), ("Automatically synced.", 1),
         ("Elasticsearch is the best database for search.", 1), ("The right tool for the job.", 1), ("Use Elasticsearch for search.", 1), ("NoSQL is faster.", 1), ("SQL doesn't scale.", 1),
         ("A vector store holds embeddings.", 1), ("A vector index is a kind of index this course does not build.", 0),
         ("The dual write is solved.", 1),
         ("ChainedTransactionManager makes both writes atomic.", 1), ("With security off the port is safe.", 1), ("Security off is fine here.", 1),
         ("Elasticsearch finds it in one second.", 1), ("It answers in a second.", 1), ("In 1 second.", 1), ("The search answers in 2s.", 1),
         ("Make that count read one without a second write.", 0), ("A second-level cache.", 0), ("The second write lands in the index.", 0),
         ("The response says `\"took\":12`.", 1), ("The response says `\"took\":<n>`.", 0), ("The log says `took[12ms]`.", 1), ("The default `\"refresh_interval\":\"1s\"`.", 1),
         ("The idle `\"after\":\"30s\"`.", 1), ("`connection-timeout 1s`.", 1), ("`socket-timeout 30s`.", 1), ("The node's `start_time_in_millis`.", 1), ("Its `uptime_in_millis`.", 1),
         ("The poller's `request_interval = 10m`.", 1), ("Its `jitter = 5m`.", 1), ("GeoIP's `poll.interval = 3d`.", 1), ("A line `\"@timestamp\":\"2026-11-23\"`.", 1),
         ("The heap, `heap_max_in_bytes 536870912`.", 0), ("The analyzer gives `9 tokens`.", 0), ("The start ends with `exit 1`.", 0),
         ("veg matches vegetarian.", 1), ("With the analyzer dish, veg matches vegetarian's dish.", 0), ("Elasticsearch finds it.", 1), ("Fuzzy fixes it.", 1),
         ("The synonym fixes it.", 1), ("The synonym fixes it: the vegetarian box, one hit.", 0),
         ("Elasticsearch is faster than PostgreSQL.", 1), ("The index scales.", 1), ("It phones home.", 1), ("TiffinBox searches PostgreSQL.", 1),
         ("`@Document` creates the index.", 0), ("@Document creates the index.", 1), ("The health key alone builds no client.", 1),
         ("Run `docker exec c8u21-es curl`.", 1), ("It binds 0.0.0.0:9200.", 1),
         ("A Vegetarian Thali.", 1), ("The vegetarian lunch box.", 0),
         ("Boot configures the Mongo transaction manager.", 1), ("Boot makes no MongoTransactionManager.", 0), ("Transactions work on it.", 1),
         ("With MongoTransactionManager on a replica set the rollback works.", 0), ("@Indexed makes the index.", 1), ("@Indexed makes the index once auto-index-creation is true.", 0),
         ("TiffinBox's orders send one command per reference.", 1), ("The harness's orders send one command per reference.", 0),
         ("A JDBC transaction manager left the first document.", 1), ("The probe ran a JDBC transaction manager.", 0),
         ("The orders collection is a fourth witness.", 1), ("A copy, never a fourth witness.", 0), ("The pipeline sums any field.", 1),
         ("Mongo swallows the error.", 1), ("The derived finder is an N+1.", 1), ("The revenue pipeline groups it.", 1),
         ("MongoDB is schemaless.", 1), ("A document needs no schema.", 1), ("Web scale.", 1), ("Mongo is faster here.", 1), ("PostgreSQL scales better than the document.", 1),
         ("Joins are slow.", 1), ("A reference is N+1 in Mongo.", 1), ("One command per reference.", 0), ("The write is atomic.", 1), ("The menu is safe.", 1),
         ("With Mongo's transaction manager on a replica set the two writes commit or neither does, atomic.", 0), ("With a JDBC transaction manager on a standalone the write is atomic.", 1),
         ("mongosh runs with telemetry off.", 1), ("mongosh sends nothing.", 1), ("mongosh runs in a container with no network; its interface list is lo.", 0),
         ("@Indexed creates the index.", 1), ("Mongo mangles the id.", 1), ("The start gives up after thirty seconds.", 1), ("The driver waits 30000 ms.", 1),
         ("The start stops once the driver gives up looking.", 0), ("Set management.health.mongo.enabled to false.", 1), ("management.health.mongo.enabled is a dead name, never written.", 0),
         ("Today's menu is a document.", 1), ("The default run needs Mongo.", 1), ("The default run never touches Mongo with the health key.", 1), ("The default run needs no Mongo.", 0),
         ("Run docker exec c8u18-mongo mongosh.", 1), ("The fill drops the collection.", 1), ("The fill deletes, never a dropCollection.", 0),
         ("The profiler shows executionTimeMillis.", 1), ("Its `_id` is ObjectId('6aff8b7764dd9c4a7e6e71b9').", 1), ("serverSelectionTimeoutMS=30000 in the URI.", 1),
         ("The profiler shows one query op on the menu.", 0), ("system.profile shows a query op.", 0), ("MongoDB answers one query for the menu.", 1), ("The op is `query`, one document.", 0),
         ("Course 13's *Delivery Guarantees* defines the words.", 0), ("Pub/Sub guarantees delivery.", 1), ("Streams give reliable delivery.", 1), ("At-most-once on Pub/Sub.", 1), ("The stream is durable.", 1),
         ("Pub/Sub reports receivers 0, and the message is in no list and nowhere in Redis.", 0),
         ("Acknowledged entries are removed.", 1), ("An acknowledged entry is deleted from the stream.", 1), ("An acknowledged entry stays in the stream: `XLEN` is unchanged.", 0),
         ("Redis is like Kafka.", 1), ("Unlike Kafka, Redis keeps one stream.", 1), ("Kafka is better here.", 1), ("Course 13's *Choosing a Broker* takes the broker comparison up.", 0),
         ("Course 13 compares the brokers.", 1),
         ("The consumer crashed.", 1), ("A crash with `appendonly no` was not measured.", 0),
         ("The receipt sends SIGINT to the consumer.", 1), ("The harness holds c1 (planted), and the receipt sends SIGINT.", 0),
         ("The writer uses Map.of.", 1), ("A Map.of writer is refused: its order moved.", 0),
         ("The early message is lost.", 1), ("The dual write loses the entry, measured.", 1), ("The dual write is named, not measured.", 0),
         ("The id was 1795083337520-0.", 1), ("c1 reads five.", 1), ("The harness's consumer c1 reads five.", 0), ("C3 is the third anchor change.", 0),
         ("`sync` works across servers.", 1), ("With `sync = true` one read serves every waiting thread across JVMs.", 1),
         ("`sync` is said in one JVM; a cross-process claim needs a two-JVM capture, not made here.", 0),
         ("`cache-null-values=false` means the empty answer is not cached.", 1), ("`cache-null-values=false` makes a quieter cache.", 1),
         ("`cache-null-values=false` throws `IllegalArgumentException` at every call - not a quieter cache.", 0),
         ("`add` evicts `customer` too.", 1), ("`add` evicts nothing in `customer`.", 0),
         ("One read, 1 in every round.", 1), ("The lookup ran, invocations 3.", 1),
         ("The key `customer::Ravi` holds her.", 0),
         ("A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.", 0),
         ("A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old values.", 1),
         ("The entry leaves after a few seconds.", 1), ("The list expires quickly.", 1), ("A short time to live.", 1), ("Briefly cached.", 1),
         ("In a moment the key is gone.", 1), ("The time to live the configuration sets runs out: keys go to none, and the read reaches the table.", 1),
         ("With 16 threads, 16 reads.", 1), ("32 threads give 32 reads.", 1), ("16 threads: more than one in every round, up to all of them.", 0),
         ("On H2 the stampede gives 6 reads for 8 threads.", 1), ("H2 never runs the stampede.", 0),
         ("The stampede uses a sleep to hold the threads.", 1), ("The stampede has no hold: no sleep anywhere.", 0),
         ("`clear()` is immediate on Redis with Boot's own writer.", 1), ("On Caffeine `clear()` empties the cache before it returns.", 0),
         ("Run `docker run redis`.", 1), ("Run `docker -H \"$DH\" run --pull never …`.", 0),
         ("The keys go 1 → 0.", 1), ("Invocations 1 -> 2.", 1), ("The cached read says 2.", 1), ("The tests: 18 + 5.", 1), ("2 vs 3.", 1),
         ("A cache hit is faster.", 1), ("It expires after a while.", 1), ("The cache works.", 1), ("Spring Data caches the list.", 1),
         ("Hibernate's cache keeps it.", 1), ("Not Hibernate's second-level cache, and not Spring Data.", 0),
         ("Spring warns you about it.", 1), ("Caffeine is LRU.", 1), ("Caffeine evicts the least recently used entry.", 1),
         ("The same eviction, industrialised.", 1), ("The same customer leaves.", 1), ("Caffeine runs Window TinyLFU.", 1),
         ("Same idea, a ceiling: Caffeine drops another customer.", 0),
         ("The prometheus line shows the hits.", 1), ("The meters appear for the caches named at the start, `spring.cache.cache-names`.", 0),
         ("The customers cache, in the JVM, Caffeine's.", 0),
         ("`cache_puts_total` reads the loads.", 1), ("`cache_puts_total` is printed and not voiced.", 0),
         ("TiffinBox keeps `[Meera, Nina, Ravi]`.", 1), ("The harness on Caffeine's own API keeps `[Meera, Nina, Ravi]`.", 0),
         ("Run `docker rm -f c8u10-pg`.", 1), ("Run `docker -H \"$DH\" rm -fv c8u10-pg`.", 0),
         ("Build with `mvn -o package -pl tiffinbox-web`.", 1), ("Build with `mvn -o package -pl tiffinbox-web -am`.", 0),
         ("The hit count is hit 4.", 1), ("Caffeine counts 4 hits.", 1), ("50 of 50 pairs.", 1), ("The lists read [1, 0, 0, 0, 0].", 1),
         ("The verify runs 23 tests.", 1), ("18 on H2.", 1), ("A cache hit costs no statement.", 1), ("A cache hit in the JVM, Caffeine's, costs nothing.", 0),
         ("Hibernate generates the SELECT.", 1), ("The URL was `jdbc:postgresql://localhost:32771/test`.", 1), ("Ports 20490-20499.", 0),
         ("The pin is eedf32a336609f92de214f7beba6d2ec.", 1), ("As Course 2 showed.", 1),
         ("As Course 5's *Docker Compose for Development* showed.", 0), ("Spring Boot 4.1.2 and Caffeine 3.2.4.", 0),
         ("The numbers are in the values block.", 0), ("It took two seconds.", 1), ("`@Cacheable` on `findAll`.", 0),
         ("Redis is asynchronous.", 1), ("The writer Boot builds over Lettuce writes asynchronously; Redis does not.", 0),
         ("On Redis the read right after `@CacheEvict` is stale.", 1), ("On Redis, with the writer Boot builds over Lettuce, the read right after `@CacheEvict` is stale.", 1), ("On Redis, with the writer Boot builds over Lettuce, the read after `@CacheEvict` is stale.", 0),
         ("The bytes Redis keeps are JSON.", 1), ("The bytes Redis keeps, by redis-cli's `GET`, beside the class Java read back.", 0),
         ("Redis hides the renamed field.", 1), ("The renamed field comes back empty, silently.", 1),
         ("The renamed field comes back empty, silently: the serializer's own setting turns `FAIL_ON_UNKNOWN_PROPERTIES` off.", 0),
         ("The key `customers::SimpleKey []` holds the list.", 0),
         ("The entry expires after two seconds.", 1), ("The time to live the configuration sets, read back by redis-cli.", 0),
         ("`/actuator/health` answers 503.", 1), ("With no Redis, Redis's indicator on, `/actuator/health` answers DOWN.", 0),
         ("Redis as a datastore.", 1), ("Redis as a cache, not a datastore (C8-15, Section 3).", 0), ("Section 3 is Redis as a datastore.", 0),
         ("Redis mangles the key.", 1), ("The serializer writes Java serialization's bytes before the key.", 0),
         ("Under dev, `/leaderboard` answers 500 while health stays 200.", 1), ("The probe's `lb` 500 beside a 200 is struck.", 0),
         ("The default run needs Redis.", 1), ("The default run still needs no Redis.", 0),
         ("Redis runs one query per order.", 1), ("Redis answers one `ZINCRBY` per order.", 0), ("The leaderboard costs an N+1.", 1),
         ("The board is durable.", 1), ("Nothing is guaranteed.", 1), ("A new container loses nothing the start does not refill.", 0),
         ("The command times out.", 1), ("The board is read later.", 1), ("It waits for Redis.", 1),
         ("redis-cli alone reads the board.", 1), ("Java and redis-cli read the same board.", 0),
         ("A cache holds what the method last returned; a write that never passes through the cache leaves it serving the old value.", 0),
         ("A cache holds what the method last returns; a write that never passes through the cache leaves it serving the old value.", 1),
         ("The leaderboard expires.", 1),
         ("On Redis, with keyspace events off, the index is stale.", 0), ("On Redis the cached list is stale.", 1),
         ("The repository cleans up after itself.", 1), ("A fresh start cleans the stale index.", 1), ("With ON_STARTUP the repository cleans the index.", 1),
         ("With ON_STARTUP a running repository removes the ids once Redis tells it a hash is gone.", 0), ("The receipt reads the clean sets after a settle.", 1),
         ("The receipt polls a count, never a settle.", 0), ("A `SINTER` is one query.", 1), ("The finder runs one statement per id.", 1), ("A finder is one `SINTER` and one `HGETALL` per id.", 0),
         ("The key `o1` holds Ravi's order.", 1), ("The harness's order `o1` holds Ravi's.", 0), ("The start answers 500 while health stays 200.", 1),
         ("The order's hash is gone: EXISTS zero.", 0), ("The order expired.", 1), ("Its expiry ends it.", 1), ("The time to live the entity carries ends.", 0), ("Unit 17, *Distributed Locks and Rate Counters*, names it.", 0), ("What differed from the brief.", 0), ("The Section 2 brief's ⚑11.", 0), ("The board is held briefly.", 1), ("A brief hold.", 1), ("A distributed lock holds it.", 1), ("The fill runs immediately.", 1), ("The board, read right after the start.", 1),
         ("Run `docker compose -p c8-unit11 down`.", 1), ("Run `docker -H \"$DH\" compose -p c8-unit11 down -v`.", 0),
         ("The viewer's `compose.yaml` carries `pull_policy: never`.", 1), ("The receipts' copy carries `pull_policy: never`.", 0),
         ("`spring.data.redis.port` is set in `application-dev.yaml`.", 1), ("No `spring.data.redis.port` is set in `application-dev.yaml`.", 0),
         ("The key's TTL -1.", 1), ("Stale in 10 of 10 rounds.", 1), ("The libraries are 122.", 1), ("Redis 8.10.3, by the digest.", 0),
         ("The Lua release makes the lock safe.", 1), ("Redlock is broken.", 1), ("Redlock is safe.", 1), ("The lock is safe.", 1),
         ("The lock expires after two seconds.", 1), ("Its expiry ends the lock.", 1), ("`sync` works across servers with the copy.", 1),
         ("The Lua release fixes the lock.", 1), ("The Lua release stops A's delete of B's lock, not the two holding it together.", 0),
         ("Holder A outlived its lock.", 1), ("When the harness holds A past its lock's time to live (planted), B acquires.", 0),
         ("The program holds A past its lock's time to live on purpose.", 0),
         ("The release is atomic.", 1), ("The Lua script makes the read and the delete atomic.", 0),
         ("Run `SET k v PX 3000 NX`.", 1), ("redis-cli `TTL` reads `-1`.", 0), ("`EXPIRE k 60 NX` answers 1.", 1), ("`PTTL` reads a positive count, masked.", 0),
         ("Kleppmann argued against it.", 1), ("§4 documentation, from memory, unchecked: Kleppmann's essay.", 0),
         ("Holder B acquires.", 1), ("The harness's holder B acquires.", 0), ("The counter allows five.", 1), ("The harness's counter allows five.", 0),
         ("A distributed lock holds the slot.", 1), ("A distributed lock — one key many processes agree to wait on.", 0),
         ("Across two JVMs one read.", 1), ("Across two JVMs, with the shipped writer, one read - `customers~lock` in Redis meanwhile (`sync`).", 0),
         ("It works across servers.", 1), ("Clock drift breaks it.", 1), ("The sketch has no clock-drift term.", 0),
         ("Kafka keeps offsets.", 1), ("Course 13's *Choosing a Broker* takes Kafka up.", 0),
         ("The index stays in sync with the rows.", 1), ("Kept in sync by the listener.", 1), ("The index is in sync.", 1), ("A copy, in sync until its drift beside it says not.", 0),
         ("The document is visible.", 1), ("The new dish is not yet visible.", 1), ("The count reads `0`: the document is not visible to that count.", 0),
         ("The listener keeps the copy right.", 1), ("The listener solves the dual write.", 1), ("The dual write is handled.", 1), ("The listener handles the dual write.", 1),
         ("The dual write is named and handed to unit 24.", 0), ("PostgreSQL searches the dishes.", 1), ("TiffinBox searches PostgreSQL.", 1),
         ("Elasticsearch answers the search; PostgreSQL holds the rows.", 0), ("The write is both or neither.", 1), ("A manager spans both.", 1),
         ("Two stores, two writes, and no manager spans both.", 0), ("The index is the source.", 1), ("The index is not the source.", 0),
         ("Paneer bowl is the new dish.", 1), ("The new dish is the mushroom noodle bowl.", 0)]
CASES += [("PostgreSQL wins the cost column.", 1), ("Redis beats MongoDB here.", 1), ("MongoDB is better than PostgreSQL at the rename.", 1),
          ("No row ranks a store.", 0), ("The table shows which database is best.", 1), ("Pick Elasticsearch for the dishes.", 1),
          ("Use Elasticsearch for search.", 1), ("The right tool for the job.", 1), ("The best database here.", 1), ("NoSQL is faster.", 1), ("SQL doesn't scale.", 1),
          ("Vector search is next.", 1), ("A vector index is a kind of index this course does not build.", 0), ("Elasticsearch has powerful full-text search.", 1),
          ("Elasticsearch finds it in one second.", 1), ("A cell is unmeasured because PostgreSQL would pass.", 1), ("A cell is unmeasured where no capture of this course prints it.", 0),
          ("The cell cites `unit24/dual`.", 1), ("The plant names `unit24/dual`, and the checker refuses it.", 0),
          ("A failure mode as a cell: what broke, the capture that showed it, and the number it printed.", 0)]
CASES += [("ChainedTransactionManager makes both writes atomic.", 1), ("ChainedTransactionManager is in the jar, deprecated, and this unit does not teach it.", 0),
          ("Boot keeps JPA's manager.", 1), ("Boot keeps JPA's manager beside Mongo's.", 1), ("Boot does not keep JPA's manager: the bean list holds one name.", 0),
          ("The dual write is solved in unit 21 of course 13.", 1), ("Course 13 solves the dual write.", 1), ("Course 13 unit 21 comes back to it.", 1),
          ("Course 13, Messaging and Integration, comes back to this dual write with an outbox, in its section on patterns that matter.", 1),
          ("The dual write is solved by the listener.", 1), ("The listener closes the dual write.", 1),
          ("Still two commits, one after the other.", 0), ("Naming Mongo's manager transactionManager fixes it.", 1),
          ("Naming Mongo's manager transactionManager fails the check.", 0), ("Both writes are atomic under the two managers.", 1),
          ("Under JPA's manager, the failure after both writes leaves zero rows and one document.", 0)]
CASES += [("Spring Data runs the query on PostgreSQL.", 1), ("Spring Data JPA sends PostgreSQL one statement for findByName.", 0),
          ("The same repository works the same on every store.", 1), ("The harness's Redis repository answers zero, with no exception.", 0),
          ("Commons sends the query to PostgreSQL.", 1), ("Commons parses the name; the module's request goes to the store.", 0),
          ("Spring Data Redis's creator, RedisQueryCreator, refuses GreaterThan at the call.", 0), ("The same parsed line, three times.", 0),
          ("It is magic.", 1), ("Spring Data automatically finds your class.", 1), ("Lesson three of the next course fixes the PATCH.", 1),
          ("The keyset names come from Course 7's lesson called Paging and Sorting: Window and ScrollPosition, both in the Commons jar.", 0),
          ("Redis finds thirty orders worth two hundred forty.", 1), ("With @Indexed on value, Redis finds thirty orders worth two hundred forty.", 0),
          ("monthRevenue is a derived name.", 1), ("monthRevenue is not a name Commons parses.", 0), ("It is a bug in Redis.", 1),
          ("The second window starts after Sunil.", 1), ("Four customers under a limit of ten: no second window, so no keyset predicate is claimed.", 0),
          ("TiffinBox uses seven modules.", 1), ("The capstone starts in one second.", 1), ("Half a minute later the index has it.", 1)]
CASES += [("Spring Data writes your method.", 1), ("The generated Impl answers the totals.", 1), ("Spring Data MongoDB writes your method.", 1),
          ("This pipeline is safe.", 1), ("Spring Data MongoDB calls your class.", 1), ("The thirty come back ascending.", 1),
          ("TiffinBox starts in one second.", 1), ("Lesson three of Course nine adds the route.", 1),
          ("Spring's advisory CVE-2026-59342 names a placeholder inside `$where`, `$function` or `$accumulator`; this pipeline has none.", 0),
          ("Commons composes the repository from `OrderTotalsImpl` and `SimpleMongoRepository`; `RepositoryComposition` hands the call to the class.", 0),
          ("The derived find sends no sort: the profiler shows its filter alone, and the count is thirty.", 0),
          ("The class is yours: Commons finds it by its name.", 0), ("The derived finder and the fragment sit side by side.", 0)]
CASES += [("TiffinBox caches on one app.", 1), ("The dev run holds both caches.", 1), ("In dev, Caffeine and Redis both cache the list.", 1),
          ("Every other store stays in sync.", 1), ("The copies are eventually consistent.", 1), ("The index has the dish later.", 1),
          ("docker ps shows the container.", 1), ("The cache writer evicts automatically.", 1), ("Testcontainers binds to localhost by default.", 1),
          ("TiffinBox starts in one second.", 1), ("Lesson three of Course nine adds the route.", 1), ("The test is safe now.", 1),
          ("A system of record: the store a change is written to first; a copy or a cache in another store is written from it, after the commit.", 0),
          ("One jar, two runs: the default run on H2 with Caffeine, and dev on the four stores.", 0),
          ("No run holds both caches: the default run loads ninety-three Caffeine classes; the dev run loads two and builds no Caffeine cache.", 0),
          ("The witnesses' order: PostgreSQL's COMMIT, then Redis's XADD, then the cache writer's DEL.", 0),
          ("Testcontainers 2.0.5 publishes on every interface unless the test names the address; unit 27 names it, 127.0.0.1.", 0)]
# --- XFAM_S9S1 begin ---
# Course 9 Section 1's family (S1B :367, :370; S9.4, S9.8, S9.13, S9.21; SC §4 (2)), judged on each sentence with its code spans masked.
XFAM_S9S1 = {
    "S9S1: faster / cheaper / lighter beside a 304, a replay or a cache (S9.8)":
        (r"\b(?:faster|cheaper|lighter|quicker)\b[^.;]*\b(?:304|replay\w*|cache\w*)\b|\b(?:304|replay\w*|cache\w*)\b[^.;]*\b(?:faster|cheaper|lighter|quicker)\b", None),
    "S9S1: the cache catches up (S9.13)": (r"\bcatch(?:es|ing)? up\b", None),
    "S9S1: safe or idempotent without the route's measured writes or its second answer (S9.21)":
        (r"\b(?:safe|idempotent)\b", r"\bwrites?\b[^.;]*\b(?:second|repeat|again)\b|\bsecond answer\b|\bthe first answer back\b|\bcounted once\b|\bbyte-identical\b"),
    "S9S1: Spring does X, with no capture (SC §4 (2))": (r"\bSpring (?:does|handles|takes care of|makes sure|guarantees|retries|knows)\b", None),
    "S9S1: REST requires / REST forbids (S9.4)": (r"\bREST (?:requires|forbids|demands|mandates|says you must)\b", None),
    "S9S1: harmless, without the key and the counts": (r"\bharmless\b", r"Idempotency-Key[^.;]*\b(?:paused days|pauses|rows)\b"),
    "S9S1: the newest version, without required=false named": (r"\bthe (?:newest|latest) version\b", r"required=false"),
    "S9S1: every API, most APIs, most teams": (r"\b(?:every|most|all) (?:APIs?|teams|clients|servers|services)\b", None),
    "S9S1: Course 8's time-meaning words dur9 does not judge": (r"\b(?:in a moment|instantly|shortly|briefly|immediately|right after|gives up after|at once)\b", None),
}
XFAM_S9S1_PLANTS = ["A replay is faster.", "The 304 is cheaper.", "Then the cache catches up.", "The route is safe.", "A PUT is idempotent.",
                    "Spring handles the retry.", "REST requires a key.", "A double submit is harmless.", "Use the newest version.",
                    "Most APIs do this.", "The retry lands at once.", "The answer comes back instantly."]
XFAM_S9S1_NEAR = ["The second try writes nothing: the filter answers with the first answer back, byte-identical.",
                  "It says that a lifetime exists, not its value.",
                  "An idempotency key: a label the client puts on a request so a repeat of it gets the first answer back.",
                  "With the Idempotency-Key, the second try leaves the pauses and the paused days as they were: harmless, measured."]


def s9s1(s, raw):
    out = []
    for name, (rx, okr) in XFAM_S9S1.items():
        if re.search(rx, s, re.I) and not (okr and re.search(okr, s, re.I)): out.append("XFAM_S9S1: " + name.split(" (")[0])
    return out
# --- XFAM_S9S1 end ---

XU05 = {
    "U05: an absent field is null, without its type (an absent number is refused at the read; an absent text field reads as null)":
        (r"\b(?:an? )?(?:absent|missing|left[- ]out) (?:field|member|value)s? (?:is|are|becomes?|reads? as) null\b", None),
    "U05: Jackson 3 writes a price of zero, without the switched-off attribute":
        (r"\b(?:writes?|wrote|becomes?|sets?) (?:a )?(?:price (?:of )?)?zero\b|\bmissing price becomes zero\b", r"\bswitched off\b|\battribute off\b"),
    "U05: the naive PATCH is safe / the trap is harmless":
        (r"\bthe naive PATCH is safe\b|\bthe trap is harmless\b", None),
    "U05: PATCH idempotent or not, without the retry's two answers":
        (r"\b(?:a )?(?:PATCH|merge patch|JSON Patch)(?: is| is not|isn't)(?: an?)? idempotent\b", r"\btwice\b[^.;]*\bthen\b"),
    "U05: a PATCH answers four-oh-five, unqualified":
        (r"\ba PATCH answers four[- ]oh[- ]five\b", r"\bslash customers\b|\bold address"),
    "U05: a broken rule is four hundred on the patch route":
        (r"\b(?:a broken rule is|validation answers) four hundred\b", r"\bcreate route\b"),
    "U05: null deletes the field, without merge patch":
        (r"\bnull (?:deletes|removes) the (?:field|member)\b", r"\bmerge patch\b"),
    "U05: readerForUpdating follows the standard / is merge patch / removes":
        (r"\breaderForUpdating (?:follows|is|removes|implements)\b", None),
    "U05: Spring or Jackson applies the patch / Spring supports JSON Patch (SC §4 item 2)":
        (r"\b(?:Spring|Jackson) applies the patch\b|\bSpring supports JSON Patch\b|\bSpring merges\b", None),
    "U05: JSON Patch is built in": (r"\bJSON Patch is built[- ]in\b", None),
    "U05: the stale window closes / the proxy closed the window / the old address 404s eventually":
        (r"\bthe (?:stale )?window closes\b|\bthe proxy closed the window\b|\bwindow (?:is )?closed\b|\b404s eventually\b|\banswers four oh four eventually\b", None),
    "U05: retries are safe / the route is not safe to retry, without both answers":
        (r"\bretries are safe\b|\bnot safe to retry\b|\bsafe to retry\b", r"\btwice\b[^.;]*\bthen\b"),
    "U05: a line count as a verdict (shorter, simpler, cleaner)":
        (r"\b(?:shorter|simpler|cleaner|leaner|neater)\b", None),
    "U05: the patch is validated, without the re-read named":
        (r"\bthe patch is validated\b", None),
    "U05: TiffinBox answers five hundred, without the harness's label":
        (r"\bTiffinBox answers five hundred\b", None),
    "U05: the key protects the patch / a PATCH carries a key":
        (r"\bthe key protects the patch\b|\ba PATCH carries a key\b|\bthe patch is keyed\b", None),
    "U05: over-posting is closed / unknown fields are refused (U22's; the run says dropped)":
        (r"\bover-posting is closed\b|\bunknown (?:fields|members) are refused\b", None),
    "U05: the standard says four twenty-two, without the RFC and its section":
        (r"\bthe standard says four twenty-two\b", None),
    "U05: a minute count in prose (the configured time to live is said by its name)":
        (r"\b(?:ten|10|\d+) minutes?\b|\bafter ten minutes\b", None),
    "U05: Hinglish (check_unit9.py's list)": (r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", None),
    "U05: a status said as digits or in the hundred form (check_unit9.py's status gate)":
        (r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b(?![\d.,:/-]\d)|\b(?:one|two|three|four|five)[\s-]hundred(?:[\s-]and)?[\s-]+(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|twenty|thirty|fifty)\b", None),
    "U05: a partial update or a status code re-glossed (U05 owns one gloss; Course 6's are theirs)":
        (r"^\s*(?:A status code|A problem detail|An API|A representation|A resource):", None),
}
XU05_PLANTS = ["An absent field is null.", "A missing field becomes null.", "Jackson 3 writes a price of zero.", "A missing price becomes zero.",
               "The naive PATCH is safe.", "The trap is harmless.", "A PATCH is idempotent.", "PATCH is not idempotent.", "A merge patch is idempotent.",
               "A PATCH answers four-oh-five.", "A broken rule is four hundred.", "Validation answers four hundred.", "Null deletes the field.",
               "readerForUpdating follows the standard.", "readerForUpdating is merge patch.", "readerForUpdating removes the member.",
               "Spring applies the patch.", "Jackson applies the patch.", "Spring supports JSON Patch.", "JSON Patch is built in.",
               "The stale window closes after ten minutes.", "The proxy closed the window.", "The old address 404s eventually.",
               "Retries are safe.", "The route is not safe to retry.", "This approach is shorter.", "The merge route is simpler.", "It is cleaner.",
               "The patch is validated.", "TiffinBox answers five hundred.", "The key protects the patch.", "A PATCH carries a key.",
               "Over-posting is closed.", "Unknown fields are refused.", "The standard says four twenty-two.", "It answers 415.",
               "It answers four hundred and fifteen.", "Bas yaar.", "A status code: a number."]
XU05_NEAR = ["An absent number is refused at the read; an absent text field reads as null.",
             "With the attribute switched off, the harness's copy wrote a price of zero.",
             "This merge patch answered two hundred twice; this test-then-replace patch answered two hundred twice, then four-oh-nine.",
             "A PATCH to slash customers still answers four-oh-five.",
             "The same broken rule answers four hundred on the create route and four twenty-two on the patch.",
             "In a merge patch, null removes the member.", "readerForUpdating set the member to null.",
             "JSON-P's `createPatch` applied it, as the run printed.", "This approach took fourteen lines.",
             "Every patched document is read back into the record and checked.", "The harness's route answered five hundred.",
             "RFC 5789 names four twenty-two for an unprocessable request.", "The unknown member was dropped.",
             "The old address answers until the entry is evicted or its time to live ends.",
             "A partial update: a change that names only the fields it changes.", "The status is `415`."]


def u05(s, raw):
    out = []
    for name, (rx, okr) in XU05.items():
        if re.search(rx, s, re.I) and not (okr and re.search(okr, s, re.I)): out.append("XU05: " + name.split(" (")[0])
    return out


# the carried base's verdicts() calls the unit's own family by U04's name, u04(): in unit 05 that name is bound to XU05's judge
u04 = u05


def _m(p): return re.sub(r"`[^`]*`", "`…`", p)
for _p in XFAM_S9S1_PLANTS + XU05_PLANTS:
    _v = s9s1(_m(_p), _p) + u05(_m(_p), _p)
    assert _v, ("a plant this unit's families do not refuse", _p)
for _p in XFAM_S9S1_NEAR + XU05_NEAR:
    _v = s9s1(_m(_p), _p) + u05(_m(_p), _p)
    assert not _v, ("a near miss this unit's families refuse", _p, _v)
CASES += [(_p, 1) for _p in XFAM_S9S1_PLANTS + XU05_PLANTS] + [("The filter answers `422`, typed `…-reused`.", 0), ("The word `RESTful` is a refused word here.", 0)]
# The carried cases that only Course 8's dropped XU25-XU27 refused, and two this unit's families now refuse (a status said in digits, R.224's
# Course 7 title the dropped lines 404-408 added): removed from the self-test, counted on its last line.
DROPPED = {"The probe's `lb` 500 beside a 200 is struck.", "The keyset names come from Course 7's lesson called Paging and Sorting: Window and ScrollPosition, both in the Commons jar.",
           "monthRevenue is a derived name.", "It is a bug in Redis.", "The second window starts after Sunil.", "TiffinBox uses seven modules.",
           "The generated Impl answers the totals.", "Spring Data MongoDB calls your class.", "The thirty come back ascending.", "TiffinBox caches on one app.",
           "The dev run holds both caches.", "Testcontainers binds to localhost by default.", "Redis finds thirty orders worth two hundred forty."}
_n0 = len(CASES); CASES = [c for c in CASES if c[0] not in DROPPED]; NDROP = _n0 - len(CASES)

_bad, _per = selftest()
assert not _bad, _bad

for t, want in CASES:
    PARA[0] = t
    got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t)
    assert bool(got) == bool(want), (t, got)
n = 0
def judge(p, start, para):
    global n
    text = " ".join(x.strip() for x in para)
    PARA[0] = text
    for s in re.split(r"(?<=[.;!?])\s+", text):
        s2 = re.sub(r"`[^`]*`", "`…`", s)
        for v in verdicts(s2, s):
            n += 1; print("  %s line %d: %s" % (p, start, v))
for p in sys.argv[2:]:
    CUR[0] = p
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in ("<!-- values: begin -->", "<!-- values: end -->")
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() == "<!-- values: begin -->": vals = True; continue
        if l.strip() == "<!-- values: end -->": vals = False; continue
        if fence or vals or not l.strip(): continue
        if l.startswith("**Your turn:**"): continue   # the brief's spoken line, byte for byte - receipts.sh checks it and its word count
        if hashlib.md5(l.rstrip("\n").encode()).hexdigest() == HANDOFF_MD5: continue   # U24: the pinned hand-off line (S8.89), byte for byte - see HANDOFF_MD5
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("carried cases dropped: %d · " % NDROP + "xfam5b self-test: %d families · %d plants · %d near misses · TIMEPAT %d + %d -> OK" % (len(XFAM_S5), len(PLANTS), len(NEAR), len(TIME_HIT), len(TIME_PASS)))
print("self-test: %d cases · XFAM_S9S1 %d families · U05 %d families · refused: %d" % (len(CASES), len(XFAM_S9S1), len(XU05), n))
