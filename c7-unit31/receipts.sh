#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · JOIN FETCH vs @EntityGraph vs @BatchSize - this unit's receipts. Section 5's third unit and its second change to the
# anchor (brief flag 1, C2): before is the link to ../c7-unit29/after (its tree's hash pinned), after/ is this unit's tree, and
# ../c7-tiffinbox equals after/ from this unit's commit on (units 32 and 33 build over after/ through links; unit 34 moves the anchor
# next). Three ways to ask for the pauses up front - join them into the customers' query, name them in an entity graph, or let
# Hibernate fetch them in groups - one table of counts, built from the run. Nine captures, each run three times and hashed; a hash
# that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a
# check that can fail, against another witness of the same run (harness/chk31.py) - never against a typed figure. Two databases
# (brief flag 7): H2 2.5.250 in the harness JVM's memory, and PostgreSQL 18.6 - ONE container per run, from the pinned image, on
# 127.0.0.1:20108, a fresh database per JVM. TiffinBox itself runs on H2 only: an H2 TCP server on 127.0.0.1:20107 (only local
# connections), so a second connection (H2's own Shell) reads what TiffinBox stored.
#   fix       the page's read - every customer by name, her paused days - through each fetch plan, at -Dn=36 (unit 20's generator,
#             counted back): none, left join fetch, inner join fetch, @EntityGraph on the anchor's derived method, @NamedEntityGraph
#             as a fetchgraph hint, @BatchSize, default_batch_fetch_size (a run option), SUBSELECT, the DTO group-by - the three
#             witnesses, the rows read, the customers shown and the id lists each batch statement asked for; both databases
#   sql       the statements' texts, read off Hibernate's SQL logger, each once with how many times it was sent; both databases
#   paging    a page of ten with a collection fetch (setMaxResults, then a PageRequest with an entity graph, then no fetch), one
#             pause each and - after a second seed - three; the JVM's WARN and HHH90003004 lines counted; both databases
#   bags      two collections fetched at once: two Lists, then two Sets with and without distinct; both databases
#   anchor    TiffinBox, B (before/ = ../c7-unit29/after, 20100) and A (after/, 20101) and A' (after/ copied and built again,
#             20102): POST /customers/import of 36 generated lines, then GET /dashboard as HTML and as JSON and GET /customers -
#             each request's SQL lines between two markers (the whole request), the read's own session, the "Paused days" column
#             parsed by its header against the second connection's sum, row by row
#   seven     the comparison set on before/ and after/ (20103): its md5, and the SQL lines during it
#   tests     TiffinBox's tests on after/, offline, read from Surefire's reports
#   xcheck    Hibernate's DDL script over after/'s libraries = ../c7-unit29/xcheck.sql (no mapping moved)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ (before, after, after2 for A', tests) and built there, never in place, with its README's
# package line, offline. The harness (harness/src, packages probe.w and probe.x, outside com.tiffinbox) is compiled once with javac
# -parameters against after/'s extracted libraries. Every JVM runs under an alarm (perl -e 'alarm N; exec ...'); an alarm that fires
# is a failed receipt (R.247). Ports (§P, 20100-20109): 20100 B · 20101 A · 20102 A' · 20103 seven · 20107 the H2 TCP server ·
# 20108 the container · 20104-20106 and 20109 never bound; the harness JVMs bind none. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
CN=c7u31-pg
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it), $spid (the
# H2 server); then sweep(): anything of this run still alive in its process group is stopped; then the container, if this script
# created it (CSTARTED), is removed (docker rm -f, pgrm). After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after
# a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an interrupt. No wait is bare.
pid=""; mpid=""; xpid=""; spid=""; CSTARTED=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.w.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "docker exec c7u31-pg") || index($0, "docker run -d --pull never --name c7u31-pg")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# pgrm: docker rm -f, again until docker ps -a names it no more (at least three tries, 0.5 apart, at most 20): a docker run cut by
# an interrupt can register its container a moment after the first rm (unit 28's form)
pgrm() { local i=0; [ -n "$CSTARTED" ] || return 0
  while [ $i -lt 20 ]; do docker rm -f "$CN" > /dev/null 2>&1 || true
    [ $i -ge 2 ] && [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] && break
    sleep 0.5; i=$((i + 1)); done; CSTARTED=""; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; pgrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGOPTIONS PGHOST PGUSER DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token and the password live under .harness/ only"
# ---- the trees: before/ is unit 29's after/, through a link, frozen (its tree's hash pinned); after/ is this unit's -------------
[ -L before ] && [ "$(readlink before)" = ../c7-unit29/after ] || die "before must be the link to ../c7-unit29/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
T29='43 573dbb79c934b95ca71c6ecaed4c3bb3'            # unit 29's after/ at its commit 9714b74: 43 files (unit 30's pin, harness/tree31.py)
beforetree() { local t; t=$(python3 -I harness/tree31.py before/) || die "before/'s tree could not be hashed"
  [ "$t" = "$T29" ] || die "R.211: before/ (../c7-unit29/after, a shipped unit's frozen tree) is not the tree this unit changed: $t, pinned $T29"
  echo "  before/'s tree ($1): python3 -I harness/tree31.py before/ -> $t = pinned (unit 29's after/, frozen; unit 30 pins the same)"; }
# R.211: after/ equals ../c7-tiffinbox from this unit's commit on - should a later unit change the anchor, a note, never a stop
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C2) - a later anchor change has moved ../c7-tiffinbox on"; fi; }
beforetree start; anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
PGJ=org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HS=harness/src/probe/w
HFILES='chk31.py csv31.py dur7.py logback.xml s31.py seg31.py src surefire.py tree31.py'
SFILES='probe/w/Gen.java probe/w/H.java probe/w/Main.java probe/w/Row.java probe/w/Run.java probe/w/Seed.java probe/w/SqlCounter.java probe/w/ent/BCustomer.java probe/w/ent/BOrder.java probe/w/ent/BPause.java probe/w/ent/TCustomer.java probe/w/ent/TOrder.java probe/w/ent/TPause.java probe/w/ex/ExApp.java probe/w/repo/FetchRepo.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not unit 29's, byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
cmp -s harness/seg31.py ../c7-unit30/harness/seg30.py && cmp -s harness/csv31.py ../c7-unit30/harness/csv30.py && cmp -s harness/tree31.py ../c7-unit30/harness/tree30.py || die "harness/seg31.py, csv31.py and tree31.py are unit 30's seg30.py, csv30.py and tree30.py, byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20100 20101 20102 20103 20104 20105 20106 20107 20108 20109"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
docker image inspect "$IMG" > /dev/null 2>&1 || die "the image $IMG is not on this machine - docker pull it once (this script never pulls)"
[ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "a container named $CN exists - an interrupted run's? remove it yourself: docker rm -f $CN"
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/secrets
echo "  the image: $IMG is on this machine (docker image inspect; never pulled)"

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264) + R.301 (S5.18) + R.287 + R.190, carried from unit 30's s30; S5.2 (R.285), R.224 carried; S5.5 (R.288),
# S5.6 (R.289), S2.12 and the inner join's lost customers, this unit's - per sentence, harness/s31.py, its self-test first
DW=$(python3 -I -B harness/s31.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'self-test: 34 cases · refused: 0' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.287, R.190, S5.2, R.224, S5.6, S2.12, the inner join): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s31, 34-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 (a cost word only beside a printed count) · speed words 0 · R.287 old wordings 0 · R.190 the tests as a witness 0 · S5.2 a page's count unscoped 0 · R.224 N+1 and DataLoader without their titles 0 · S5.6 paging in memory / HHH90003004 0 · S2.12 an IN list without its database 0 · the inner join's lost customers unnamed 0 - over README.md and exercise/"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/ and harness/)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
# R.225: a SQL string this unit shows is the logger's - outside the values block and the text blocks a run printed, none in README.md
SQLRE='select ce1_0|from customer ce1_0|from pause p1_0|select p1_0|select distinct ce1_0|select b1_0|select t1_0|customer_id in \(|= any \(|offset \? rows|count\(\*\)|left join pause p1_0'
TS=$(awk '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b { print NR ": " $0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its values block and the blocks the runs printed"
# R.302 (S5.19): the page's counts and the table's cells are printed by the run, typed nowhere - not in the prose (fenced blocks and
# the values block hold what the runs print), not in this script, not in the harness
TN=$(for f in README.md exercise/README.md exercise/SOLUTION.md; do awk -v f="$f" '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } /^```/ { b = !b; next } !v && !b && ($0 ~ /(^|[^0-9A-Za-z_.])(4[14]|78|38)([^0-9A-Za-z_.]|$)/ || $0 ~ /(^|[^0-9A-Za-z_.,\/-])4 (SQL lines|statements|batch statements|lines)/ || $0 ~ /[0-9] (jars|libraries|JPA repository)/) { print f ":" NR ": " $0 }' "$f"; done | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TN" ] || die "R.302: a count typed in the prose (a page's or the table's count, a jar or library count), outside a block a run printed and the values block: $TN"
TC=$($G -nwE '4[14]|78|38' receipts.sh harness/chk31.py harness/src/probe/w/*.java harness/src/probe/w/*/*.java 2> /dev/null | $G -vE '^receipts.sh:[0-9]*:T[NC]=' | cut -c1-120 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "R.302: a count typed in this script or the harness: $TC"
echo "  R.302: the counts typed 0 times in the prose (outside printed blocks and the values block), in receipts.sh, chk31.py and the harness's sources (s31.py's self-test aside: its refused cases are the plants' sentences)"

# ---- R.250: C2 and every sentence it makes false - a gate before any build -------------------------------------------------------
ER=after/$CJ/CustomerEntityRepository.java; CR=after/$CJ/CustomerRepository.java
$G -qxF '    @EntityGraph(attributePaths = "pauses")' "$ER" && $G -qxF '    List<CustomerEntity> findAllByOrderByNameAsc();' "$ER" || die "C2: after/'s CustomerEntityRepository declares @EntityGraph(attributePaths = \"pauses\") List<CustomerEntity> findAllByOrderByNameAsc()"
PB=$(awk '/public Map<String, Integer> pausedDaysByCustomer\(\)/ { f = 1 } f { print } f && /^    }$/ { exit }' "$CR")
printf '%s\n' "$PB" | $G -qF 'customers.findAllByOrderByNameAsc()' && ! printf '%s\n' "$PB" | $G -qF 'findAll(Sort.by(' || die "C2 (R.250): pausedDaysByCustomer must read through findAllByOrderByNameAsc(), not findAll(Sort.by(\"name\"))"
awk '/@Transactional\(readOnly = true\)/ { t = NR } /public Map<String, Integer> pausedDaysByCustomer\(\)/ { print (t == NR - 1) ? "kept" : "gone" }' "$CR" | $G -qx kept || die "C2: pausedDaysByCustomer keeps its @Transactional(readOnly = true) (RE-MEASURE 2)"
[ "$($G -cF 'customers.findAll(Sort.by("name"))' "$CR")" = 1 ] && awk '/public List<Customer> findAll\(\)/ { f = 1 } f && /customers.findAll\(Sort.by\("name"\)\)/ { print "list"; exit }' "$CR" | $G -qx list || die "C2: CustomerRepository.findAll() - the list - keeps findAll(Sort.by(\"name\")), and nothing else does"
F250=$( { $G -nE 'a lazy collection|read through her pauses|One SELECT for the customers and one per customer' "$CR" | sed "s#^#$CR:#"; $G -nE 'one method of its own|two queries written by hand' "$ER" | sed "s#^#$ER:#"; } | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$F250" ] || die "R.250: a sentence C2 makes false is still in after/: $F250"
$G -qF 'unit 30'"'"'s subject. *(Course 7, unit 31: no longer — the read fetches the customers and their pauses in one statement, through an entity' after/README.md && $G -qF '## Course 7 · unit 31 — the fetch plan' after/README.md || die "R.250: after/README.md - unit 29's sentence on the page's statements carries unit 31's note, and unit 31's section is there"
for t in before after; do $G -c 'findAllByOrderByNameAsc' "$t/$CJ/CustomerEntityRepository.java" > /dev/null || true; done
[ "$($G -c 'findAllByOrderByNameAsc' before/$CJ/CustomerEntityRepository.java || true)" = 0 ] || die "before/ must not hold unit 31's method"
echo "  R.250: after/ - the graph on the derived method, the fourth read through it, its transaction kept, the list route's findAll(Sort) alone; the sentences C2 makes false (\"a lazy collection\", \"read through her pauses\", \"one per customer\" in CustomerRepository; \"one method of its own\", \"two queries written by hand\" in CustomerEntityRepository) 0; the anchor README's note and section"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/Gen.java $HS/H.java $HS/Main.java $HS/Row.java $HS/Run.java $HS/Seed.java $HS/SqlCounter.java $HS/ent/BCustomer.java $HS/ent/BOrder.java $HS/ent/BPause.java $HS/ent/TCustomer.java $HS/ent/TOrder.java $HS/ent/TPause.java $HS/repo/FetchRepo.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HSRC")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*:../../.m2-demo/$PGJ\" probe.w.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../after/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20107 -ifNotExists")
L_SHELL=$(mine "cd .harness/run && $AL java $JL -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20107/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
L_CSV=$(mine 'python3 -I harness/csv31.py "$N" > .harness/import.csv')
L_IMP=$(mine "curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20100/customers/import")
L_RUN=$(mine "docker run -d --pull never --name $CN -p 127.0.0.1:20108:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v \"\$U/.harness/secrets/pgpw:/run/pgpw:ro\" $IMG")
L_READY=$(mine "docker exec $CN pg_isready -U sa -h 127.0.0.1 -q")
L_DB=$(mine "docker exec $CN psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c \"drop database if exists \$DB with (force)\" -c \"create database \$DB\"")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
Q_C='select count(*) from customer'
Q_P='select count(*) from pause'
Q_S='select c.name, coalesce(sum(p.days),0) from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name'
TBL=(--spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug --logging.level.org.hibernate.session.metrics=debug --spring.jpa.properties.hibernate.generate_statistics=true)
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# tb TREE PORT DB: the README's run line on TREE, its port, TiffinBox's database on the H2 server (mem:DB), sa (unit 29's step:
# without it Boot treats the TCP URL as not embedded and the start fails, 28000-250), the SQL logger, the transaction manager's
# DEBUG lines, Hibernate's session metrics (DEBUG) and its statistics on (run options) - quoted
tb() { local t=$1 p=$2 d=$3 a x; a="'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20107/mem:$d;DB_CLOSE_DELAY=-1'"
  for x in "${TBL[@]}"; do a="$a $x"; done; printf '%s %s\n' "$(at .harness/$t $p "$R_RUN")" "$a"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(exe "$(at .harness/after 20101 "$R_RUN")")" = "cd .harness/after && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20101" ] || die "at(): the run line is not the README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE "Could not find artifact [^ ]+|$NOPLUG [^ ]+|Non-resolvable parent POM for [^ ]+" "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
summ4() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }'; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/after2
mbuild "$(off .harness/before "$R_PLAIN" package) -DskipTests" .harness/build-before.log ".harness/before (before/, the README's package line, -DskipTests: its tests are unit 29's)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0 (a guard)"
mbuild "$(off .harness/after2 "$R_PLAIN" package) -DskipTests" .harness/build-after2.log ".harness/after2 (after/ copied again for A', the same line, -DskipTests)"
for t in before after after2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar "$PGJ"; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
[ ! -e .harness/after/$XD/lib/postgresql-42.7.14.jar ] || die "after/'s lib/ holds the PostgreSQL driver - it never did; the harness takes it from .m2-demo"
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before after2; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after after2; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/after), copied into before's and after2's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/w/ex ] || die "the exercise's class compiled into the wrong place"
echo "  extracted three jars ($(for t in before after after2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/A'); the harness compiled once - .harness/hc over after/'s; the PostgreSQL driver: .m2-demo/$PGJ (md5 $(md5 -q "$M2/$PGJ"))"
# the H2 TCP server: one JVM for this run, loopback only, TiffinBox's databases on it (mem:NAME), the second connection its Shell
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20107)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20107)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20107"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20107' ] || die "the H2 server must listen on 127.0.0.1:20107 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20107 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20107 alone"

# ---- the container: PostgreSQL 18 from the pinned image, loopback only, a generated password in a 0600 file (R.214) ------------
# CSTARTED is set before docker run, so an interrupt during its start removes it too
(umask 077 && LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom 2> /dev/null | head -c 24 > .harness/secrets/pgpw) || true
[ "$(wc -c < .harness/secrets/pgpw | tr -d ' ')" = 24 ] && [ "$(stat -f '%Lp' .harness/secrets/pgpw)" = 600 ] || die "the password file was not written, 24 characters, mode 0600"
PW=$(cat .harness/secrets/pgpw)
CSTARTED=1
(eval "$L_RUN") > .harness/docker-run.log 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/docker-run.log)"
i=0; while ! (eval "$L_READY") > /dev/null 2>&1 < /dev/null; do i=$((i + 1)); [ $i -lt 120 ] || die "the container did not accept connections within its cap (120 tries, 0.5 apart)"; sleep 0.5; done
DP=$(docker port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20108' ] || die "docker port: the container must publish 5432 on 127.0.0.1:20108 alone: $DP"
[ "$(listeners 20108)" -ge 1 ] || die "nothing listens on 20108 after the container started"
echo "  the container: $CN from $IMG (--pull never); docker port: $DP; user sa, the password generated into .harness/secrets/pgpw (24 characters, mode 0600, never printed); pg_isready after $i tries (cap 120); no per-database setting"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0; PGJVM=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v pw="$PW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(pw); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(W, "<pw>"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/^ *[0-9]+ ns /, "      <ns> ns ")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/virtual-[0-9]+/, "virtual-<n>"); gsub(/omcat-handler-[0-9]+/, "omcat-handler-<n>"); gsub(/ rows?, [0-9]+ ms\)/, " row(s))")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 2 JPA repository interfaces.' "token $TOKEN" "url jdbc:postgresql://127.0.0.1:20108/u31fix?user=sa&password=$PW" 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' '    6189708 ns preparing 9 JDBC statements' '(1 row, 3 ms)' '(4 rows, 12 ms)' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 2 JPA repository interfaces.' 'token [masked: the token]' 'url jdbc:postgresql://127.0.0.1:20108/u31fix?user=sa&password=<pw>' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' '      <ns> ns preparing 9 JDBC statements' '(1 row(s))' '(4 row(s))')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time, the token, the password, a lambda class's address, a session-metrics time figure and the Shell's time must be masked"
echo "  mask: its self-test passed (the token, the password, folders, home, identities, times); raw password copies after mask: $(mask < .harness/p1 | $G -cF -- "$PW" || true)"
rm -f .harness/p1
HQ=(--logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HA=('--spring.datasource.url=jdbc:h2:mem:u31;DB_CLOSE_DELAY=-1' "${HQ[@]}")
DBF=--spring.jpa.properties.hibernate.default_batch_fetch_size=16
HE=""
hrun() { local c i=0 e=0 n
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"
  case " ${V[*]:-} " in *" -Dpg.db="*) PGJVM=$((PGJVM + 1)); n=$(raw "$PW" .harness/h.log); [ "$n" = 0 ] || die "a harness log held the password, raw ($n)"; echo "  raw password copies in its log: $n (before the mask; the URL is printed cut before its ?)" ;; esac; }
# hview [texts]: the harness JVM's log - its org.hibernate.SQL lines counted, not shown (with "texts": each text once, with how many
# times it was sent, after the log); its WARN lines and HHH90003004 lines counted by grep -c (R.302); tabs as four spaces
hview() { awk '/ org\.hibernate\.SQL : / { q++; next } /^$/ { next } { gsub(/\t/, "    "); sub(/[ \t]+$/, ""); print "  " $0 }
    END { print "  its org.hibernate.SQL lines (counted, not shown here): " q + 0 }' .harness/h.log
  [ "${1:-}" != texts ] || sed -n 's/^DEBUG \[main\] org\.hibernate\.SQL : //p' .harness/h.log | awk '{ if (!($0 in c)) o[++n] = $0; c[$0]++ } END { for (i = 1; i <= n; i++) print "  SQL text, sent " c[o[i]] " x: " o[i] }'
  echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true) · HHH90003004 lines (grep -c): $($G -c 'HHH90003004' .harness/h.log || true)"
  echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# pgdb NAME: a fresh database for the next PostgreSQL JVM (dropped first, if a run left it)
pgdb() { local DB=$1; echo "\$ DB=$DB; $L_DB"; (eval "$L_DB") > .harness/pgdb.log 2>&1 < /dev/null || die "the fresh database $DB was not made: $(tail -2 .harness/pgdb.log)"
  echo "  a fresh database: $DB"; }
# h2 / pg SCEN [texts] [more A]: one harness JVM on H2 (this JVM's memory) or on the run's fresh PostgreSQL database
h2() { local s=$1 t=${2:-}; shift 2 2> /dev/null || shift; V=(-Ds=$s -Dn=${NN:-$NIMP}); A=("${HA[@]}" "$@"); hrun; hview $t; }
pg() { local s=$1 t=${2:-}; shift 2 2> /dev/null || shift; pgdb "u31$s"; V=(-Ds=$s -Dn=${NN:-$NIMP} -Dpg.db=u31$s -Dpg.pwfile=../secrets/pgpw); A=("${HQ[@]}" "$@"); hrun; hview $t; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; raw "$PW" .harness/cap.raw > ".harness/rawpw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-13s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-13s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-13s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $($G -c '^@@ ' .harness/code.diff || true) · lines out: $($G -c '^-' .harness/code.diff || true) · in: $($G -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }
# ---- TiffinBox: started from its tree, readiness polled, asked, stopped by its pid ---------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on $1 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on $1 now: 0"; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
# ---- the requests: each between two markers this script appends to the JVM's log (opened for append), read per request -----
U31M=U31MARK
mark() { printf '%s %s\n' "$U31M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U31M $1 start" -v b="$U31M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
# rq LABEL PATH ACCEPT PORT: one GET - its status, then (by its kind) the HTML table, the JSON's counts or the list's length, and
# its own log lines between its markers, summarised by harness/seg31.py
rq() { local l=$1 p=$4 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: $3' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: $3" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  case $l in
    list) echo "  -> $code · entries parsed (python3 -I): $(python3 -I -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' .harness/body-$l 2> /dev/null || echo 'no answer')" ;;
    *) echo "  -> $code" ;; esac
  python3 -I -B harness/seg31.py .harness/seg-$l.log
  case $l in
    html) python3 -I -B harness/chk31.py table .harness/body-$l || echo "  the table: not parsed" ;;
    json) echo "  the JSON (python3 -I): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print("customers %d · names %d · keys %s" % (d["customers"], len(d["names"]), " ".join(sorted(d))))' .harness/body-$l 2> /dev/null || echo 'no answer')" ;; esac; }
# imp PORT: the import - unit 20's generator writes the file (N lines and a header), POST /customers/import sends it
imp() { local p=$1 code c N=$NIMP
  echo "\$ N=$NIMP; $L_CSV"; eval "$L_CSV" || die "the import's file was not written"
  echo "  the generated file: .harness/import.csv - a header and $(($(wc -l < .harness/import.csv) - 1)) lines (wc -l: $(wc -l < .harness/import.csv | tr -d ' '))"
  c=${L_IMP/20100/$p}; mark "import start"; echo "\$ $c"
  code=$(curl -s --noproxy '*' -o .harness/body-import -w '%{http_code}' -F 'file=@.harness/import.csv;type=text/csv' "http://127.0.0.1:$p/customers/import" 2> /dev/null || true)
  settle; mark "import end"; seg import > .harness/seg-import.log
  echo "  -> $code $(cut -c1-200 .harness/body-import)"; python3 -I -B harness/seg31.py .harness/seg-import.log; }
# second DB: the second connection - H2's own Shell over TCP, the same database, run by this script while TiffinBox still runs
second() { local DB=$1 Q
  echo "the second connection (H2's Shell over TCP, mem:$DB):"
  for Q in "$Q_C" "$Q_P" "$Q_S"; do echo "\$ Q=\"$Q\"; $L_SHELL" | sed "s#\\\$DB#$DB#"
    (eval "$L_SHELL") > .harness/second.txt 2>&1 < /dev/null || die "the second connection failed: $(head -3 .harness/second.txt)"
    sed -E 's/[[:space:]]+$//; s/^/  /' .harness/second.txt; done; }
NIMP=36                                               # the generator's N - the import's lines, the harness's -Dn
# ---- the captures --------------------------------------------------------------------------------------------------------
fix() { echo "fix - the page's read through each fetch plan, at -Dn=$NIMP; per database one harness JVM for the plans, one more for the run option:"
  echo "H2 (in the harness JVM's memory):"; h2 fix; h2 dbf "" $DBF
  echo "PostgreSQL (the container, a fresh database per JVM):"; pg fix; pg dbf "" $DBF; }
sqlt() { echo "sql - the statements of the page's read through each fetch plan, read off Hibernate's SQL logger: each text once, with how many times it was sent:"
  echo "H2 (in the harness JVM's memory):"; h2 fix texts
  echo "PostgreSQL (the container, a fresh database per JVM):"; pg fix texts; }
paging() { echo "paging - a page of ten customers by name with a collection fetch, at -Dn=$NIMP (one pause each), then after a second seed (three each):"
  echo "H2 (in the harness JVM's memory):"; h2 paging texts
  echo "PostgreSQL (the container, a fresh database per JVM):"; pg paging texts; }
bags() { echo "bags - two collections fetched at once, on the seeded four (-Dn=0), the harness's table meal_order the second collection:"
  echo "H2 (in the harness JVM's memory):"; NN=0 h2 bags texts
  echo "PostgreSQL (the container, a fresh database per JVM):"; NN=0 pg bags texts; }
treeis() { if [ "$1" = before ]; then echo "before/, the anchor before this change"; elif [ "$1" = after ]; then echo "after/'s jar"; else echo "after/ copied again and built again"; fi; }
anchor() { local f t p d
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#' | sort
  for f in $CJ/CustomerEntityRepository.java $CJ/CustomerRepository.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  for f in before:20100:u31b:B after:20101:u31a:A after2:20102:u31a2:A2; do t=${f%%:*}; p=$(echo "$f" | cut -d: -f2); d=$(echo "$f" | cut -d: -f3)
    echo "${f##*:} - TiffinBox on .harness/$t ($(treeis $t)), port $p, its database mem:$d on the H2 server:"
    start "$(tb $t $p $d)" $p; up $p; ready $p
    imp $p; rq html /dashboard text/html $p; rq json /dashboard application/json $p; rq list /customers application/json $p
    second $d; stopit $p; logtok; rm -f .harness/run.out; done; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t n0
  for t in before after; do
    echo "the seven - $t/'s jar, port 20103, a fresh JVM (TiffinBox's own in-memory database), Hibernate's SQL logger on:"
    start "$(at .harness/$t 20103 "$L_SQL")" 20103; up 20103; ready 20103; n0=$(lines)
    echo "\$ \$CURLSET 20103 .harness/$t/$TF"
    "$CURLSET" 20103 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone 20103
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its dashboard line: $($G '^GET   /dashboard ' .harness/seven-$t.txt | cut -c1-120)"
    echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
    logtok; rm -f .harness/run.out; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  rm -rf .harness/tests; copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  which test classes run the real CustomerRepository or Dashboard - each test source's @MockitoBean lines (R.190):"
  for c in TiffinBoxWebTest FullStackTest FeedTest; do echo "    $c.java: CustomerRepository $($G -c '^ *@MockitoBean CustomerRepository ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true) · Dashboard $($G -c '^ *@MockitoBean Dashboard ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true)"; done
  echo "  the token in its log and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
X29=9cf92b8cae3abfd0f1c0706bfe7a4373                # Boot's script since unit 27's C2 - ../c7-unit29/xcheck.sql; no mapping moves in 31
[ "$(md5 -q xcheck.sql)" = "$X29" ] && cmp -s xcheck.sql ../c7-unit29/xcheck.sql || die "xcheck.sql is not ../c7-unit29/xcheck.sql (md5 $X29)"
XA=('--spring.datasource.url=jdbc:h2:mem:x31;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL over after/'s libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; V=(); A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over after/'s libraries"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-after.sql
  echo "  .harness/ddl-after.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-after.sql
  echo "  its md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the lazy-loading lesson's xcheck.sql: $(cmp -s .harness/ddl-after.sql ../c7-unit29/xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 300 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${A[@]}"' && printf '%s\n' "$setup" | $G -qE '^A=\(' || die "exercise/README.md must pass its arguments as an array, A (R.164, R.193)"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's JVM must run under its alarm (R.247)"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# ---- the checks: every number and string the video says, read off its capture -------------------------------------------------
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk31.py "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' | tee .harness/chk-$nm.out || true
  [ $e = 0 ] || die "$nm: its check failed (harness/chk31.py, above)"
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
chk_seven() { local SV SVB SVA
  SV=$(cat .r-seven.out)
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] && has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: $S466 on both trees (a guard)" || die "seven: $S466 on both trees"
  SVB=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 1p); SVA=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 2p)
  [ -n "$SVB" ] && [ -n "$SVA" ] && [ "$SVA" -lt "$SVB" ] || die "seven: the SQL lines during the seven, fewer on after/ (the JSON dashboard's fourth read is one statement): $SVB -> $SVA"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); SQL lines during the seven $SVB -> $SVA (the JSON dashboard runs the fourth read too, now one statement)"
  VALS="$VALS · seven: $S466 on before/ and after/, SQL lines during it $SVB -> $SVA"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' '    TiffinBoxWebTest.java: CustomerRepository 1 · Dashboard 1' '    FullStackTest.java: CustomerRepository 1 · Dashboard 0' '  the token in its log and every report: 0 times'; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) on after/ from the reports, the console the same - a guard (R.190; C7-4)"; VALS="$VALS · tests: 18 (14/3/1) on after/, offline"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  has "$XC" "  its md5: $X29 · the filed xcheck.sql: $X29 · cmp: the same, byte for byte · the lazy-loading lesson's xcheck.sql: the same, byte for byte" "xcheck: after/'s script = unit 29's, byte for byte (no mapping moved)"
  [ "$(cnt "$XC" '  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final')" = 1 ] || die "xcheck: HHH000001"
  echo "  xcheck: after/'s script $X29 = xcheck.sql = ../c7-unit29/xcheck.sql"; VALS="$VALS · xcheck: $X29"; }
EXQ="Your turn: the README's page runs one more statement for every customer. Make it one statement, without writing JPQL."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
chk_exercise() { local EB EZ b ER ES w x
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    x=$(python3 -I -c '
import re, sys
def pts(t): return [(int(a), int(b)) for a, b in re.findall(r"^    PROBE diners (\d+) · the page.s statements \(getPrepareStatementCount\): (\d+)$", t, re.M)]
br, so = pts(sys.argv[1]), pts(sys.argv[2])
ok = len(br) == 2 and len(so) == 2 and [d for d, _ in br] == [d for d, _ in so] and br[0][0] != br[1][0]
ok = ok and all(c == 1 + d for d, c in br) and len(set(c for _, c in so)) == 1 and so[0][1] < min(c for _, c in br) and br != so
print(("PASS" if ok else "FAIL") + " the README: " + " · ".join("%d diners %d" % p for p in br) + "; the solution: " + " · ".join("%d diners %d" % p for p in so))' "$ER" "$ES")
    case $x in PASS*) ;; *) die "exercise: the broken count one plus the diners at both N, the solution's the same at both and fewer, the two differ (R.196, R.249): $x" ;; esac
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  [ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "exercise: broken and solved print the same (R.196)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" = 19 ] || die "exercise: the spoken line is the brief's 19 words: $EXW"
  x=${x#PASS }
  echo "  exercise: bash and zsh alike - $x; each file's What it prints = the run, the two md5s differ; $EXW words"
  VALS="$VALS · exercise: $x ($EXW words)"; }
cap fix fix; chk fix fix .r-fix.out; pub fix
cap sql sqlt; chk sql sql .r-sql.out; pub sql
cap paging paging; chk paging paging .r-paging.out; pub paging
cap bags bags; chk bags bags .r-bags.out; pub bags
cap anchor anchor; chk anchor page .r-anchor.out; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# S5.5 (R.288): the slide's table - every line between README.md's table markers is a line the fix check printed, row and derived
# line alike, so a typed cell, a typed label or a row the run did not print fails here
TB=$(awk '/^<!-- table: begin -->$/ { t = 1; next } /^<!-- table: end -->$/ { t = 0 } t && /^  / { print }' README.md)
[ "$(printf '%s\n' "$TB" | $G -c '^  row: ')" -ge 9 ] || die "S5.5: README.md's table (between its markers) must hold the fix check's rows"
TBX=$(printf '%s\n' "$TB" | while IFS= read -r l; do $G -qxF -- "$l" .harness/chk-fix.out || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ -z "$TBX" ] || die "S5.5: README.md's table holds a line the fix check did not print (a typed cell or label): $TBX"
echo "  S5.5: README.md's table - $(printf '%s\n' "$TB" | $G -c .) lines, each one the fix check printed (rows, labels read off the run, the derived batch line)"
# R.302: every line of README.md's ```text blocks is a line a run printed - a capture's or a check's (leading spaces aside)
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed"
VS="the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw tokens, 0 raw passwords
for f in .harness/raw-* .harness/rawpw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token or the password ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$PW" "$f")" = 0 ] || die "$f holds the token or the password, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] && [ "$PGJVM" -gt 0 ] || die "no JVM ran, or none on PostgreSQL"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -vE '^    [-+]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number (the quoted diff lines of the change aside)"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|virtual-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp, a thread number or a context's start date"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|Debian|pgdg' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b|[0-9] ns ' "$f" || die "$f holds a millisecond or nanosecond figure (R.207, S5.2)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'password=[^<]' "$f" || die "$f holds a password in a URL"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2010[0-3]' || die "$f holds a URL (only TiffinBox's own loopback ports 20100-20103 may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.w' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token and password copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs, $PGJVM of them on PostgreSQL); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond or nanosecond figure, thread number, OS token, unmasked identity, password, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no H2 file"
# ---- the end: the anchor, the container, the ports ------------------------------------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
pgrm; [ -z "$(docker ps -a --filter "name=^/$CN\$" --format '{{.Names}}' 2> /dev/null)" ] || die "the container $CN is still there"
beforetree end; anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20100-20109 at the end - TiffinBox bound 20100-20103 and stopped, the H2 server 20107 and stopped, the container 20108 and removed; 20104-20106 and 20109 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit31: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens, 0 raw passwords; no port bound but 20100-20103, 20107 and 20108"
