#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Testing the JDBC Layer - this unit's receipts. Section 1's second anchor change, TEST SCOPE ONLY: before/ is a link to
# ../c8-unit02/after (units 03-06 changed nothing), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on.
# tiffinbox-web gains spring-boot-starter-data-jdbc-test (test scope), slice/JdbcSlice and com/tiffinbox/jdbc/CustomerAggregatesIT;
# nothing in src/main moves. Eight captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every
# number the video may say is asserted right after its capture by harness/chk07.py against a second witness of the same run (Surefire's
# XML against Maven's Results lines, the engine's events against Testcontainers' log, the connection's product line against Flyway's
# Database line, V2's seed rows against the counts, the repository's findAll() against JdbcTemplate's count) - never a typed figure.
#   tests       mvn verify on after/'s copy (the anchor's recipe): the two slice tests' lines, Surefire per report folder, the creates
#               and the pulls; the three verifies' logs are kept, one per pass
#   slice       what the slice started, read off the same pass's verify log (beans, the configuration, spring.sql.init, the history)
#   sql         the @Sql sequence: a harness copy of the IT with an @AfterAll hook (its own JdbcTemplate on the container): 5, 5, 4
#   wrongslice  a harness copy started from DataSlice: Unable to retrieve @EnableAutoConfiguration base packages, exit 1
#   nocontainer harness copies: @ServiceConnection removed (H2, green, the container created and unused); and without Q, on H2 and on
#               PostgreSQL - every line with the database that answered
#   nodocker    mvn verify and mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1)
#   seven       the comparison set on before/'s and after/'s jars (H2, port 20462); Hibernate's schema script = xcheck.sql
#   exercise    exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed). Every JVM and every Maven
# run runs under an alarm (perl -e 'alarm N; exec ...'; R.247). Every docker call names its socket (docker -H "$DH"). Testcontainers runs
# with Ryuk off (TESTCONTAINERS_RYUK_DISABLED=true, the env alone - Ryuk's image is not on this machine and nothing may be pulled); its
# containers are removed by Testcontainers, and by the trap with their volumes (rm -fv, by label) if a run is interrupted; the image
# list and the volume count are asserted unchanged after every Maven run. Ports (20460-20469): 20460 never bound (the slice binds none) ·
# 20461 never bound (no container of this script's own: the second client is a JdbcTemplate) · 20462 TiffinBox for the seven ·
# 20463-20469 spare, never bound; Testcontainers' host ports are OrbStack's (ephemeral, masked). Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
# tcrm: Testcontainers' own containers (label org.testcontainers=true) - Ryuk is off, so a killed test JVM leaves its container: rm -fv,
# each container AND its anonymous volume (R.322), again until docker ps -a lists none
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) (label org.testcontainers=true) removed with their volumes (rm -fv)" >&3; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (Hibernate's schema probe is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git tar /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250 -------------------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh xcheck.sql' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk07.py dur8.py logback.xml s807.py src surefire.py tree07.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/x/XMain.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'OnWhichDatabaseIT.java README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (unit 02's copy), byte for byte"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (unit 07 moves no JPA mapping)"
[ -L before ] && [ "$(readlink before)" = ../c8-unit02/after ] || die "R.211: before must be a link to ../c8-unit02/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '4cb088a^{commit}' > /dev/null 2>&1 || die "unit 06's commit 4cb088a is not in this repository's history"
UC=$(git -C "$UP" log --oneline 60d5a0c..4cb088a -- c8-tiffinbox 2> /dev/null; echo "rc $?")
[ "$UC" = 'rc 0' ] || die "R.211: a commit between unit 02's (60d5a0c) and unit 06's (4cb088a) touched c8-tiffinbox: $(printf '%s\n' "$UC" | head -2 | paste -sd';' -)"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree07.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree07.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
echo "  before -> $(readlink before) (a link: units 03-06 committed nothing under c8-tiffinbox - git log 60d5a0c..4cb088a -- c8-tiffinbox: no line)"
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s807.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness after/tiffinbox-web/src/test)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE 'PENDING|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise after/tiffinbox-web/src/test 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or tree: $PH"
# R.224: the call-backs by title - the titles java7_series.py / java8_series.py hold, byte for byte
for t2 in 'Capstone: TiffinBox on Postgres' 'Aggregates, Not Entities'; do $G -qF -- "*$t2*" README.md || die "R.224: README.md calls the unit back by its title: $t2"; done
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: this repository test asked for PostgreSQL but ran on an embedded H2 the slice made itself. Make it use the container."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E '(^|[ ;(])docker ' | $G -vqF 'docker -H "$DOCKER_HOST" ' && die "R.344: exercise/README.md calls docker without naming the socket it exports"
printf '%s\n' "$SETUP" | sed -n 4p | $G -qF 'image inspect' || die "the exercise needs Docker and the pinned image: its first command after the exports prints the image inspect check"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
# static: the docker socket, no container removed without its volume, no kill by name, the change itself (chk07.py static), R.250
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "S6.10/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: ${RMF:-none})"
ST=$(python3 -I -B harness/chk07.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | sed 's/^/  /'
R250=$(python3 -I -B harness/chk07.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | sed 's/^/  /'
echo "  prose, per sentence (s807, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · dish names 0 · placeholders 0 · Course 7's capstone and unit 02 called back by title · no java block"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); docker on the exported socket, the image inspect first"
echo "  static: no kill by name; every docker call on the pinned socket; every container removal dk rm -fv (R.322, S6.10)"
# mask: the duration words a builder must never pass on (R.366) - its self-test feeds the planted lines
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/scanning in [0-9]+ ms/, "scanning in <t>")
    gsub(/ started in PT[0-9.]+S/, " started in PT<t>S")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 1 JDBC repository interface.' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container postgres@sha256:77f5 started in PT1.2S' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT1" in t or "3.982" in t or "00:00.026" in t else 0)' || die "R.366: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, execution-time and started-in-PT lines unmasked (R.366); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"

# ---- docker and ports: the baselines, Ryuk (R.318) -------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
IID=$(dk image inspect --format '{{.Id}}' "$IMG" 2> /dev/null | cut -c8-19)
[ "$IID" = 77f585114c32 ] || die "the image $IMG is not on this machine (its id: ${IID:-none}) - this script never pulls"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container (label org.testcontainers=true) exists before the run - an interrupted run's? remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20460 20461 20462 20463 20464 20465 20466 20467 20468 20469"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · the image $IMG present, id $IID (never pulled) · images named ryuk $RY0 · Testcontainers containers 0 · ~/.testcontainers.properties absent · ports 20460-20469 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds -------------------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/home
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s1) is missing - README.md, The repository"
for a in org/springframework/boot/spring-boot-starter-data-jdbc-test/4.1.2/spring-boot-starter-data-jdbc-test-4.1.2.jar org/springframework/boot/spring-boot-data-jdbc-test/4.1.2/spring-boot-data-jdbc-test-4.1.2.jar org/testcontainers/testcontainers/2.0.5/testcontainers-2.0.5.jar org/testcontainers/testcontainers-postgresql/2.0.5/testcontainers-postgresql-2.0.5.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
[ ! -e "$M2/org/apache/maven/plugins/maven-failsafe-plugin" ] || die "maven-failsafe-plugin is in .m2-demo - the course's seed holds none (⚑7)"
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
for t in before after; do copy $t .harness/$t; done
copy after .harness/tests; copy after .harness/probe; copy after .harness/ex0
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after; do
  bg "cd .harness/$t && $MV clean package -DskipTests" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
bg "cd .harness/ex0 && $MV \"$AL\" clean test-compile" .harness/build-ex0.log
[ "$RE" = 0 ] || { tail -20 .harness/build-ex0.log >&3; die ".harness/ex0 did not compile offline (exit $RE)"; }; offl .harness/build-ex0.log
mkdir -p .harness/lib-nofly
for j in $(ls .harness/after/$XD/lib); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../after/$XD/lib/$j .harness/lib-nofly/$j ;; esac; done
bg "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/x/XMain.java" .harness/javac.log
[ "$RE" = 0 ] || die "Hibernate's schema probe did not compile: $(head -5 .harness/javac.log)"
TF=secrets/tiffinbox/shutdown-token
mkdir -p .harness/after/secrets/tiffinbox .harness/before/secrets/tiffinbox
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/after/$TF && cp .harness/after/$TF .harness/before/$TF) || die "the token was not written"
TOKEN=$(head -1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
echo "  built before/'s and after/'s copies offline (mvn -o package -DskipTests, exit 0, 'Downloaded from' 0) and extracted their jars; .harness/ex0 (the exercise's base) compiled offline (test-compile); Hibernate's schema probe compiled; a shutdown token generated (0600, never printed)"

# ---- helpers -------------------------------------------------------------------------------------------------------------------
unpub=""; CAPRUN=0
cap() { local nm=$1 i; shift
  for i in 1 2 3; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]+|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw: $($G -oE 'localhost:[0-9]+' .harness/cap.raw | head -1)"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk07.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk07 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk07.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
# after every Maven run: the images, the volumes, Testcontainers' containers, the seed (R.318, R.322)
dockeq() { local v i r c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); v=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' '); r=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] && [ "$r" = 0 ] || die "$1: the images moved (or a ryuk image appeared) - nothing may be pulled"
  [ "$v" = "$VOL0" ] || die "R.322: $1: the volume count moved, $VOL0 -> $v"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list, none named ryuk) · volumes $v · Testcontainers containers 0 · .m2-demo's files $n (unchanged)"; }
# mvnrun DIR LABEL ARGS: one Maven run under its alarm, the engine's events over its window, the seed, the images, the volumes
MVE=""; MPRE=""
mvnrun() { local d=$1 l=$2 a=$3 t0 t1 e=0 n im
  [ "$(dk image inspect --format '{{.Id}}' "$IMG" 2> /dev/null | cut -c8-19)" = 77f585114c32 ] || die "$l: the pinned image is gone before the run - Testcontainers would pull it"
  echo "\$ cd $d && ${MPRE:+$MPRE }$MV $a"
  t0=$(date +%s); (cd "$d" && eval "${MPRE:+$MPRE }$MV $a") > .harness/$l.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""; t1=$(date +%s); MVE=$e
  sleep 1; dk events --since "$t0" --until "$((t1 + 1))" --filter type=image --filter type=container --format '{{.Type}} {{.Action}} {{.Actor.Attributes.image}}' > .harness/$l.events 2> /dev/null || true
  [ "$e" != 142 ] || die "$l: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/$l.log || true)
  im=$($G '^container create ' .harness/$l.events | awk '{ print $3 }' | sort -u | paste -sd' ' -)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/$l.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  echo "  the engine's events over its window (the pinned CLI): image pull $($G -c '^image pull' .harness/$l.events || true) · container create $($G -c '^container create ' .harness/$l.events || true) (${im:-none}) · Testcontainers' log: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/$l.log || true) · 'Pulling' $($G -c 'Pulling' .harness/$l.log || true) · 'Ryuk has been disabled' $($G -c 'Ryuk has been disabled' .harness/$l.log || true)"
  [ "$n" = 0 ] || die "$l: Maven downloaded"
  dockeq "$l"; }
results() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/^\[[A-Z]+\] /  Surefire'"'"'s Results line: /'; }
SR=tiffinbox-web/target/surefire-reports; SRI=tiffinbox-web/target/surefire-reports-it
jit() { $G -E '^JDBC IT ' "$1" | sed 's/^/  /'; }
seg() { awk -v c="$2" '$0 ~ ("Running com\\.tiffinbox\\.jdbc\\." c "$") { f = 1 } f { print } f && $0 ~ ("Tests run: .* in com\\.tiffinbox\\.jdbc\\." c "$") { exit }' "$1"; }
sqlsel() { $G -oE 'Executing prepared SQL statement \[SELECT [^]]*\] *$|Executing prepared SQL statement \[SELECT [^]]*\]' "$1" | sed -E 's/^Executing prepared SQL statement \[//; s/\] *$//' | $G -E 'FROM "?customer"?$' | sort -u | sed 's/^/  the SQL Spring Data JDBC sent for findAll(), its JdbcTemplate log: /'; }
pgr() { python3 -I harness/surefire.py "$1" | sed 's/^/  /'; }

# ---- the captures --------------------------------------------------------------------------------------------------------------
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true    # the anchor README's two export lines (the nodocker runs set Maven's DOCKER_HOST alone)
tests() { echo "-- after/ copied to .harness/tests; mvn verify, the anchor's recipe (DOCKER_HOST, Ryuk off, a receipt home), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  mvnrun .harness/tests verify-$CAPRUN "\"$AL\" clean verify"
  cp .harness/verify-$CAPRUN.log .harness/verify.log
  echo "  the two slice tests' lines (CustomerAggregatesIT, stdout):"; $G -E '^JDBC IT test [12] ' .harness/verify.log | sed 's/^/  /'
  echo "  the database Flyway saw in the slice (its Database line): $($G -oE 'Database: jdbc:postgresql://localhost:[0-9]+/test[^ ]* \(PostgreSQL [0-9.]+\)' .harness/verify.log | sed -E 's/localhost:[0-9]+/localhost:<port>/' | sort | uniq -c | sed -E 's/^ *([0-9]+) (.*)/\2 - \1 lines/' | paste -sd';' -)"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  echo "  the verify log: 'Found 1 JPA repository interface' $($G -c 'Found 1 JPA repository interface' .harness/verify.log || true) · 'Found 1 JDBC repository interface' $($G -c 'Found 1 JDBC repository interface' .harness/verify.log || true) · Testcontainers 2.0.5 $($G -c 'Testcontainers version: 2.0.5' .harness/verify.log || true)"; }
slice() { local L=.harness/verify-$CAPRUN.log
  echo "-- the slice, read off the same pass's verify log (the tests capture's: pass 1's for pass 1, and so on) - CustomerAggregatesIT's first test, from inside it:"
  $G -E '^JDBC IT (the configuration|beans |spring\.sql\.init|flyway_schema_history)' "$L" | sed 's/^/  /'
  awk '/Running com\.tiffinbox\.jdbc\.CustomerAggregatesIT$/ { f = 1 } f { print } f && /Tests run: .* in com\.tiffinbox\.jdbc\.CustomerAggregatesIT$/ { exit }' "$L" > .harness/slice-seg.log
  echo "  its log, from 'Running com.tiffinbox.jdbc.CustomerAggregatesIT' to its Tests run line: 'Found 1 JDBC repository interface' $($G -c 'Found 1 JDBC repository interface' .harness/slice-seg.log || true) · 'Found 1 JPA repository interface' $($G -c 'Found 1 JPA repository interface' .harness/slice-seg.log || true) · HHH000001 (Hibernate starting) $($G -c 'HHH000001' .harness/slice-seg.log || true) · 'Successfully applied 3 migrations' $($G -c 'Successfully applied 3 migrations' .harness/slice-seg.log || true) · 'Creating container for image' $($G -c 'Creating container for image: ' .harness/slice-seg.log || true) · 'Tomcat started' $($G -c 'Tomcat started' .harness/slice-seg.log || true)"
  echo "  listening on 20460 while nothing runs: $(listeners 20460) (the slice binds no port)"; }
probe() { local l=$1 t=$2
  rm -rf .harness/probe/$SR
  mvnrun .harness/probe "$l-$CAPRUN" "\"$AL -Dlogging.level.org.springframework.jdbc.core.JdbcTemplate=debug\" -Dtest=$t -Dsurefire.failIfNoSpecifiedTests=false test"
  cp .harness/$l-$CAPRUN.log .harness/$l.log
  echo "  Surefire's reports:"; pgr .harness/probe/$SR; results .harness/$l.log; }
sql() { echo "-- the @Sql fixture: harness copy AfterTheClassIT (the shipped IT + an @AfterAll hook with a JdbcTemplate of its own on the container), PostgreSQL:"
  probe sql AfterTheClassIT
  $G -E '^JDBC IT (test [12] (customers|the database)|after the class)' .harness/sql.log | sed 's/^/  /'
  echo "  V2's seed (tiffinbox-core's V2__seed.sql): INSERT INTO customer lines $($G -c '^INSERT INTO customer ' after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql || true)"; }
wrongslice() { echo "-- harness copy WrongSliceIT: the shipped IT started from Spring Data JPA's DataSlice:"
  probe wrongslice WrongSliceIT
  echo "  the log's first IllegalStateException line: $($G -m1 -oE 'java\.lang\.IllegalStateException: Unable to retrieve @EnableAutoConfiguration base packages' .harness/wrongslice.log || echo none)"; }
nocontainer() { echo "-- harness copy NoServiceConnectionIT: the shipped IT with @ServiceConnection removed, @Container kept, JdbcSlice (Q imported):"
  probe nocontainer-a NoServiceConnectionIT
  $G -E '^JDBC IT (test [12] |flyway_schema_history)' .harness/nocontainer-a.log | sed 's/^/  /'; sqlsel .harness/nocontainer-a.log
  echo "-- the same without Q (harness copy NoServiceConnectionNoQIT, started from JdbcSliceNoQ), and the shipped IT without Q on the container (NoQIT):"
  probe nocontainer-b 'NoServiceConnectionNoQIT,NoQIT'
  for c in NoServiceConnectionNoQIT NoQIT; do seg .harness/nocontainer-b.log $c > .harness/seg-$c.log
    echo "  $c's own lines (its log, from 'Running' to its Tests run line):"
    $G -E '^JDBC IT test [12] (the database|customers)' .harness/seg-$c.log | sed 's/^/  /'
    echo "  $c: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/seg-$c.log || true) (its log)"
    sqlsel .harness/seg-$c.log; done; }
nodocker() { echo "-- after/'s copy (.harness/tests), Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1): mvn verify, then mvn package:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests nodocker-verify "\"$AL\" clean verify"
  echo "  'Could not find a valid Docker environment': $($G -c 'Could not find a valid Docker environment' .harness/nodocker-verify.log || true) lines"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/nodocker-verify.log
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  mvnrun .harness/tests nodocker-package "\"$AL\" clean package"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/nodocker-package.log; }
XA=('--spring.datasource.url=jdbc:h2:mem:x07;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
seven() { local t i c e a
  echo "-- Hibernate's schema script over after/'s libraries without Flyway's three jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  echo "\$ cd .harness/run && perl -e 'alarm 240; exec @ARGV' java $JL -cp \"../hc:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\""
  (cd .harness/run && exec perl -e 'alarm 240; exec @ARGV' java $JL -cp "../hc:../lib-nofly/*" probe.x.XMain "${XA[@]}") > .harness/x.log 2>&1 < /dev/null & pid=$!; e=0; wait "$pid" || e=$?; pid=""
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  echo "  exit $e · the script's md5: $(md5 -q .harness/run/hibernate-ddl.sql) · xcheck.sql (= Course 7's capstone's): $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/run/hibernate-ddl.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  for t in before after; do i=0; e=0
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port 20462:"
    echo "\$ cd .harness/$t && perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20462"
    (cd .harness/$t && exec perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20462) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20462/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on 20462"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · listens on: $a"
    $G -oE 'Found [0-9]+ J[A-Z]+ repository interfaces?\.' .harness/seven-run.log | sed 's/^/  log: /'
    echo "\$ \$CURLSET 20462 .harness/$t/$TF"
    "$CURLSET" 20462 .harness/$t/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-$t.txt || true
    i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
    kill -0 "$pid" 2> /dev/null && die "TiffinBox on 20462 was still running after POST /shutdown"
    wait "$pid" || e=$?; pid=""
    [ "$(listeners 20462)" = 0 ] || die "something still listens on 20462"
    echo "  exit $e · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt) · listening on 20462 now: 0"
    ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/ex.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"
  dockeq "the exercise's $sh"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with; DOCKER_HOST only as the block exports it), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }

cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk07.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk07)"
pub exercise
cap tests tests; chk tests .r-tests.out; pub tests
cap slice slice; chk slice .r-slice.out; pub slice
# the harness copies, derived and compiled only now - after the tests capture, so a planted shipped IT meets that capture's checks first
VAR=$(python3 -I -B harness/variants.py .harness/probe) || die "the harness copies could not be derived: $VAR"
bg "cd .harness/probe && $MV \"$AL\" clean test-compile" .harness/build-probe.log
[ "$RE" = 0 ] || { tail -20 .harness/build-probe.log >&3; die ".harness/probe did not compile offline (exit $RE)"; }; offl .harness/build-probe.log
echo "  .harness/probe (after/ + harness/variants.py's copies) compiled offline (test-compile, exit 0, 'Downloaded from' 0); the harness copies, each derived from after/'s files at run time and asserted to differ by its named change alone:"
printf '%s\n' "$VAR" | sed 's/^/    /'
cap sql sql; chk sql .r-sql.out; pub sql
cap wrongslice wrongslice; chk wrongslice .r-wrongslice.out; pub wrongslice
cap nocontainer nocontainer; chk nocontainer .r-nocontainer.out; pub nocontainer
cap nodocker nodocker; chk nodocker .r-nodocker.out; pub nodocker
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
# R.302: every line of README.md's ```text blocks is a line a run printed; the values line is the captures'
cat .r-*.out .harness/chk-*.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
VS="the values the video may say - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give (the line is in .harness/values.txt)"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values line = the captures' ($(wc -c < .harness/values.txt | tr -d ' ') bytes)"
# hygiene
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]' "$f" || die "R.366: $f holds a time, unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"; done
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: no path, time, log time, stack frame, H2 database name, raw port or token in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: Testcontainers, the volumes, the images, the trees, the ports, the JVMs -------------------------------------------
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled); ~/.testcontainers.properties absent"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20460-20469 at the end - TiffinBox bound 20462 for the seven and stopped; 20460, 20461 and 20463-20469 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit07: every capture 3/3 and = published; every spoken number asserted by chk07.py; before/ and after/ = their pins; the volume count and the images unchanged"
