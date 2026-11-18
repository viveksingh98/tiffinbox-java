#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · The Cache Abstraction's Machinery - this unit's receipts. NO ANCHOR CHANGE: anchor is a link to ../c8-unit08/after (the
# tree unit 08 froze; ../c8-tiffinbox equals it today), pinned by harness/tree09.py and asserted equal to unit 08's own after-tree pin.
# Everything this unit measures is a HARNESS on that tree or on COPIES of it (harness/variants.py, derived at run time): the
# CacheManager Boot picks per class path and per spring.cache.type, the keys the default key generator builds, two methods that
# share one key, and the proxy in front of a harness bean (H09, a harness bean - not the anchor's cache, R.392). Two witnesses in
# every counted window (R.375): harness/src/probe/u09/Counter (unit 08's class, copied: calls that reach Spring Data JPA's
# repository, a MethodInterceptor at position 0 of its proxy) and Hibernate's getPrepareStatementCount(); every counted method body
# reads the database through that repository, and a window whose two per-call lists differ fails.
# Captures (the JVM ones run three times inside each run and hashed; the exercise once per run of record):
#   managers    seven harness JVMs on H2 in memory: the anchor (the cache starter alone); a copy + Caffeine; a copy + Spring Data
#               Redis's starter; a copy + both; the both-copy with spring.cache.type=caffeine, =simple, =none. Each prints
#               spring.cache.type, the CacheManager bean, its cache's class and native class; Redis (a container by the digest) answers PING
#   keys        the five key shapes off the native cache, and the collision: k1("a") then kSpel("a", 9) - H2 and PostgreSQL 18.6
#   proxy       the harness bean's class and advisors; all() x3 beside allViaSelf() x3; package-private x3; private x3; the public
#               final method x3 (its own JVM, its start's WARN) - H2 and PostgreSQL; the final method again with the harness's log levels
#   finalclass  FinalOne as shipped (the control) and a copy whose class is final: the start stops - H2; the anchor's Dashboard line
#   exercise    exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247).
# Every docker call names its socket (dk, R.344), --pull never; every container is removed with its volume (rm -fv, R.387).
# Ports (20480-20489): 20480 never bound (no capture starts TiffinBox's web server) · 20481 the PostgreSQL container · 20482 the
# Redis container (no password, 127.0.0.1 only) · 20483-20489 spare, never bound.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
CN=c8u09-pg; RN=c8u09-redis
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CSTARTED=""; RSTARTED=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u09.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
ctrm() { [ -z "$CSTARTED" ] || dk rm -fv "$CN" > /dev/null 2>&1 || true; CSTARTED=""; [ -z "$RSTARTED" ] || dk rm -fv "$RN" > /dev/null 2>&1 || true; RSTARTED=""; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find openssl docker git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the link, the pin, the harness, the prose, the exercise ------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md anchor exercise harness receipts.md5 receipts.sh' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk09.py dur8.py logback.xml s809.py src tree09.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u09/Counter.java probe/u09/FinalOne.java probe/u09/H09.java probe/u09/H09Final.java probe/u09/U9.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
CD=$(diff ../c8-unit08/harness/src/probe/u08/Counter.java harness/src/probe/u09/Counter.java | $G '^[<>]' | paste -sd'|' -)
[ "$CD" = '< package probe.u08;|> package probe.u09;' ] || die "harness/src/probe/u09/Counter.java must be unit 08's Counter with its package line alone changed: $CD"
[ -L anchor ] && [ "$(readlink anchor)" = ../c8-unit08/after ] || die "R.211: anchor must be a link to ../c8-unit08/after (it points at: $(readlink anchor 2> /dev/null || echo 'not a link'))"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] && die "anchor holds a secrets/ or a target/ - never built in place"
git rev-parse -q --verify '68fb5e7^{commit}' > /dev/null 2>&1 || die "unit 08's commit 68fb5e7 is not in this repository's history"
pin() { local got want; got=$(python3 -I harness/tree09.py anchor/) || die "anchor's tree could not be hashed"
  want=$(awk '$1 == "anchor-tree" { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no anchor-tree line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: anchor/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  anchor/ ($1): python3 -I harness/tree09.py anchor/ -> $got = receipts.md5's anchor-tree line"; }
pin start
U8P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit08/receipts.md5)
[ "$U8P" = "$(awk '$1 == "anchor-tree" { print $2, $3 }' receipts.md5)" ] || die "anchor's pin is not unit 08's after-tree line ($U8P)"
echo "  anchor's pin = ../c8-unit08/receipts.md5's after-tree line ($U8P), re-derived by harness/tree09.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c8-tiffinbox 2>&1 || true)
echo "  anchor/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor today' || echo 'they differ - a later unit moved the anchor; this unit measures anchor/ (unit 08 after)')"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s809.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE 'PENDING|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or harness: $PH"
for t2 in 'JDK Proxies vs CGLIB, and the Self-Invocation Trap' '@Transactional: What the Proxy Does' 'Auto-Configuration, Mechanism First' 'N+1, Measured' '@Cacheable, @CacheEvict, @CachePut' 'Caffeine'; do $G -qF -- "*$t2*" README.md || die "R.224: README.md calls the unit back by its title: $t2"; done
C4L=$(sed -n 159p ../../../spring-core/scripts-and-decks/23-jdk-proxies-vs-cglib-and-the-self-invocation-trap.md 2> /dev/null || true)
if [ -n "$C4L" ]; then $G -qxF -- "$C4L" README.md || die "README.md must quote Course 4 unit 23's script line 159 byte for byte (RED #18)"; C4Q="quoted byte for byte from ../../../spring-core/scripts-and-decks/23-…md:159"
else C4Q="the course's script folder is not beside this repository - the quote's bytes are not re-read (a clone)"; fi
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the harness's files"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: two cached methods share one cache and answer each other's calls. Give each method a key of its own."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk09.py static anchor) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | sed 's/^/  /'
echo "  prose, per sentence (s809, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · dish names 0 · placeholders 0 · called back by title · Course 4 unit 23's line: $C4Q · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); its build -pl tiffinbox-web -am"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never; every container removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/scanning in [0-9]+ ms/, "scanning in <t>")
    gsub(/initialization completed in [0-9]+ ms/, "initialization completed in <t>")
    gsub(/ started in PT[0-9.]+S/, " started in PT<t>S")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 0 Redis repository interfaces.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container redis@sha256:7958 started in PT1.2S' 'Total time:  12.345 s' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT1" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t else 0)' || die "R.366: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT and Total time lines unmasked (R.366, R.388); folders and home masked"

# ---- docker and ports: the baselines -------------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
IID=$(dk image inspect --format '{{.Id}}' "$IMG" 2> /dev/null | cut -c8-19)
[ "$IID" = 77f585114c32 ] || die "the image $IMG is not on this machine (its id: ${IID:-none}) - this script never pulls; docker -H \"\$DH\" pull $IMG is yours to run"
RID=$(dk image inspect --format '{{.Id}}' "$RIMG" 2> /dev/null | cut -c8-19)
[ "$RID" = 7958cfbb9d15 ] || die "the image $RIMG is not on this machine (its id: ${RID:-none}) - this script never pulls; docker -H \"\$DH\" pull $RIMG is yours to run"
for c in $CN $RN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20480 20481 20482 20483 20484 20485 20486 20487 20488 20489"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present, id $IID · $RIMG present, id $RID (neither pulled) · ports 20480-20489 (and 18425, 8080) free · java processes 0"

# ---- the copies, derived; the builds; the harness; the two containers -----------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/hc .harness/hcfc .harness/srcfc .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s2) is missing - README.md, The repository"
for a in com/github/ben-manes/caffeine/caffeine/3.2.4/caffeine-3.2.4.jar org/springframework/boot/spring-boot-starter-data-redis/4.1.2/spring-boot-starter-data-redis-4.1.2.jar io/lettuce/lettuce-core/7.5.2.RELEASE/lettuce-core-7.5.2.RELEASE.jar org/springframework/boot/spring-boot-cache/4.1.2/spring-boot-cache-4.1.2.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
TREES="anchor caffeine redis both"
for t in $TREES; do copy anchor .harness/$t; done
: > .harness/variants.out
for t in caffeine redis both; do
  VAR=$(python3 -I -B harness/variants.py $t .harness/$t) || die "the $t copy could not be derived: $VAR"
  [ "$(diff -rq .harness/anchor .harness/$t | paste -sd' ' -)" = "Files .harness/anchor/tiffinbox-web/pom.xml and .harness/$t/tiffinbox-web/pom.xml differ" ] || die "the $t copy differs from the anchor beyond tiffinbox-web/pom.xml"
  printf '%s\n' "the $t copy (.harness/$t), derived from the anchor's file by harness/variants.py - diff -rq against the anchor: tiffinbox-web/pom.xml alone:" "$VAR" >> .harness/variants.out; done
cp harness/src/probe/u09/*.java .harness/srcfc/
FCV=$(python3 -I -B harness/variants.py finalclass .harness/srcfc) || die "the final-class copy could not be derived: $FCV"
[ "$(diff -rq harness/src/probe/u09 .harness/srcfc | paste -sd' ' -)" = 'Files harness/src/probe/u09/FinalOne.java and .harness/srcfc/FinalOne.java differ' ] || die "the final-class copy differs from the harness beyond FinalOne.java"
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
for t in $TREES; do
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die ".m2-demo gained files over the builds - offline: no"
: > .harness/libs.out
for t in caffeine redis both; do
  echo "the $t copy's jar: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries (the anchor's $(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ')); gained, by name: $(comm -13 <(ls .harness/anchor/$XD/lib) <(ls .harness/$t/$XD/lib) | paste -sd' ' -); lost: $(comm -23 <(ls .harness/anchor/$XD/lib) <(ls .harness/$t/$XD/lib) | wc -l | tr -d ' ')" >> .harness/libs.out; done
bg "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/tiffinbox-web-1.0.0.jar:.harness/anchor/$XD/lib/*\" harness/src/probe/u09/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against the anchor's jar: $(head -5 .harness/javac.log)"
bg "javac -parameters -d .harness/hcfc -cp \".harness/anchor/$XD/tiffinbox-web-1.0.0.jar:.harness/anchor/$XD/lib/*\" .harness/srcfc/*.java" .harness/javac-fc.log
[ "$RE" = 0 ] || die "the final-class copy did not compile: $(head -5 .harness/javac-fc.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF && cp .harness/run-h2/$TF .harness/run-pg/$TF) || die "the token was not written"
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built the anchor's tree and the three copies offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0, .m2-demo's $NF0 files unchanged), extracted their jars; the harness compiled against the anchor's jar, and the final-class copy of it; a shutdown token and a PostgreSQL password generated (0600, never printed)"
sed 's/^/  /' .harness/variants.out
echo "  the final-class copy (.harness/srcfc), derived from harness/src/probe/u09 by harness/variants.py - diff -rq: FinalOne.java alone:"
printf '%s\n' "$FCV" | sed 's/^/    /'
CSTARTED=1
bg "dk run -d --pull never --name $CN -p 127.0.0.1:20481:5432 --env-file .harness/pg.env $IMG" .harness/docker-run.log
[ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run.log)"
i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "the PostgreSQL container did not accept connections (120 tries)"; sleep 0.5; done
DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -)
[ "$DP" = '5432/tcp -> 127.0.0.1:20481' ] || die "the PostgreSQL container must publish 5432 on 127.0.0.1:20481 alone: $DP"
V1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
RSTARTED=1
bg "dk run -d --pull never --name $RN -p 127.0.0.1:20482:6379 $RIMG" .harness/docker-run-redis.log
[ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
i=0; while [ "$(dk exec "$RN" redis-cli ping 2> /dev/null)" != PONG ]; do i=$((i + 1)); [ $i -lt 120 ] || die "the Redis container did not answer PING (120 tries)"; sleep 0.5; done
RP=$(dk port "$RN" 2> /dev/null | paste -sd'|' -)
[ "$RP" = '6379/tcp -> 127.0.0.1:20482' ] || die "the Redis container must publish 6379 on 127.0.0.1:20482 alone: $RP"
V2=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
RV=$(dk exec "$RN" redis-cli INFO server 2> /dev/null | tr -d '\r' | sed -n 's/^redis_version://p')
echo "  the containers: $CN from $IMG (--pull never), published $DP, user tiffinbox, its password from a 0600 file; volumes $VOL0 -> $V1 (its own)"
echo "  $RN from $RIMG (--pull never), published $RP, no password (127.0.0.1 only); redis-cli PING -> PONG; volumes $V1 -> $V2 (the image declares none)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20481/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  echo "  a fresh database: $1 (psql) · its URL in the config tree, .harness/run-pg/secrets/tiffinbox/jdbc-url (0600, never printed)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
HX=0
# hj TREE HC DB STEPS [ARGS...]: one harness JVM over TREE's jar (anchor, caffeine, redis or both), the harness classes in HC (hc, or
# hcfc - the final-class copy), on H2 (DB=h2, .harness/run-h2) or on PostgreSQL (DB=pg, .harness/run-pg, whose config tree holds the
# URL); the Redis container's address always given (a tree without Spring Data Redis ignores it); its exit asserted = $HX
hj() { local tr=$1 hc=$2 db=$3 steps=$4 c; shift 4
  c="cd .harness/run-$db && perl -e 'alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"../$hc:../$tr/$XD/tiffinbox-web-1.0.0.jar:../$tr/$XD/lib/*\" probe.u09.U9 $steps --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20482${1:+ $*}"
  echo "\$ $c" | sed 's#\.\./\.\./harness#…/harness#'
  bg "$c" .harness/h.log
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  $G -oE 'Multiple Spring Data modules found, entering strict repository configuration mode|Found [0-9]+ (JPA|JDBC|Redis) repository interfaces?|HHH000001: Hibernate ORM core version [^ ]+|FlywayExecutor : Database: .*' .harness/h.log | sed -E 's/FlywayExecutor : //; s#127\.0\.0\.1:20481/[a-z0-9]+#127.0.0.1:<port>/<db>#' | sed 's/^/  log: /'
  $G -E '^PROBE ' .harness/h.log | mask
  echo "  exit $RE · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) $($G -v '^PROBE ' .harness/h.log | $G -ic 'cache' || true) · WARN $($G -c '^WARN ' .harness/h.log || true) · ERROR $($G -c '^ERROR ' .harness/h.log || true) · 'Public final method' $($G -c 'Public final method' .harness/h.log || true) · 'Could not generate CGLIB subclass' $($G -c 'Could not generate CGLIB subclass' .harness/h.log || true) · 'final class' $($G -c 'final class' .harness/h.log || true)"
  $G -E '^(WARN|ERROR) ' .harness/h.log | sed -E 's/^(WARN|ERROR) +\[[^]]*\] /  its \1 line: /' | cut -c1-400 | mask
  [ "$RE" = "$HX" ] || die "the harness JVM exited $RE, not $HX ($tr, $db, $steps): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
AOP='--logging.level.org.springframework.aop=info --logging.level.org.springframework.cache=info'
NCAP=3
unpub=""; CAPRUN=0
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]+|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
    mask < .harness/cap.raw > ".r-$nm.$i"; i=$((i + 1)); done
  CH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-10s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-10s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-10s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk09.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk09 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk09.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
managers() {
  echo "-- the copies (harness/variants.py, at run time) and their jars:"; sed 's/^/  /' .harness/variants.out; sed 's/^/  /' .harness/libs.out
  echo "  the Redis container, by redis-cli (a second client): redis_version $RV"
  echo "-- (1) the anchor, the cache starter alone, spring.cache.type unset - H2 in memory, one JVM:"; hj anchor hc h2 info,managers
  echo "-- (2) the caffeine copy (+ caffeine), spring.cache.type unset - H2 in memory, one JVM:"; hj caffeine hc h2 info,managers
  echo "-- (3) the redis copy (+ spring-boot-starter-data-redis), spring.cache.type unset - H2 in memory, Redis by the digest, one JVM:"; hj redis hc h2 info,managers
  echo "-- (4) the both copy (+ caffeine + spring-boot-starter-data-redis), spring.cache.type unset - H2 in memory, Redis by the digest, one JVM:"; hj both hc h2 info,managers
  for ty in caffeine simple none; do
    echo "-- (5) the both copy, spring.cache.type=$ty - H2 in memory, Redis by the digest, one JVM:"; hj both hc h2 info,managers --spring.cache.type=$ty; done; }
keys() {
  echo "-- the anchor, H2 in memory, one JVM:"; hj anchor hc h2 info,keys,pair
  echo "-- the anchor, PostgreSQL 18.6 (the container, by the digest), one JVM, the jar's own driver:"; pgdb u09k; hj anchor hc pg info,keys,pair; pgdrop u09k; }
proxy() {
  echo "-- the anchor, H2 in memory, one JVM, Spring's AOP and cache loggers at INFO (Boot's default level):"; hj anchor hc h2 info,bean,self,pkg,priv $AOP
  echo "-- the anchor, H2 in memory, one JVM with H09Final as a source, the same loggers at INFO:"; hj anchor hc h2 info,final $AOP
  echo "-- the anchor, PostgreSQL 18.6 (the container, by the digest), one JVM, the same loggers at INFO:"; pgdb u09p; hj anchor hc pg info,bean,self,pkg,priv $AOP
  echo "-- the anchor, PostgreSQL 18.6, one JVM with H09Final as a source, the same loggers at INFO:"; hj anchor hc pg info,final $AOP; pgdrop u09p
  echo "-- the contrast: the anchor, H2 in memory, one JVM with H09Final as a source, the harness's logback.xml alone (its root at WARN):"; hj anchor hc h2 info,final; }
finalclass() {
  echo "-- the anchor's own Dashboard (tiffinbox-core), its class line:"
  $G -n '^public final class' anchor/tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java | sed 's/^/  Dashboard.java:/'
  echo "  an @Cacheable line (an annotation, not a comment) in the anchor's src/main: $($G -rlE '^ *@Cacheable' anchor/tiffinbox-core/src/main anchor/tiffinbox-web/src/main | sed 's#^anchor/##' | paste -sd' ' -)"
  echo "-- the control: FinalOne as shipped (Reads, not final) - H2 in memory, one JVM:"; hj anchor hc h2 info,fclass
  echo "-- the copy: FinalOne with Reads final (harness/variants.py finalclass) - H2 in memory, one JVM:"; HX=1; hj anchor hcfc h2 info,fclass; HX=0; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk09.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk09)"
pub exercise
NCAP=3
cap managers managers; chk managers .r-managers.out; pub managers
cap keys keys; chk keys .r-keys.out; pub keys
cap proxy proxy; chk proxy .r-proxy.out; pub proxy
cap finalclass finalclass; chk finalclass .r-finalclass.out; pub finalclass
# R.302: every line of README.md's ```text blocks is a line a run printed; the values line is the captures'
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
VS="the values the video may say - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give (the line is in .harness/values.txt)"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values line = the captures' ($(wc -c < .harness/values.txt | tr -d ' ') bytes)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]' "$f" || die "R.366: $f holds a time, unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: no path, time, log time, stack frame, H2 database name, raw port, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, the volumes, the images, the tree, the ports --------------------------------------------------------
dk rm -fv "$CN" > /dev/null 2>&1 || die "the PostgreSQL container could not be removed"; CSTARTED=""
dk rm -fv "$RN" > /dev/null 2>&1 || die "the Redis container could not be removed"; RSTARTED=""
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ "$(find "$M2" -type f | wc -l | tr -d ' ')" = "$NF0" ] || die ".m2-demo gained files over this run - offline: no"
echo "  docker at the end: $CN and $RN removed with their volumes (rm -fv); volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled); .m2-demo's files unchanged"
pin end
AD2=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c8-tiffinbox 2>&1 || true)
[ "$AD2" = "$AD" ] || die "../c8-tiffinbox moved against anchor/ over this run"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20480-20489 at the end - the containers bound 20481 and 20482 and are gone; 20480 and 20483-20489 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit09: every capture = published (JVM captures 3/3 in this run; the exercise once per run); every spoken number asserted by chk09.py; anchor/ = its pin (unit 08's after-tree); the volume count and the images unchanged"
