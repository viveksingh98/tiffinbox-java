#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Money in the Database - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit09/after, the
# tree Section 2 froze (= ../c7-tiffinbox when this unit was built; compared at the start and the end, a note when they differ, never
# a stop - R.211). Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number
# and string the video says is asserted right after its capture by a check that can fail. Two databases: H2 in a harness JVM's
# memory, and PostgreSQL 18.6 in a container of this run's (postgres@sha256:77f58511..., --pull never, published on 127.0.0.1:19938
# only), the container removed at the end and by the trap. Every capture says which database answered (a database: line per
# factory). The money entities (package probe.map.money, English names only): Bill (amount numeric(10,2), no @Digits), PlainBill (a
# bare BigDecimal), DoubleBill (a double), DigitsOnlyBill (@Digits alone), DigitsBill (@Digits(integer = 8, fraction = 2) beside
# @Column(precision = 10, scale = 2) - the shipped class S2.4's check reads), ScaleThreeBill (DigitsBill with scale = 3 - the plant,
# shipped as its own class so a capture shows it), SixDigitsBill (@Digits(integer = 6) beside @Column(precision = 10)).
#   course2   Course 2's money lesson read off its files: its title, Money.java's thirty additions and the bill's rounding,
#             Rounding.java's 1.005, its README's two measured lines - each by sed -n, each file's md5 asserted
#   ddl       Hibernate's DDL for the seven, on H2 and on PostgreSQL, Bean Validation as Hibernate finds it and then switched off
#             (jakarta.persistence.validation.mode=NONE) - the scripts compared byte for byte, across the two and across the databases
#   values    one Bill per value, one transaction each, on H2 and on PostgreSQL: the bind logger's value (what Hibernate sent), the
#             managed object after the flush (the same persistence context), the row by a second connection, a new EntityManager's
#             read; then the 11-digit value in its own JVM - the failure receipt (DataException, exit 1), each database's message
#   double    Course 2's thirty additions of 120.10 in a double, stored and read back through JDBC, on H2 and on PostgreSQL
#   digits    A/B/A' (R.1): A DigitsBill - 120.105 refused before any SQL; B Bill - stored as 120.11; A' = A, a fresh JVM; on H2 and
#             on PostgreSQL. Then S2.4's check (R.209): both annotations read off the class files (javap), beside Hibernate's DDL -
#             passing on DigitsBill; on ScaleThreeBill the DDL-only check PASSES (the check that cannot fail) and S2.4's FAILS
#   xcheck    the harness's DDL for the anchor's CustomerEntity and PauseEntity against Boot's script as the owning-side lesson
#             captured it (its md5, f5956370..., in ../c7-unit09/README.md - R.212, RED #308: this unit runs no Boot)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f (H2 in memory, one fresh JVM per block)
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar is extracted (the anchor's own line) - its libraries hold Hibernate Validator 9.1.5.Final and an EL implementation, which
# the digits capture uses. The PostgreSQL driver is resolved by Maven from .m2-demo (harness/pom.xml: Boot's managed version, none
# written). The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with javac -parameters against that
# extracted jar and the driver into .harness/hc. probe.map.H builds one EntityManagerFactory per factory a run asks for (Jakarta
# Persistence 3.2's PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's own
# database only) over a DataSource wrapped in a proxy that counts the driver calls. It runs from .harness/run and binds no port.
# Its JVM's flags travel as an array, V, its arguments as an array, A (R.193). Commands are printed exactly as they run: each goes
# through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) gates this unit's prose: it speaks no time
# (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale and the zone: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US: the validator's message is a locale's) and its zone (-Duser.timezone=UTC), and the checks
# refuse a java line without either; a TZ variable of yours is unset first; the test JVM's locale comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. The image is never pulled (--pull never; a missing image stops the run with the pull line to type). At run time
# nothing leaves the computer: H2 in a JVM's memory, PostgreSQL on 127.0.0.1. This unit reads no version file: unit 06 made the
# section's dated sweep (R.223).
# The database password: 24 characters this script generates at every run (never committed; bounded: 4,096 bytes of /dev/urandom),
# held in .harness/pg/password (mode 0600); the harness reads that file (-Dpg.passfile=) and never prints it. Every raw capture
# run is counted for it before the mask - 0 raw copies, else the run stops - and at the end the whole folder holds it once: its file.
# Masks (README.md declares each; awk gsub only): the password "[masked: the 24-character password]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; an identity hash "@…"; Hibernate's generated
# constraint names "FK<hash>" and "UK<hash>"; H2's generated index and constraint names "PRIMARY_KEY_<n>", "CONSTRAINT_<n>".
# A harness JVM's log is printed whole (every line, trailing spaces dropped).
# Ports (§P, 19930-19939): the container 19938, published on 127.0.0.1 only (docker port asserted); 19939 never bound. Every one of
# 19930-19939 is checked free at the start and the end (19938 after the container is gone), with 18425 (TiffinBox's default), 8080
# and 35729. The anchor's tests (inside its package build) bind what TiffinBox's tests bind; the harness's JVMs and the exercise
# bind none.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
PGN=c7-u14-pg; PGP=19938
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a harness JVM, a Maven, Surefire's fork - is stopped; then
# this run's container is removed (docker rm -f), if this run started it. After an interrupt a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C, and the script still exits 130 after
# an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""; PGUP=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.map.Main") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$PGUP" ] || docker rm -f "$PGN" > /dev/null 2>&1 || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
javap -version 2>&1 | $G -q '^25' || die "javap 25 needed (S2.4's check reads the class files with it)"
for t in python3 rsync lsof unzip mvn md5 cmp docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a JVM's zone or a build setting (the problem-detail lesson's
# loop: a canary planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGUSER PGHOST PGTZ TZ DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|TZ|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - nothing here needs one"
# No anchor change: anchor/ is the link to ../c7-unit09/after, the frozen tree this unit reads. It equals ../c7-tiffinbox until a
# later unit changes the anchor - a note then, never a stop (R.211, the Course 6 form)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit09/after ] || die "anchor must be the link to ../c7-unit09/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit09/after (frozen); diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit09/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
# ⚑4, CARRIED: the anchor's own money column stays an INT of rupees - read off the frozen tree, named, never changed here
$G -qE '^ +price_per_meal INT +NOT NULL,$' anchor/tiffinbox-core/src/main/java/com/tiffinbox/Database.java && $G -qxF '    private int pricePerMeal;' anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java || die "the anchor's price_per_meal is no longer an INT column (Database.java) and an int field (CustomerEntity.java) - CARRIED (⚑4) says it stays one"
echo "  (terminal only) CARRIED (⚑4): the anchor's price_per_meal is an INT of rupees (Database.java's DDL, CustomerEntity's int pricePerMeal) - named, not changed" >&3
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/map
HFILES='dur7.py logback.xml pom.xml src'
SFILES='probe/map/H.java probe/map/Main.java probe/map/ex/Bill.java probe/map/money/Bill.java probe/map/money/DigitsBill.java probe/map/money/DigitsOnlyBill.java probe/map/money/DoubleBill.java probe/map/money/PlainBill.java probe/map/money/ScaleThreeBill.java probe/map/money/SixDigitsBill.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19930 19931 19932 19933 19934 19935 19936 19937 19938 19939"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
# the image, by digest, already on this computer (a receipt never pulls); no container of this unit's name
docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack here); this unit runs PostgreSQL 18 in a container"
[ "$(docker image inspect "$IMG" --format '{{.Id}}' 2> /dev/null || true)" = "${IMG#postgres@}" ] || die "the image is not on this computer: docker pull $IMG"
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "a container named $PGN exists - an interrupted run's? remove it: docker rm -f $PGN"
rm -rf .harness; mkdir -p .harness/run .harness/pg .harness/drv .harness/hc


# ---- duration words: none - this unit speaks no time (R.172); English names only (R.215); no typed result ------------------
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
n = 0
for f in sys.argv[2:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1
            print("  %s line %d: %s  <- not allowed: this unit speaks no time" % (f, i, w.group(0)))
print("duration words: %d" % n)
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0' || die "dur7.DUR found a duration word - this unit speaks no time (R.172): $(printf '%s\n' "$DW" | $G 'not allowed' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md) - this unit speaks no time"
# R.215: English names only - the AI voice mispronounces Indian dish names (the course's memory rule); the list is refused, whole
# words, any case, in this unit's prose, its harness and (at the end) every capture
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain|curry|curries'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes harness/src exercise README.md)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
# A result is what a database or Java hands back, never typed: no rounded amount, no double's error, no whole double in the harness
TY=$($G -rnoE '120\.11|3693\.08|3602\.99|"3603"|-120\.11' harness/src | head -3 | paste -sd';' - || true)
[ -z "$TY" ] || die "a typed result in the harness - every amount it prints is one Java computed or a database handed back: $TY"
echo "  typed results in the harness: 0 (no 120.11, 3693.08, 3602.99…, \"3603\" - the inputs are the receipt's, the outputs the run's)"
# ---- Course 2, read off its files: Money.java, Rounding.java, README.md in this repository; the title beside it (asserted when there)
C2D=../c2-unit21; C2M=$C2D/Money.java; C2R=$C2D/Rounding.java; C2T=$C2D/README.md
C2MMD5=490ab5a990f35f88a6b7fb798b868d27; C2RMD5=a7ce857d8d92aa02b7f5512fbbad9289; C2TMD5=d7ca9f3e2b697c7abe83f94cd5759d8b
J2="$HOME/Desktop/PromptVidya-Automation/java2_series.py"
T21='Money, Overflow and the Bill That Was Wrong'
for f in "$C2M:$C2MMD5" "$C2R:$C2RMD5" "$C2T:$C2TMD5"; do [ -f "${f%:*}" ] && [ "$(md5 -q "${f%:*}")" = "${f##*:}" ] || die "${f%:*} is missing or not Course 2's shipped file (md5 ${f##*:})"; done
if [ -f "$J2" ]; then
  [ "$(sed -n -E 's/^ *"21": "([^"]*)",$/\1/p' "$J2")" = "$T21" ] || die "java2_series.py's \"21\" entry is not the title this script holds: $T21"
  echo "  (terminal only) java2_series.py's \"21\" entry = $T21" >&3
else echo "  (terminal only) java2_series.py is not on this computer's Desktop: the title, asserted when it was, is the check" >&3; fi

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US -Duser.timezone=UTC'
L_PG=$(mine "docker run -d --pull never --name $PGN -e POSTGRES_USER=sa -e POSTGRES_PASSWORD=\"\$PGPW\" -p 127.0.0.1:$PGP:5432 $IMG")
L_DRV=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*:.harness/drv/*\" $HS/H.java $HS/Main.java $HS/money/*.java")
L_H=$(mine "java $JL -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../drv/*\" probe.map.Main \"\${A[@]}\"")
L_JAVAP=$(mine 'javap -v -p -cp .harness/hc "$K"')
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- the password: generated now, kept in a file only this user reads, never printed -------------------------------------
PGPW=$(head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 24)   # bounded: a tr reading /dev/urandom itself never ends where SIGPIPE is ignored
[ ${#PGPW} = 24 ] || die "the generated password must be 24 characters"
PF=.harness/pg/password; (umask 077 && printf '%s\n' "$PGPW" > "$PF"); chmod 700 .harness/pg

# ---- build: before the captures - the anchor copied and built with its README's package line offline (its tests run); its jar
# ---- extracted (the anchor's line); the driver resolved by Maven; the harness compiled against both ---------------------------
# mbuild COMMAND LOG WHAT: offline first. If the offline build fails for want of an artifact, its log is kept beside (LOG with
# -offline), the first artifact it names is read from it, and the build runs once more without -o; the label then names that
# artifact and every repository the retry's log says it downloaded from - id, URL scheme, count - and counts the downloads whose
# URL is http(s). It never says "Maven Central" unless the log does.
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE 'Could not find artifact [^ ]+|No plugin found for prefix [^ ]+|Non-resolvable parent POM for [^ ]+' "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! $G -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: a fresh clone's first run needs .m2-demo seeded (README.md, The repository)"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
mkdir -p .harness/drvpom; cp harness/pom.xml .harness/drvpom/pom.xml
mbuild "cd .harness/drvpom && $L_DRV" .harness/build-drv.log ".harness/drvpom (harness/pom.xml: the PostgreSQL driver at the version Boot 4.1.2 manages)"
tr ':' '\n' < .harness/drvpom/classpath.txt > .harness/drv.list
while IFS= read -r j || [ -n "$j" ]; do [ -f "$j" ] || die "the driver's class path names a file that is not there: $j"; cp "$j" .harness/drv/; done < .harness/drv.list
[ "$(ls .harness/drv | paste -sd' ' -)" = 'checker-qual-3.55.1.jar postgresql-42.7.14.jar' ] || die "the driver's class path is not postgresql-42.7.14.jar and checker-qual-3.55.1.jar: $(ls .harness/drv | paste -sd' ' -)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar com/h2database/h2/2.5.250/h2-2.5.250.jar org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar org/hibernate/validator/hibernate-validator/9.1.5.Final/hibernate-validator-9.1.5.Final.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the build - README.md, The repository"; done
# the validator the digits capture needs: in the anchor's own libraries (its validation starter), with an EL implementation
VLIB=$(ls .harness/anchor/$XD/lib | $G -E '^(hibernate-validator|jakarta\.validation-api|tomcat-embed-el)-' | paste -sd' ' -)
[ "$VLIB" = 'hibernate-validator-9.1.5.Final.jar jakarta.validation-api-3.1.1.jar tomcat-embed-el-11.0.27.jar' ] || die "the anchor's libraries no longer hold Hibernate Validator 9.1.5.Final, the validation API 3.1.1 and an EL implementation: $VLIB"
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/map/ex ] || die "the exercise's classes were compiled into the harness - they are the exercise's own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries, among them $VLIB), resolved the driver ($(ls .harness/drv | paste -sd' ' -)) and compiled the harness into .harness/hc"

# ---- the container: started once, before the captures; every factory on PostgreSQL makes its own fresh database in it ---------
pgmask() { awk -v p="$PGPW" '{ gsub(p, "[masked: the 24-character password]"); print }'; }
echo "  \$ $(printf '%s\n' "${L_PG/\"\$PGPW\"/$PGPW}" | pgmask)" >&3
PGUP=1; (eval "$L_PG") > .harness/pg/cid 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/pg/cid | pgmask)"
i=0; while [ $i -lt 120 ]; do docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 && break; sleep 0.5; i=$((i + 1)); done
docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 || die "Postgres never became ready in the container"
[ "$(docker port "$PGN")" = "5432/tcp -> 127.0.0.1:$PGP" ] || die "the container is not published on 127.0.0.1:$PGP alone: $(docker port "$PGN" | paste -sd';' -)"
[ "$(listeners 19939)" = 0 ] || die "something listens on 19939 - it is never bound"
echo "  the container $PGN: up, published on $(docker port "$PGN") only" >&3

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; }
PGV=(-Ddb=pg -Dpg.port=$PGP -Dpg.passfile=../pg/password)    # a harness run on PostgreSQL: where the container is, and the password's file
# hrun: the harness line (V, A set by the caller), run from .harness/run; it exits by itself (bounded: 240 s); its exit code in HE;
# its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 240 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log; }
# hview: the harness's whole log (PROBE lines, Hibernate's INFO core lines, the SQL logger's lines, the bind logger's when asked),
# trailing spaces dropped; then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
script() { echo "  the script it wrote, .harness/run/$1 - every line:"; if [ -f ".harness/run/$1" ]; then sed 's/^/    /' ".harness/run/$1"; else echo "    (none: no such file)"; fi; }
mask() { awk -v w="$PGPW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { W = lit(w); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(W, "[masked: the 24-character password]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/FK[0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z]*/, "FK<hash>")
    gsub(/UK[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]*/, "UK<hash>")
    gsub(/PRIMARY_KEY_[0-9A-F]+/, "PRIMARY_KEY_<n>"); gsub(/CONSTRAINT_[0-9A-F]+/, "CONSTRAINT_<n>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists pause add constraint FKf6bjesl03vnrm7801593526l1 foreign key (customer_id) references customer;' 'alter table if exists t add constraint UKm2mc7dy22sku3hjrgease2abs unique (x);' '    /* PUBLIC.PRIMARY_KEY_9: ID = O1_0.ID */' 'Check constraint violation: "CONSTRAINT_8A"' "jdbc:postgresql://127.0.0.1:$PGP/u14x?user=sa&password=$PGPW" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists pause add constraint FK<hash> foreign key (customer_id) references customer;' 'alter table if exists t add constraint UK<hash> unique (x);' '    /* PUBLIC.PRIMARY_KEY_<n>: ID = O1_0.ID */' 'Check constraint violation: "CONSTRAINT_<n>"' "jdbc:postgresql://127.0.0.1:$PGP/u14x?user=sa&password=[masked: the 24-character password]")" ] || die "mask: the planted JDK version, folders, home, identity hash, constraint and index names and the password must be masked"
rm -f .harness/p1                                    # it held the password: gone before any capture
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    [ "$(raw "$PGPW" .harness/cap.raw)" = 0 ] || { rm -f .harness/cap.raw; die "$nm: its raw output (run $i) held the database password - the mask would hide it; nothing may print it (S2.9)"; }
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  rm -f .harness/cap.raw
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or image, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
DBNAME() { case $1 in h2) echo H2 ;; pg) echo PostgreSQL ;; esac; }
dbv() { case $1 in h2) V=() ;; pg) V=("${PGV[@]}") ;; esac; }



# ---- course2: Course 2's money lesson, read off its files ------------------------------------------------------------------------
course2() {
  echo "Course 2's lesson, by its title - java2_series.py's \"21\" entry (read off the file when it is on this computer, else the line asserted when it was): $T21"
  echo "its Money.java - ../c2-unit21/Money.java, md5 $(md5 -q "$C2M") - the thirty additions, then the bill and its rounding:"
  echo "\$ sed -n 10,24p ../c2-unit21/Money.java"; sed -n 10,24p "$C2M" | sed -E 's/[[:space:]]+$//; s/^/    /'
  echo "\$ sed -n 38,45p ../c2-unit21/Money.java"; sed -n 38,45p "$C2M" | sed -E 's/[[:space:]]+$//; s/^/    /'
  echo "its Rounding.java - ../c2-unit21/Rounding.java, md5 $(md5 -q "$C2R") - 1.005 as a double and as a BigDecimal:"
  echo "\$ sed -n 15,17p ../c2-unit21/Rounding.java"; sed -n 15,17p "$C2R" | sed -E 's/[[:space:]]+$//; s/^/    /'
  echo "its README.md - ../c2-unit21/README.md, md5 $(md5 -q "$C2T") - the two lines that record what Money.java and Rounding.java printed:"
  echo "\$ sed -n 4,5p ../c2-unit21/README.md"; sed -n 4,5p "$C2T" | sed -E 's/[[:space:]]+$//; s/^/    /'; }

# ---- ddl: Hibernate's DDL for the seven, on H2 and on PostgreSQL, validation as found and switched off --------------------------
ddl() { local d
  for d in h2 pg; do rm -f .harness/run/ddl-$d.sql .harness/run/nv-$d.sql
    echo "the seven money entities on $(DBNAME $d) - one JVM, two factories: Bean Validation as Hibernate finds it, then jakarta.persistence.validation.mode=NONE:"
    dbv $d; A=(ddl u14ddl ddl-$d.sql u14nv nv-$d.sql); hrun; hview; script ddl-$d.sql; script nv-$d.sql
    echo "  validation as found = validation switched off, byte for byte: $(cmp -s .harness/run/ddl-$d.sql .harness/run/nv-$d.sql && echo yes || echo no)"; done
  echo "  the script on H2 = the script on PostgreSQL, byte for byte: $(cmp -s .harness/run/ddl-h2.sql .harness/run/ddl-pg.sql && echo yes || echo no)"; }

# ---- values: one Bill per value, one transaction each; then the 11-digit value, the failure receipt ---------------------------------
VALS=(3603.00 120.105 120.104 -120.105 3693.07500)  # the inputs - Course 2's total, the third decimal both ways, a negative, Course 2's gross
OVER=123456789.00                                    # eleven digits for a numeric(10,2)
values() { local d
  for d in h2 pg; do
    echo "values on $(DBNAME $d) - one JVM, one transaction per value (the bind logger at TRACE: what Hibernate sent):"
    dbv $d; V=("${V[@]}" -Dbind=TRACE); A=(values u14v "${VALS[@]}"); hrun; hview
    echo "overflow on $(DBNAME $d) - the failure receipt: a fresh JVM, a fresh database, $OVER:"
    dbv $d; V=("${V[@]}" -Dbind=TRACE); A=(values u14o $OVER); hrun; hview; done; }

# ---- double: Course 2's thirty additions in a double, in a column ------------------------------------------------------------------
dbl() { local d
  for d in h2 pg; do
    echo "the double on $(DBNAME $d) - one JVM:"
    dbv $d; A=(double u14d); hrun; hview; done; }

# ---- digits: A/B/A' - the refusal you write, on H2 and PostgreSQL; then S2.4's check on the class files ----------------------------
DA=A                                                 # A's kind (DigitsBill); B is Bill
ann() { (eval "$L_JAVAP") 2> /dev/null | awk '
  /^  public java\.math\.BigDecimal amount;$/ { f = 1; next } f && /^  [^ ]/ { exit } f && /RuntimeVisibleTypeAnnotations/ { exit }
  f && /^ +jakarta\.validation\.constraints\.Digits\($/ { a = "D"; next } f && /^ +jakarta\.persistence\.Column\($/ { a = "C"; next }
  f && /^ +\)$/ { a = ""; next } f && a != "" { s = $0; gsub(/ /, "", s); split(s, kv, "="); v[a kv[1]] = kv[2] }
  END { print (v["Dinteger"] == "" ? "-" : v["Dinteger"]), (v["Dfraction"] == "" ? "-" : v["Dfraction"]), (v["Cprecision"] == "" ? "-" : v["Cprecision"]), (v["Cscale"] == "" ? "-" : v["Cscale"]) }'; }
annview() { (eval "$L_JAVAP") 2> /dev/null | awk '
  /^  public java\.math\.BigDecimal amount;$/ { f = 1; print "    " $0; next } f && /^  [^ ]/ { exit } f && /RuntimeVisibleTypeAnnotations/ { exit }
  f && /^ +(RuntimeVisibleAnnotations:|jakarta\.|[a-z]+=|\))/ { print "    " $0 }'; }
ddlnum() { sed -n -E "s/^create table $1 \\(amount numeric\\(([0-9]+),([0-9]+)\\).*/\\1,\\2/p" "$2"; }
# s24 CLASS TABLE SCRIPT: the class file's two annotations (javap) beside the DDL Hibernate wrote for its table. The DDL-only check
# compares @Digits with the DDL alone; S2.4's (R.209) compares @Digits, @Column(precision, scale) and the DDL - all three one fact
s24() { local K=$1 di df cp cs d e
  echo "  \$ K=$K"; echo "  \$ $L_JAVAP   (the amount field's annotations, as javap prints them)"; annview
  read -r di df cp cs <<EOF
$(ann)
EOF
  # a class without @Digits (or a field javap cannot read) gives no number: said so, never an arithmetic error that ends the line
  d=$(ddlnum $2 .harness/run/$3); case "$di$df" in ''|*[!0-9]*) e="(no @Digits)" ;; *) e="$((di + df)),$df" ;; esac
  echo "  read off the class file: Digits(integer=$di, fraction=$df) | Column(precision=$cp, scale=$cs) · Hibernate's DDL for $2: amount numeric($d)"
  echo "  the DDL-only check - numeric(integer + fraction, fraction) from @Digits = the DDL's: numeric($e) = numeric($d): $( [ "$e" = "$d" ] && echo pass || echo FAIL)"
  echo "  S2.4's check - @Digits, @Column(precision, scale) and the DDL one fact: numeric($e) = Column($cp,$cs) = numeric($d): $( [ "$e" = "$d" ] && [ "$cp,$cs" = "$d" ] && echo pass || echo FAIL)"; }
digits() { local d
  for d in h2 pg; do
    echo "A on $(DBNAME $d) - DigitsBill, @Digits(integer = 8, fraction = 2) beside @Column(precision = 10, scale = 2):"
    dbv $d; A=(digits u14a $DA); hrun; hview
    echo "B on $(DBNAME $d) - Bill, @Column(precision = 10, scale = 2) and no @Digits:"
    dbv $d; A=(digits u14b B); hrun; hview
    echo "A' on $(DBNAME $d) - A again, a fresh JVM, a fresh database:"
    dbv $d; A=(digits u14a2 $DA); hrun; hview; done
  rm -f .harness/run/s24.sql
  echo "S2.4 on H2 - Hibernate's DDL for the two classes, written to a file, never run; then each class file read with javap:"
  V=(); A=(script s24.sql probe.map.money.DigitsBill probe.map.money.ScaleThreeBill); hrun; hview; script s24.sql
  echo "S2.4 on the shipped class - DigitsBill:"; s24 probe.map.money.DigitsBill digits_bill s24.sql
  echo "S2.4 on the planted scale = 3 - ScaleThreeBill:"; s24 probe.map.money.ScaleThreeBill scale_three_bill s24.sql; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's, as the owning-side lesson captured it --------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # that capture's own published md5 (../c7-unit09/receipts.md5)
$G -qF "$X09" ../c7-unit09/README.md || die "../c7-unit09/README.md no longer states Boot's script md5 $X09 - the number this unit compares with"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
echo "  (terminal only) Boot's script for the anchor's CustomerEntity and PauseEntity: md5 $X09, stated in ../c7-unit09/README.md (its xcheck capture, published $X09CAP)" >&3
BOOT09=""
if [ -f ../c7-unit09/.r-xcheck.out ] && [ "$(md5 -q ../c7-unit09/.r-xcheck.out)" = "$X09CAP" ]; then
  BOOT09=$(sed -n '/^  \.harness\/after\/hibernate-ddl\.sql - every line:$/,/^the harness/p' ../c7-unit09/.r-xcheck.out | sed -n 's/^    //p')
  [ "$(printf '%s\n' "$BOOT09" | wc -l | tr -d ' ')" = 3 ] || die "../c7-unit09/.r-xcheck.out (its published capture, on disk) does not hold Boot's three lines"
  echo "  (terminal only) ../c7-unit09/.r-xcheck.out is on disk (md5 = its published $X09CAP): Boot's three lines read from it (constraint name masked there) - compared line by line after xcheck" >&3
else echo "  (terminal only) ../c7-unit09/.r-xcheck.out is not on disk (a clone: captures are not committed) - the md5 is the comparison" >&3; fi
xcheck() { rm -f .harness/run/xcheck.sql
  echo "the harness's DDL - its own EntityManagerFactory over com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity (from the anchor's jar), a file, never run:"
  V=(); A=(xcheck xcheck.sql); hrun; hview; script xcheck.sql
  echo "  md5 of .harness/run/xcheck.sql: $(md5 -q .harness/run/xcheck.sql)"
  echo "  Boot's script for these entities, as the owning-side lesson's xcheck captured it (Boot 4.1.2, the anchor's jar): md5 $X09"
  echo "  the same, byte for byte (md5): $( [ "$(md5 -q .harness/run/xcheck.sql)" = "$X09" ] && echo yes || echo no)"; }

# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
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
  printf '%s\n' "$setup" | $G -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | $G -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  [ "$(printf '%s\n' "$setup" | $G -c -- "$JL")" = 1 ] || die "exercise/README.md: its java line must pin the locale and the zone ($JL)"
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

# ---- the captures, each followed by the checks of what the video says from it ------------------------------------------------
# sect CAP HEADING: a block of a capture - from the line that starts with HEADING to the next heading (a line that starts with
# neither a space nor "$ ")
sect() { awk -v h="$2" 'index($0, h) == 1 { f = 1; print; next } f && /^[^ $]/ { exit } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
cntre() { printf '%s\n' "$1" | $G -cE -- "$2" || true; }
# R.222: a version-shaped claim prints its version in the same capture - Hibernate's own HHH000001 line (its core logger at INFO)
# and the harness's org.hibernate.Version.getVersionString() line, once per harness JVM, read off the log, never typed; S2.9/S2.17:
# the driver's version on every PostgreSQL factory, from the connection's metadata; S2.12: the database: lines say H2 and PostgreSQL
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:'
DBP="  PROBE database: PostgreSQL 18.6 | select version(): PostgreSQL 18.6 (the platform after ' on ' cut) | url jdbc:postgresql://127.0.0.1:$PGP/"
DRVP=' | user sa | driver PostgreSQL JDBC Driver 42.7.14'
ndb() { printf '%s\n' "$1" | $G -F -- "$2" | { [ "$2" = "$DBP" ] && $G -F -- "$DRVP" || cat; } | wc -l | tr -d ' '; }
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] || die "$1: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its $2 harness JVMs (R.222)"
  [ "$(ndb "$c" "$DBH")" = "$3" ] && [ "$(ndb "$c" "$DBP")" = "$4" ] || die "$1: the database: lines - $3 on H2 2.5.250 and $4 on PostgreSQL 18.6 with driver 42.7.14 (S2.12, S2.17) - read $(ndb "$c" "$DBH") and $(ndb "$c" "$DBP")"; }
# S2.8: a schema step that WARNs is a failure - checked first after every capture with a JVM
nowarn() { local n; n=$($G -v "^ *exit [0-9]* · 'GenerationTarget encountered exception': [0-9]*\$" ".r-$1.out" | $G -c 'GenerationTarget encountered exception' || true)
  [ "$n" = 0 ] || die "$1: a schema step WARNed - 'GenerationTarget encountered exception' $n times (S2.8, R.213: a field or table named after an SQL keyword? $($G -m1 -oE 'Syntax error in SQL statement "[^"]{0,80}' ".r-$1.out" || true))"; }
ok0() { has "$1" "  exit 0 · 'GenerationTarget encountered exception': 0" "$2: exit 0"; nhas "$1" 'PROBE EXCEPTION' "$2: no exception"; }
chk_course2() { local O l; O=$(cat .r-course2.out)
  for l in '    for (int day = 1; day <= 30; day++) dTotal += 120.10;' '    IO.println("double     total = " + dTotal);' '    IO.println("BigDecimal total = " + bTotal);' \
      '    BigDecimal due   = gross.setScale(2, RoundingMode.HALF_UP);' '    IO.println("new BigDecimal(\"1.005\").setScale(2,HALF_UP) = " + new BigDecimal("1.005").setScale(2, RoundingMode.HALF_UP));'; do has "$O" "    $l" "course2: Course 2's line"; done
  [ "$(printf '%s\n' "$O" | sed -n '/^\$ sed -n 10,24p /,/^\$ sed -n 38,45p /p' | $G -c '^    ')" = 15 ] && [ "$(printf '%s\n' "$O" | sed -n '/^\$ sed -n 38,45p /,/^its Rounding/p' | $G -c '^    ')" = 8 ] || die "course2: Money.java lines 10-24 (15) and 38-45 (8)"
  for l in '`double total = 3602.999999999998`' '`BigDecimal total = 3603.00`' '`fee 90.07500 scale 5`' '`due 3693.08 scale 2`' 'setScale(2,HALF_UP) = 1.01`'; do
    [ "$(printf '%s\n' "$O" | sed -n '/^\$ sed -n 4,5p /,$p' | $G -cF -- "$l")" = 1 ] || die "course2: Course 2's README line holding $l"; done
  echo "  course2: $T21 - Money.java (md5 $C2MMD5) thirty additions of 120.10, setScale(2, RoundingMode.HALF_UP); its README: double total = 3602.999999999998 · BigDecimal total = 3603.00 · fee 90.07500 scale 5 · due 3693.08 scale 2 · 1.005 -> 1.01"; }
DDL1='create table bill (amount numeric(10,2), id bigint generated by default as identity, primary key (id));
create table digits_bill (amount numeric(10,2), id bigint generated by default as identity, primary key (id));
create table digits_only_bill (amount numeric(10,2), id bigint generated by default as identity, primary key (id));
create table double_bill (amount float(53) not null, id bigint generated by default as identity, primary key (id));
create table plain_bill (amount numeric(38,2), id bigint generated by default as identity, primary key (id));
create table scale_three_bill (amount numeric(10,2), id bigint generated by default as identity, primary key (id));
create table six_digits_bill (amount numeric(8,2), id bigint generated by default as identity, primary key (id));'
scr() { printf '%s\n' "$1" | sed -n "/^  the script it wrote, .harness\/run\/$2 - every line:\$/,/^  [^ ]/p" | sed -n 's/^    //p'; }
chk_ddl() { local O d W; nowarn ddl; O=$(cat .r-ddl.out); ver ddl 2 2 2
  for d in h2 pg; do W=$(sect ddl "the seven money entities on $(DBNAME $d) - ")
    [ "$(scr "$W" ddl-$d.sql)" = "$DDL1" ] || die "ddl on $(DBNAME $d): the script - expected, every line: $(printf '%s\n' "$DDL1" | paste -sd'|' -) - read: $(scr "$W" ddl-$d.sql | paste -sd'|' -)"
    [ "$(scr "$W" nv-$d.sql)" = "$DDL1" ] || die "ddl on $(DBNAME $d): validation switched off - the same script expected"
    has "$W" "  validation as found = validation switched off, byte for byte: yes" "ddl on $(DBNAME $d): @Digits decides the column even with validation off"
    ok0 "$W" "ddl on $(DBNAME $d)"; done
  has "$O" "  the script on H2 = the script on PostgreSQL, byte for byte: yes" "ddl: H2 = PostgreSQL"
  echo "  ddl: H2 = PostgreSQL, validation on = off, byte for byte - Bill numeric(10,2) · PlainBill numeric(38,2) · DoubleBill float(53) not null · DigitsOnlyBill numeric(10,2) · DigitsBill numeric(10,2) · ScaleThreeBill (@Column scale 3) numeric(10,2) · SixDigitsBill (@Digits integer 6, @Column precision 10) numeric(8,2)"; }
# vblk BLOCK VALUE: one value's lines, from its "value V - " line to the next value's
vblk() { printf '%s\n' "$1" | awk -v h="  PROBE value $2 - " 'index($0, h) == 1 { f = 1; print; next } f && index($0, "  PROBE value ") == 1 { exit } f && /^  exit / { exit } f'; }
BIND() { printf '  TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:NUMERIC) <- [%s]\n' "$1"; }
ONE1='  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 1'
ONEJ='  PROBE jdbc: prepareStatement 1 | executeUpdate 1 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0'
# vrow BLOCK VALUE ROW NAME: the value bound whole, the managed object still holding it after the flush (R.201: measured, the same
# persistence context), one INSERT counted three ways (R.184), the row and a new EntityManager's read both ROW
vrow() { local b; b=$(vblk "$1" "$2")
  [ -n "$b" ] || die "$4: no block for the value $2"
  has "$b" "$(BIND "$2")" "$4: the bind logger - Hibernate sent the value whole"
  has "$b" "  PROBE after the flush, the same persistence context: the managed Bill's amount $2 | em.find(Bill, id) is that object: true" "$4: the managed object after the flush"
  [ "$(cntre "$b" '^  DEBUG org\.hibernate\.SQL : insert into bill ')" = 1 ] && [ "$(cnt "$b" "$ONE1")" = 1 ] && [ "$(cnt "$b" "$ONEJ")" = 1 ] || die "$4: one INSERT - the SQL log, getPrepareStatementCount(), the driver's prepareStatement (R.184)"
  has "$b" "  PROBE the row by a second connection (getString): $3" "$4: the row"
  has "$b" "  PROBE read back by a new EntityManager: amount $3" "$4: a new EntityManager's read"
  nhas "$b" 'EXCEPTION' "$4: no exception"; }
R120=""; R120P=""; R104=""; RNEG=""; RDUE=""; R3603=""; OVH=""; OVP=""; BND=""
chk_values() { local d W n O; nowarn values; ver values 4 2 2
  for d in h2 pg; do n="values on $(DBNAME $d)"; W=$(sect values "values on $(DBNAME $d) - ")
    vrow "$W" 3603.00 3603.00 "$n: 3603.00 kept"
    vrow "$W" 120.105 120.11 "$n: 120.105 - the row holds 120.11"
    vrow "$W" 120.104 120.10 "$n: 120.104 - the row holds 120.10"
    vrow "$W" -120.105 -120.11 "$n: -120.105 - the row holds -120.11"
    vrow "$W" 3693.07500 3693.08 "$n: Course 2's gross - the row holds 3693.08"
    ok0 "$W" "$n"
    [ "$(cntre "$W" '^  WARN ')" = 0 ] && [ "$(cntre "$W" '^  ERROR ')" = 0 ] || die "$n: no WARN and no ERROR line while the database rounds - the rounding is silent (read $(cntre "$W" '^  WARN ') WARN)"
    n="overflow on $(DBNAME $d)"; O=$(sect values "overflow on $(DBNAME $d) - ")
    has "$O" "$(BIND $OVER)" "$n: the value bound whole"
    has "$O" "  exit 1 · 'GenerationTarget encountered exception': 0" "$n: exit 1 - the failure receipt"
    has "$O" "  PROBE rows in bill by a second connection: [0]" "$n: nothing stored"
    [ "$(cntre "$O" '^  PROBE EXCEPTION org\.hibernate\.exception\.DataException: could not execute statement \[')" = 1 ] || die "$n: DataException - could not execute statement"
    case $d in
      h2) has "$O" '  PROBE   Caused by org.h2.jdbc.JdbcSQLDataException: Value too long for column "AMOUNT NUMERIC(10, 2)": "123456789.00 (11)"; SQL statement:' "$n: H2's own message"
          nhas "$O" 'numeric field overflow' "$n: PostgreSQL's message is PostgreSQL's"
          OVH=$(printf '%s\n' "$O" | sed -n -E 's/^  PROBE   Caused by org\.h2\.jdbc\.JdbcSQLDataException: (Value too long for column "AMOUNT NUMERIC\(10, 2\)"): .*/\1/p') ;;
      pg) has "$O" '  PROBE   Caused by org.postgresql.util.PSQLException: ERROR: numeric field overflow' "$n: PostgreSQL's own message"
          nhas "$O" 'Value too long' "$n: H2's message is H2's"
          OVP=$(printf '%s\n' "$O" | sed -n -E 's/^  PROBE   Caused by org\.postgresql\.util\.PSQLException: ERROR: (numeric field overflow)$/\1/p') ;; esac; done
  W=$(sect values 'values on H2 - '); R120=$(vblk "$W" 120.105 | sed -n 's/^  PROBE the row by a second connection (getString): //p'); BND=$(vblk "$W" 120.105 | sed -n 's/^  TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:NUMERIC) <- //p')
  R104=$(vblk "$W" 120.104 | sed -n 's/^  PROBE the row by a second connection (getString): //p'); RNEG=$(vblk "$W" -120.105 | sed -n 's/^  PROBE the row by a second connection (getString): //p')
  RDUE=$(vblk "$W" 3693.07500 | sed -n 's/^  PROBE the row by a second connection (getString): //p'); R3603=$(vblk "$W" 3603.00 | sed -n 's/^  PROBE the row by a second connection (getString): //p')
  R120P=$(vblk "$(sect values 'values on PostgreSQL - ')" 120.105 | sed -n 's/^  PROBE the row by a second connection (getString): //p')
  echo "  values: H2 and PostgreSQL alike - 120.105 bound $BND, the row $R120 (H2) / $R120P (PostgreSQL), the managed object 120.105 after the flush, a new EntityManager $R120 · 120.104 -> $R104 · -120.105 -> $RNEG · 3693.07500 -> $RDUE · 3603.00 kept; 0 WARN · $OVER: H2 '$OVH', PostgreSQL '$OVP' - DataException, exit 1, nothing stored"; }
D1=""; D2=""; DT=""
chk_double() { local d W; nowarn double; ver double 2 1 1
  for d in h2 pg; do W=$(sect double "the double on $(DBNAME $d) - ")
    has "$W" '  PROBE written: thirty additions of 120.10 in a double = 3602.999999999998 | new BigDecimal("3603.00").doubleValue() = 3603.0' "double on $(DBNAME $d): Course 2's double"
    has "$W" '  PROBE the rows by a second connection, read through JDBC (getDouble, then Double.toString): [id 1: 3602.999999999998, id 2: 3603.0]' "double on $(DBNAME $d): the stored doubles, read through JDBC"
    has "$W" '  PROBE read back by a new EntityManager: id 1 amount 3602.999999999998' "double on $(DBNAME $d): a new EntityManager"
    has "$W" '  PROBE thirty additions == 3603.00 after the round trip: false' "double on $(DBNAME $d): still not 3603"
    ok0 "$W" "double on $(DBNAME $d)"; done
  has "$(sect double 'the double on PostgreSQL - ')" "  PROBE the same rows as the database's own text (amount::text - its text, not the double read back): [1 | 3602.999999999998, 2 | 3603]" "double: PostgreSQL's own text of the whole double"
  D1=$(sect double 'the double on PostgreSQL - ' | sed -n -E 's/^  PROBE the rows by a second connection, read through JDBC \(getDouble, then Double\.toString\): \[id 1: ([^,]+), id 2: ([^]]+)\]$/\1/p')
  D2=$(sect double 'the double on PostgreSQL - ' | sed -n -E 's/^  PROBE the rows by a second connection, read through JDBC \(getDouble, then Double\.toString\): \[id 1: ([^,]+), id 2: ([^]]+)\]$/\2/p')
  DT=$(sect double 'the double on PostgreSQL - ' | sed -n -E 's/^  PROBE the same rows as the database.s own text \(amount::text - its text, not the double read back\): \[1 \| [^,]+, 2 \| ([^]]+)\]$/\1/p')
  echo "  double: thirty additions of 120.10 -> $D1 stored and read back so, through JDBC and a new EntityManager, on H2 and PostgreSQL (float(53)); 3603.0 read through JDBC is $D2 - PostgreSQL's own text of it is $DT"; }
AREF='  PROBE refused at persist: jakarta.validation.ConstraintViolationException: Validation failed for classes [probe.map.money.DigitsBill] during persist time for groups [jakarta.validation.groups.Default, ]'
AVIO='  PROBE   violation probe.map.money.DigitsBill.amount = 120.105: numeric value out of bounds (<8 digits>.<2 digits> expected)'
ZERO1='  PROBE statistics: statements prepared (getPrepareStatementCount) 0 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 0'
ZEROJ='  PROBE jdbc: prepareStatement 0 | executeUpdate 0 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0'
ASTM=""
chk_digits() { local d W n; nowarn digits; ver digits 7 4 3
  for d in h2 pg; do
    # A: refused before any SQL - the validator's exception, then 0 statements three ways (the SQL log, Statistics, the driver)
    n="digits A on $(DBNAME $d)"; W=$(sect digits "A on $(DBNAME $d) - ")
    [ "$(cntre "$W" '^  DEBUG org\.hibernate\.SQL : insert ')" = 0 ] && [ "$(cnt "$W" "$ZERO1")" = 1 ] && [ "$(cnt "$W" "$ZEROJ")" = 1 ] || die "$n: 0 statements - no insert in the SQL log, getPrepareStatementCount() 0, the driver's prepareStatement 0 (R.184)"
    has "$W" "$AREF" "$n: the validator refuses at persist"; has "$W" "$AVIO" "$n: the violation"
    has "$W" "  PROBE rows in digits_bill by a second connection: [0]" "$n: nothing stored"; ok0 "$W" "$n"
    # A': A again, a fresh JVM - the same lines
    [ "$(sect digits "A' on $(DBNAME $d) - " | sed 1d | sed 's/u14a2/u14a/g')" = "$(printf '%s\n' "$W" | sed 1d)" ] || die "digits A' on $(DBNAME $d): A again, a fresh JVM - every line A printed (its database name aside)"
    # B: no @Digits - stored, rounded by the database
    n="digits B on $(DBNAME $d)"; W=$(sect digits "B on $(DBNAME $d) - ")
    [ "$(cntre "$W" '^  DEBUG org\.hibernate\.SQL : insert into bill ')" = 1 ] && [ "$(cnt "$W" "$ONE1")" = 1 ] && [ "$(cnt "$W" "$ONEJ")" = 1 ] || die "$n: one INSERT, three ways"
    has "$W" "  PROBE the row by a second connection (getString): 120.11" "$n: stored as 120.11"
    has "$W" "  PROBE read back by a new EntityManager: amount 120.11" "$n: read back 120.11"; nhas "$W" 'refused' "$n: nothing refuses"; ok0 "$W" "$n"; done
  # S2.4 (R.209): the shipped class passes both checks; on the planted scale = 3 the DDL-only check passes - it cannot fail - and
  # S2.4's fails
  W=$(sect digits 'S2.4 on the shipped class - '); has "$W" '  read off the class file: Digits(integer=8, fraction=2) | Column(precision=10, scale=2) · Hibernate'"'"'s DDL for digits_bill: amount numeric(10,2)' "S2.4: DigitsBill's two annotations and its DDL"
  has "$W" '  the DDL-only check - numeric(integer + fraction, fraction) from @Digits = the DDL'"'"'s: numeric(10,2) = numeric(10,2): pass' "S2.4: DigitsBill, the DDL-only check"
  has "$W" "  S2.4's check - @Digits, @Column(precision, scale) and the DDL one fact: numeric(10,2) = Column(10,2) = numeric(10,2): pass" "S2.4: the shipped DigitsBill passes S2.4's check"
  # the plant shipped as a class: ScaleThreeBill.java is DigitsBill.java with its name, its comment and one number changed - the scale
  [ -z "$(diff <(sed '/^\/\*\* /d; s/ScaleThreeBill/DigitsBill/g; s/@Column(precision = 10, scale = 3)/@Column(precision = 10, scale = 2)/' $HS/money/ScaleThreeBill.java) <(sed '/^\/\*\* /d' $HS/money/DigitsBill.java))" ] \
  && [ "$(diff $HS/money/ScaleThreeBill.java $HS/money/DigitsBill.java | $G -c '^<')" = 4 ] || die "ScaleThreeBill.java must be DigitsBill.java with only its name, its comment and its scale (3) changed"
  echo "  (terminal only) ScaleThreeBill.java = DigitsBill.java but its name, its comment and @Column(scale = 3) - the planted scale, shipped as a class" >&3
  W=$(sect digits 'S2.4 on the planted scale = 3 - '); has "$W" '  read off the class file: Digits(integer=8, fraction=2) | Column(precision=10, scale=3) · Hibernate'"'"'s DDL for scale_three_bill: amount numeric(10,2)' "S2.4: the plant's annotations and its DDL"
  has "$W" '  the DDL-only check - numeric(integer + fraction, fraction) from @Digits = the DDL'"'"'s: numeric(10,2) = numeric(10,2): pass' "S2.4: the DDL-only check passes on the plant - it cannot fail"
  has "$W" "  S2.4's check - @Digits, @Column(precision, scale) and the DDL one fact: numeric(10,2) = Column(10,3) = numeric(10,2): FAIL" "S2.4: S2.4's check fails on the plant"
  ASTM=$(sect digits 'A on PostgreSQL - ' | sed -n -E 's/^  PROBE statistics: statements prepared \(getPrepareStatementCount\) ([0-9]+) .*/\1/p')
  echo "  digits: A @Digits(integer = 8, fraction = 2) - 120.105 refused at persist (ConstraintViolationException, 'numeric value out of bounds (<8 digits>.<2 digits> expected)'), $ASTM statements three ways, nothing stored; B no @Digits - stored 120.11; A' = A; H2 and PostgreSQL · S2.4 (javap + DDL): DigitsBill pass; ScaleThreeBill - the DDL-only check pass (it cannot fail), S2.4's FAIL"; }
# R.212 (RED #308): the harness's script for the anchor's two entities = Boot's as unit 09 captured it, by md5
chk_xcheck() { local XC l; nowarn xcheck; XC=$(cat .r-xcheck.out); ver xcheck 1 1 0
  [ "$(printf '%s\n' "$XC" | sed -n '/xcheck.sql - every line:$/,/^  md5 of/p' | $G -c '^    ')" = 3 ] || die "xcheck: three lines"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the harness's script = Boot's (md5 $X09)"
  if [ -n "$BOOT09" ]; then printf '%s\n' "$BOOT09" | while IFS= read -r l; do has "$XC" "    $l" "xcheck: Boot's line as ../c7-unit09/.r-xcheck.out holds it"; done; fi
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity and PauseEntity, md5 $X09 = Boot's script as unit 09 captured it (R.212)"; }
EXQ="Your turn: the README saves a bill of 120.105 and the table quietly keeps 120.11. Make it refuse the third decimal before any SQL."
chk_exercise() { local EXB EXZ b ER ES l
  nowarn exercise
  EXB=$(sect exercise "in bash"); EXZ=$(sect exercise "in zsh")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    DEBUG org.hibernate.SQL : insert into bill (amount,id) values (?,default)' '    TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:NUMERIC) <- [120.105]' \
        '    PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 1' \
        '    PROBE read back by a new EntityManager: amount 120.11'; do has "$ER" "$l" "exercise: the README - stored, the table keeps 120.11"; done
    nhas "$ER" 'refused' "exercise: the README refuses nothing"
    for l in '    the JVM: exit 0' '    PROBE refused at persist: jakarta.validation.ConstraintViolationException: Validation failed for classes [probe.map.ex.Bill] during persist time for groups [jakarta.validation.groups.Default, ]' \
        '    PROBE   violation probe.map.ex.Bill.amount = 120.105: numeric value out of bounds (<8 digits>.<2 digits> expected)' \
        '    PROBE statistics: statements prepared (getPrepareStatementCount) 0 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 0' \
        '    PROBE jdbc: prepareStatement 0 | executeUpdate 0 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0'; do has "$ES" "$l" "exercise: the solution - refused, 0 statements"; done
    nhas "$ES" 'insert into' "exercise: the solution sends no INSERT"; nhas "$ES" 'read back' "exercise: the solution stores nothing"; nhas "$b" 'EXCEPTION' "exercise: nothing else throws"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder after each block"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 24 ] || die "exercise: the spoken line is 24 words (R.203)"
  $G -qxF '    @Column(precision = 10, scale = 2)' harness/src/probe/map/ex/Bill.java && ! $G -q '^ *@Digits' harness/src/probe/map/ex/Bill.java || die "exercise: ex.Bill ships no @Digits"
  echo "  exercise: bash and zsh alike - the README as written (no @Digits): 120.105 bound whole, one INSERT, read back 120.11; the solution (one line: @Digits(integer = 8, fraction = 2)): refused at persist, 0 statements three ways; 24 words"; }
# S2.14 / R.219: the database rounds - "Hibernate rounds" is false, and the values capture is the witness: its bind line (what
# Hibernate sent) and its row. Refused unquoted in this unit's prose (quoted, it may be named as the sentence never said)
chk_rounds() { local HR
  HR=$($G -rniE '(^|[^"`a-z])hibernate (rounds|rounded|rounding|round)' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
  [ -z "$HR" ] || die "\"Hibernate rounds\" is false (S2.14, R.219) - the values capture's bind line says Hibernate sent <- $BND and its row holds $R120 (H2) / $R120P (PostgreSQL): the database rounds. Said in: $HR"
  echo "  \"Hibernate rounds\", unquoted: 0 (README.md, exercise/) - the values capture contradicts it: bound <- $BND, the row $R120 / $R120P"; }
cap course2 course2; chk_course2
cap ddl ddl; chk_ddl
cap values values; chk_values; chk_rounds
cap double dbl; chk_double
cap digits digits; chk_digits
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise
# the values the video says are the captures', never typed: README.md states them in one line, compared with what the checks read
VS="the values the video may say: 120.105 bound $BND, the row $R120 (H2) and $R120P (PostgreSQL) · 120.104 -> $R104 · -120.105 -> $RNEG · 3693.07500 -> $RDUE · 3603.00 -> $R3603 · $OVER refused - H2 '$OVH', PostgreSQL '$OVP' · the double $D1 and $D2 read through JDBC (PostgreSQL's own text of the second: $DT) · A refused with $ASTM statements"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds - 0 raw passwords (counted in each raw run above, and here in every file)
[ "$LOGS" -gt 0 ] || die "no harness log was read"
[ "$(find . -type f ! -path './.m2-demo/*' -print0 | xargs -0 cat 2> /dev/null | LC_ALL=C $G -aoF -- "$PGPW" | wc -l | tr -d ' ')" = 1 ] || die "the password is held raw somewhere but its own file, .harness/pg/password"
[ "$(raw "$PGPW" "$PF")" = 1 ] || die "the password's file does not hold it"
DN=$($G -niwE -- "$DISH" .r-*.out 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  [ "$f" = .r-course2.out ] || ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|x86_64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -oE '(127\.0\.0\.1:|port )[0-9]+' "$f" | $G -vxF "127.0.0.1:$PGP" > /dev/null || die "$f holds a port other than the container's $PGP"
  ! $G -qE '[0-9]+\.[0-9]+ ms' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'FK[0-9A-Za-z]{11,}|PRIMARY_KEY_[0-9]|CONSTRAINT_[0-9]' "$f" || die "$f holds a generated constraint or index name, unmasked (#320)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'Last modified|SHA-256 checksum|Classfile ' "$f" || die "$f holds javap's file header (a date, a checksum, a path)"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE 'https?://' || die "$f runs a command with a URL - this unit makes no request"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale and its zone pinned on its java line (S6.1)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|BigDecimal|double|Long) +(order|offset|user|value|key|zone|timestamp|number|decimal|numeric)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
# R.195: no H2 database file anywhere in this folder - .harness/ included - nor beside it
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "R.195: an H2 database file exists - every H2 database here lives in a JVM's memory"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 0 raw passwords in every raw capture run and every file but its own; 'GenerationTarget encountered exception' 0; no path, unit number (course2 quotes Course 2's folder by name), time, millisecond figure, OS token, other port, generated name, javap header or stack frame in any capture; every JVM pinned - locale and zone; no kill by name; no bare wait; options as arrays; no H2 file (R.195); no dish name"

# ---- the end: the container removed, the anchor, the ports -------------------------------------------------------------------
docker rm -f "$PGN" > /dev/null 2>&1 || die "docker rm -f $PGN failed"; PGUP=""
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "the container $PGN is still there"
echo "  the container: removed (docker ps -a --filter name=$PGN: 0 lines)"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19930-19939 at the end; 19938 was the container's (127.0.0.1 only), 19939 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit14: every capture 3/3 and = published; every spoken value asserted; 0 raw passwords; the container removed"
