#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Dates, Times and Zones - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit09/after, the
# tree Section 2 froze (= ../c7-tiffinbox when this unit was built; compared at the start and the end, a note when they differ, never
# a stop - R.211). Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number
# and string the video says is asserted right after its capture by a check that can fail. Two databases: H2 - in a harness JVM's
# memory, or, for two JVMs that share it, a FILE under .harness/run/db/ that the receipt deletes after the second JVM and asserts gone
# (R.195) - and PostgreSQL 18.6 in a container of this run's (postgres@sha256:77f58511..., --pull never, published on 127.0.0.1:19928
# only), the container removed at the end and by the trap. Every capture says which database answered (a database: line per JVM), and
# every JVM says its zone: -Duser.timezone on its java line, TimeZone.getDefault().getID() printed first. One entity, OrderLog: one
# moment - Course 2's literal 2026-09-14T18:30:00Z, never now() - held five ways: wall (LocalDateTime), moment (Instant), momentNoZone
# (an Instant forced onto a timestamp column - Course 2's column), offsetAt (OffsetDateTime at +05:30), zonedAt (ZonedDateTime in
# Asia/Kolkata); no field named after an SQL keyword (S2.8). A gap is printed with Course 2's own label, "off by" padded as its
# Connect.java pads it (S2.19, R.224: byte-equal to Course 2's capture line):
#   course2   Course 2's lesson read off its files: its title, Connect.java lines 80-115 (the literal, setTimestamp with a UTC calendar,
#             getTimestamp with a Kolkata one, the off-by label, TIMESTAMP WITH TIME ZONE), its script's ON SCREEN capture lines
#   ddl       Hibernate's DDL for OrderLog, Hibernate's defaults, on H2 and on PostgreSQL, the two scripts compared byte for byte
#   zones     two JVMs, two zones, one database between them (A/B/A'): the writer in UTC, the reader in Asia/Kolkata - B the wall clock
#             and the forced timestamp off by PT5H30M, A the default Instant PT0S; the zones reversed; A' = A again, fresh JVMs, a fresh
#             database; on H2 (a file) and on PostgreSQL (a database kept between the two JVMs); the row by a second connection
#   storage   hibernate.timezone.default_storage - not set, NATIVE, NORMALIZE, COLUMN, AUTO - on H2 and PostgreSQL: Hibernate's
#             reading (SessionFactoryOptions) and the DDL; B: NATIVE on PostgreSQL, the failure receipt (exit 1, no script)
#   offset    an OffsetDateTime at +05:30, written and read back by a new EntityManager, one JVM in UTC, on H2 and on PostgreSQL
#   jdbctz    C, labelled: hibernate.jdbc.time_zone=UTC on both JVMs - the forced timestamp PT0S too, the wall clock read shifted
#   xcheck    the harness's DDL for the anchor's CustomerEntity and PauseEntity against Boot's script as the owning-side lesson
#             captured it (its md5, f5956370..., in ../c7-unit09/README.md - R.212, RED #308: this unit runs no Boot)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f (H2, a file, two JVMs each half)
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar is extracted (the anchor's own line). The PostgreSQL driver is resolved by Maven from .m2-demo (harness/pom.xml: Boot's
# managed version, none written). The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with javac
# -parameters against that extracted jar and the driver into .harness/hc. probe.map.H builds one EntityManagerFactory per run
# (Jakarta Persistence 3.2's PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's
# own database only - a reader opens the writer's database with none) over a DataSource wrapped in a proxy that counts the driver
# calls. It runs from .harness/run and binds no port. Its JVM's zone travels as Z, its flags as an array, V, its arguments as an
# array, A (R.193). Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration
# pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale and the zone: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US) and its zone (-Duser.timezone=), and the checks refuse a java line without either; a TZ
# variable of yours is unset first; the test JVM's locale comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. The image is never pulled (--pull never; a missing image stops the run with the pull line to type). At run time
# nothing leaves the computer: H2 in a JVM's memory or in .harness/run/db/, PostgreSQL on 127.0.0.1. This unit reads no version
# file: unit 06 made the section's dated sweep (R.223).
# The database password: 24 characters this script generates at every run (never committed; bounded: 4,096 bytes of /dev/urandom),
# held in .harness/pg/password (mode 0600); the harness reads that file (-Dpg.passfile=) and never prints it. Every raw capture
# run is counted for it before the mask - 0 raw copies, else the run stops - and at the end the whole folder holds it once: its file.
# Masks (README.md declares each; awk gsub only): the password "[masked: the 24-character password]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; an identity hash "@…"; Hibernate's generated
# constraint names "FK<hash>" and "UK<hash>"; H2's generated index and constraint names "PRIMARY_KEY_<n>", "CONSTRAINT_<n>".
# A harness JVM's log is printed whole (every line, trailing spaces dropped).
# Ports (§P, 19920-19929): the container 19928, published on 127.0.0.1 only (docker port asserted); 19929 never bound. Every one of
# 19920-19929 is checked free at the start and the end (19928 after the container is gone), with 18425 (TiffinBox's default), 8080
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
PGN=c7-u13-pg; PGP=19928
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a harness JVM, a Maven, Surefire's fork - is stopped; then
# this run's container is removed (docker rm -f), if this run started it; then the H2 file database folder, .harness/run/db, is
# deleted, whatever left it. After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay.
# The clean-up ignores a second Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in
# this script is bare.
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
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$PGUP" ] || docker rm -f "$PGN" > /dev/null 2>&1 || true; rm -rf .harness/run/db; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
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
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/map
HFILES='dur7.py logback.xml pom.xml src'
SFILES='probe/map/H.java probe/map/Main.java probe/map/ex/OrderLog.java probe/map/log/OrderLog.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19920 19921 19922 19923 19924 19925 19926 19927 19928 19929"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
# the image, by digest, already on this computer (a receipt never pulls); no container of this unit's name
docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack here); this unit runs PostgreSQL 18 in a container"
[ "$(docker image inspect "$IMG" --format '{{.Id}}' 2> /dev/null || true)" = "${IMG#postgres@}" ] || die "the image is not on this computer: docker pull $IMG"
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "a container named $PGN exists - an interrupted run's? remove it: docker rm -f $PGN"
rm -rf .harness; mkdir -p .harness/run .harness/pg .harness/drv .harness/hc


# ---- duration words: none - this unit speaks no time (R.172); English names only (R.215); no typed gap ------------------------
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
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md) - this unit speaks no time; the bug's gap, PT5H30M, is a value a capture prints, not a timing"
# R.215: English names only - the AI voice mispronounces Indian dish names (the course's memory rule); the list is refused, whole
# words, any case, in this unit's prose, its harness and (at the end) every capture
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain|curry|curries'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes harness/src exercise README.md)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
# A gap is computed by the JVM that prints it (Duration.between), never typed: no ISO-8601 duration literal in the harness's source
TY=$($G -rnoE '"[^"]*PT-?[0-9]+[HMS][^"]*"' harness/src | head -3 | paste -sd';' - || true)
[ -z "$TY" ] || die "a typed gap in the harness - every PT… it prints must come from Duration.between: $TY"
echo "  typed gaps in the harness: 0 (every PT… printed is Duration.between's)"

# ---- Course 2, read off its files: Connect.java in this repository; the script and the title beside it (asserted when there) ---
C2J=../c2-unit35/src/main/java/Connect.java; C2JMD5=a2b44f17a90c745cccedd10cd8915d8a
C2S=../../../core-java-2/scripts-and-decks/35-jdbc-basics.md; C2SMD5=0bb5a050af2b08325aa6303ffef002ea; C2SL=194; C2SLMD5=aef5012116e3d0fa3c418d4d3cd2266c
J2="$HOME/Desktop/PromptVidya-Automation/java2_series.py"
T35='JDBC: Connect, Query, Map Rows to Records'
C2ON1='stored instant                   : 2026-09-14T18:30:00Z'
C2ON2='TIMESTAMP column holds           : 2026-09-14T18:30   (no zone anywhere)'
C2ON3='read by a service in Asia/Kolkata: 2026-09-14T13:00:00Z'
C2ON4='off by                           : PT5H30M'
[ -f "$C2J" ] && [ "$(md5 -q "$C2J")" = "$C2JMD5" ] || die "$C2J is missing or not Course 2's shipped file (md5 $C2JMD5)"
OFFL=$(sed -n 108p "$C2J" | sed -n -E 's/^ *IO\.println\("(off by +: )"$/\1/p')
STL=$(sed -n 105p "$C2J" | sed -n -E 's/^ *IO\.println\("(stored instant +: )" \+ placed\);$/\1/p')
[ -n "$OFFL" ] && [ -n "$STL" ] || die "Connect.java lines 105 and 108 no longer print Course 2's two labels"
[ "${C2ON4%PT5H30M}" = "$OFFL" ] && [ "${C2ON1%2026-09-14T18:30:00Z}" = "$STL" ] || die "the ON SCREEN lines this script holds do not start with Connect.java's labels"
if [ -f "$C2S" ]; then
  [ "$(md5 -q "$C2S")" = "$C2SMD5" ] && [ "$(sed -n ${C2SL}p "$C2S" | md5)" = "$C2SLMD5" ] || die "$C2S is not the script this unit quotes (md5 $C2SMD5, line $C2SL $C2SLMD5)"
  [ "$(sed -n ${C2SL}p "$C2S" | $G -o '`[^`]*`' | tr -d '`' | sed -n '3,6p')" = "$(printf '%s\n' "$C2ON1" "$C2ON2" "$C2ON3" "$C2ON4")" ] || die "the script's line $C2SL no longer shows the four capture lines this script holds"
  echo "  (terminal only) Course 2's script is beside this repository: md5 $C2SMD5, line $C2SL's four capture lines = the four this script holds" >&3
else echo "  (terminal only) Course 2's script is not beside this clone: its md5 and line $C2SL's four lines, asserted when it was, are the check" >&3; fi
if [ -f "$J2" ]; then
  [ "$(sed -n -E 's/^ *"35": "([^"]*)",$/\1/p' "$J2")" = "$T35" ] || die "java2_series.py's \"35\" entry is not the title this script holds: $T35"
  echo "  (terminal only) java2_series.py's \"35\" entry = $T35" >&3
else echo "  (terminal only) java2_series.py is not on this computer's Desktop: the title, asserted when it was, is the check" >&3; fi

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_PG=$(mine "docker run -d --pull never --name $PGN -e POSTGRES_USER=sa -e POSTGRES_PASSWORD=\"\$PGPW\" -p 127.0.0.1:$PGP:5432 $IMG")
L_DRV=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*:.harness/drv/*\" $HS/H.java $HS/Main.java $HS/log/*.java")
L_H=$(mine "java $JL -Duser.timezone=\"\$Z\" -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../drv/*\" probe.map.Main \"\${A[@]}\"")
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
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar com/h2database/h2/2.5.250/h2-2.5.250.jar org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the build - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/map/ex ] || die "the exercise's classes were compiled into the harness - they are the exercise's own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries), resolved the driver ($(ls .harness/drv | paste -sd' ' -)) and compiled the harness into .harness/hc"

# ---- the container: started once, before the captures; every writer on PostgreSQL makes its own fresh database in it ---------
pgmask() { awk -v p="$PGPW" '{ gsub(p, "[masked: the 24-character password]"); print }'; }
echo "  \$ $(printf '%s\n' "${L_PG/\"\$PGPW\"/$PGPW}" | pgmask)" >&3
PGUP=1; (eval "$L_PG") > .harness/pg/cid 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/pg/cid | pgmask)"
i=0; while [ $i -lt 120 ]; do docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 && break; sleep 0.5; i=$((i + 1)); done
docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 || die "Postgres never became ready in the container"
[ "$(docker port "$PGN")" = "5432/tcp -> 127.0.0.1:$PGP" ] || die "the container is not published on 127.0.0.1:$PGP alone: $(docker port "$PGN" | paste -sd';' -)"
[ "$(listeners 19929)" = 0 ] || die "something listens on 19929 - it is never bound"
echo "  the container $PGN: up, published on $(docker port "$PGN") only" >&3

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; }
PGV=(-Ddb=pg -Dpg.port=$PGP -Dpg.passfile=../pg/password)    # a harness run on PostgreSQL: where the container is, and the password's file
# hrun: the harness line (Z, V, A set by the caller), run from .harness/run; it exits by itself (bounded: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  echo "\$ Z=$Z"; pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 240 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log; }
# hview: the harness's whole log (PROBE lines, Hibernate's INFO core lines and the SQL logger's lines), trailing spaces dropped;
# then its exit code
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
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists pause add constraint FKf6bjesl03vnrm7801593526l1 foreign key (customer_id) references customer;' 'alter table if exists t add constraint UKm2mc7dy22sku3hjrgease2abs unique (x);' '    /* PUBLIC.PRIMARY_KEY_9: ID = O1_0.ID */' 'Check constraint violation: "CONSTRAINT_8A"' "jdbc:postgresql://127.0.0.1:$PGP/u13x?user=sa&password=$PGPW" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists pause add constraint FK<hash> foreign key (customer_id) references customer;' 'alter table if exists t add constraint UK<hash> unique (x);' '    /* PUBLIC.PRIMARY_KEY_<n>: ID = O1_0.ID */' 'Check constraint violation: "CONSTRAINT_<n>"' "jdbc:postgresql://127.0.0.1:$PGP/u13x?user=sa&password=[masked: the 24-character password]")" ] || die "mask: the planted JDK version, folders, home, identity hash, constraint and index names and the password must be masked"
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
# dbv DB [r]: the database flags of a harness run - H2 in memory (one JVM), H2 in the file db/NAME (a writer: f; a reader: r), or
# PostgreSQL (a writer: a fresh database; a reader, r: the writer's, kept)
dbv() { case $1-${2:-} in h2-) V=() ;; h2-f) V=(-Ddb=h2file) ;; h2-r) V=(-Ddb=h2file -Ddb.keep=true) ;; pg-|pg-f) V=("${PGV[@]}") ;; pg-r) V=("${PGV[@]}" -Ddb.keep=true) ;; esac; }



# ---- course2: Course 2's lesson, read off its files ------------------------------------------------------------------------
course2() {
  echo "Course 2's lesson, by its title - java2_series.py's \"35\" entry (read off the file when it is on this computer, else the line asserted when it was): $T35"
  echo "its Connect.java - ../c2-unit35/src/main/java/Connect.java, md5 $(md5 -q "$C2J") - lines 80-115, as sed -n prints them:"
  echo "\$ sed -n 80,115p ../c2-unit35/src/main/java/Connect.java"
  sed -n 80,115p "$C2J" | sed -E 's/[[:space:]]+$//; s/^/    /'
  echo "its script - core-java-2/scripts-and-decks/35-jdbc-basics.md, md5 $C2SMD5 - line $C2SL, the ON SCREEN terminal text: the capture's four lines, in order (cut out of its backticks; asserted against the file when it is beside this repository):"
  printf '    %s\n' "$C2ON1" "$C2ON2" "$C2ON3" "$C2ON4"
  echo "  Connect.java line 105's label, between its quotes: [$STL] · line 108's: [$OFFL]"
  echo "  the ON SCREEN off-by line = line 108's label + the gap: $( [ "$C2ON4" = "${OFFL}PT5H30M" ] && echo yes || echo no)"; }

# ---- ddl: Hibernate's DDL for OrderLog, its defaults, on H2 and on PostgreSQL, compared --------------------------------------
ddl() { local d
  for d in h2 pg; do rm -f .harness/run/ddl-$d.sql
    echo "Hibernate's defaults on $(DBNAME $d) - probe.map.log.OrderLog (wall LocalDateTime, moment Instant, momentNoZone Instant with @JdbcTypeCode(SqlTypes.TIMESTAMP), offsetAt OffsetDateTime, zonedAt ZonedDateTime), no setting passed:"
    Z=UTC; dbv $d; A=(ddl u13ddl ddl-$d.sql); hrun; hview; script ddl-$d.sql; done
  echo "  the script on H2 = the script on PostgreSQL, byte for byte: $(cmp -s .harness/run/ddl-h2.sql .harness/run/ddl-pg.sql && echo yes || echo no)"; }

# ---- zones: two JVMs, two zones, one database between them ----------------------------------------------------------------------
ZR=Asia/Kolkata                                      # the reader's zone in A, B and A' (the writer's: UTC)
ZBX=()                                               # extra flags for the A-and-B pair (none: Hibernate's defaults)
DBRM=1                                               # delete the H2 file after the reader (R.195)
# pair LABEL DB WRITERZONE READERZONE NAME [FLAG...]: the writer's JVM writes one OrderLog to the database NAME (a fresh one); then,
# that JVM gone, the reader's JVM opens the same database as it is and reads it back. H2: the file .harness/run/db/NAME.mv.db -
# absent before the writer, listed between the two JVMs, deleted after the reader and asserted gone; PostgreSQL: the database NAME in
# the container, kept between the two
pair() { local lab=$1 d=$2 zw=$3 zr=$4 n=$5 wp rp; shift 5
  echo "$lab on $(DBNAME $d) - the writer's JVM in $zw, then the reader's JVM in $zr, one database between them:"
  [ $d = h2 ] && echo "  before the writer: .harness/run/db $( [ -e .harness/run/db ] && echo 'EXISTS - left by an earlier run' || echo 'absent')"
  Z=$zw; dbv $d f; V=("${V[@]}" "$@"); A=(write $n); hrun; wp=$LOGS; hview
  if [ $d = h2 ]; then echo "  between the two JVMs - the writer's gone, the reader's not started; .harness/run/db holds: $(ls .harness/run/db 2> /dev/null | paste -sd' ' -)"
  else echo "  between the two JVMs - the writer's gone, the reader's not started; the database $n stays in the container"; fi
  Z=$zr; dbv $d r; V=("${V[@]}" "$@"); A=(read $n); hrun; rp=$LOGS; hview
  echo "  two JVMs, one after the other (the writer's exit before the reader's start): $( [ $rp = $((wp + 1)) ] && echo yes || echo no)"
  if [ $d = h2 ]; then [ "$DBRM" = 1 ] && rm -rf .harness/run/db
    echo "  after the reader: .harness/run/db deleted - gone: $( [ -e .harness/run/db ] && echo no || echo yes)"
    [ ! -e .harness/run/db ] || die "R.195: the H2 file the two JVMs shared is still there after the reader ($lab on H2) - .harness/run/db: $(ls .harness/run/db | paste -sd' ' -)"; fi; }
zones() { local d
  for d in h2 pg; do
    pair "A and B" $d UTC $ZR u13zab "${ZBX[@]}"
    pair "B reversed" $d Asia/Kolkata UTC u13zrev
    pair "A'" $d UTC $ZR u13za2; done; }

# ---- storage: hibernate.timezone.default_storage, on H2 and PostgreSQL; B - NATIVE on PostgreSQL, the failure receipt ------------
NATDB=pg                                             # B's database: NATIVE where the dialect cannot keep an offset
storage() { local s d
  for s in unset NATIVE NORMALIZE COLUMN AUTO; do for d in h2 pg; do
    [ $s = NATIVE ] && [ $d = $NATDB ] && continue
    rm -f .harness/run/st-$s-$d.sql
    echo "$s on $(DBNAME $d) - hibernate.timezone.default_storage $( [ $s = unset ] && echo 'not set' || echo "= $s"):"
    Z=UTC; dbv $d; [ $s = unset ] || V=("${V[@]}" -Dtzs=$s); A=(ddl u13st st-$s-$d.sql); hrun; hview; script st-$s-$d.sql; done; done
  rm -f .harness/run/st-B.sql
  echo "B - NATIVE on $(DBNAME $NATDB) - hibernate.timezone.default_storage = NATIVE (the failure receipt):"
  Z=UTC; dbv $NATDB; V=("${V[@]}" -Dtzs=NATIVE); A=(ddl u13st st-B.sql); hrun; hview; script st-B.sql; }

# ---- offset: an OffsetDateTime at +05:30, written and read back in one JVM ------------------------------------------------------
offset() { local d
  for d in h2 pg; do
    echo "$(DBNAME $d) - one OrderLog written, then read back by a new EntityManager, one JVM in UTC (offsetAt at +05:30, zonedAt in Asia/Kolkata):"
    Z=UTC; dbv $d; A=(offset u13off); hrun; hview; done; }

# ---- jdbctz: C, labelled - hibernate.jdbc.time_zone=UTC on both JVMs -------------------------------------------------------------
jdbctz() { local d
  for d in h2 pg; do pair "C - hibernate.jdbc.time_zone=UTC on both JVMs (-Djtz=UTC)," $d UTC Asia/Kolkata u13c -Djtz=UTC; done; }

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
  Z=UTC; V=(); A=(xcheck xcheck.sql); hrun; hview; script xcheck.sql
  echo "  md5 of .harness/run/xcheck.sql: $(md5 -q .harness/run/xcheck.sql)"
  echo "  Boot's script for these entities, as the owning-side lesson's xcheck captured it (Boot 4.1.2, the anchor's jar): md5 $X09"
  echo "  the same, byte for byte (md5): $( [ "$(md5 -q .harness/run/xcheck.sql)" = "$X09" ] && echo yes || echo no)"; }

# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex .harness/run/db; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log .harness/mine-write.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · .harness/run/db after the block: $(cat .harness/ex-readme.db)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · .harness/run/db after the block: $(cat .harness/ex-sol.db) · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | $G -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  [ "$(printf '%s\n' "$setup" | $G -c -- '-Duser.timezone=')" = 2 ] || die "exercise/README.md: each of its two java lines must give its JVM's zone"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
if [ -e "$1/.harness/run/db" ]; then echo "still there" > "$1/.harness/ex-readme.db"; else echo "gone" > "$1/.harness/ex-readme.db"; fi
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
if [ -e "$1/.harness/run/db" ]; then echo "still there" > "$1/.harness/ex-sol.db"; else echo "gone" > "$1/.harness/ex-sol.db"; fi
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
nxt() { printf '%s\n' "$1" | awk -v l="$2" 'f { print; exit } $0 == l { f = 1 }'; }
# R.222: a version-shaped claim prints its version in the same capture - Hibernate's own HHH000001 line (its core logger at INFO)
# and the harness's org.hibernate.Version.getVersionString() line, once per harness JVM, read off the log, never typed; S2.9/S2.17:
# the driver's version on every PostgreSQL run, from the connection's metadata; S2.12: the database: lines say H2 and PostgreSQL
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:'
DBP="  PROBE database: PostgreSQL 18.6 | select version(): PostgreSQL 18.6 (the platform after ' on ' cut) | url jdbc:postgresql://127.0.0.1:$PGP/"
DRVP=' | user sa | driver PostgreSQL JDBC Driver 42.7.14'
ndb() { printf '%s\n' "$1" | $G -F -- "$2" | { [ "$2" = "$DBP" ] && $G -F -- "$DRVP" || cat; } | wc -l | tr -d ' '; }
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] || die "$1: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its $2 harness JVMs (R.222)"
  [ "$(ndb "$c" "$DBH")" = "$3" ] && [ "$(ndb "$c" "$DBP")" = "$4" ] || die "$1: the database: lines - $3 on H2 2.5.250 and $4 on PostgreSQL 18.6 with driver 42.7.14 (S2.12, S2.17) - read $(ndb "$c" "$DBH") and $(ndb "$c" "$DBP")"; }
# S2.8: a schema step that WARNs is a failure - checked first after every capture with a JVM, so a reserved word speaks for itself
nowarn() { local n; n=$($G -v "^ *exit [0-9]* · 'GenerationTarget encountered exception': [0-9]*\$" ".r-$1.out" | $G -c 'GenerationTarget encountered exception' || true)
  [ "$n" = 0 ] || die "$1: a schema step WARNed - 'GenerationTarget encountered exception' $n times (S2.8, R.213: a field or table named after an SQL keyword? $($G -m1 -oE 'Syntax error in SQL statement "[^"]{0,80}' ".r-$1.out" || true))"; }
# the zone: every JVM of a capture prints TimeZone.getDefault().getID() - equal to the Z its java line was given (-Duser.timezone)
zchk() { local r; r=$(awk '/^\$ Z=/ { z = substr($0, 5); next } /^  PROBE JVM zone \(TimeZone\.getDefault\(\)\.getID\(\)\): / { n++; s = $0; sub(/^  PROBE JVM zone \(TimeZone\.getDefault\(\)\.getID\(\)\): /, "", s); sub(/ \|.*/, "", s); if (s != z) { bad++; w = w " " z "->" s } } END { print n + 0, bad + 0, w }' ".r-$1.out")
  [ "${r%% *}" = "$2" ] && [ "$(printf '%s\n' "$r" | cut -d' ' -f2)" = 0 ] || die "$1: every JVM prints its zone, the one its java line gives (-Duser.timezone) - $2 expected; read (JVMs, wrong, given->printed): $r"; }
# C is labelled: hibernate.jdbc.time_zone set in a JVM only under a heading that begins "C - "
jtzlabel() { local r; r=$(awk '/^[^ $]/ { h = $0; next } /^  PROBE JVM zone / && index($0, "-Djtz (hibernate.jdbc.time_zone): (not set)") == 0 { if (index(h, "C - ") != 1) bad++ } /getJdbcTimeZone\(\) / && index($0, "getJdbcTimeZone() null") == 0 { if (index(h, "C - ") != 1) bad++ } END { print bad + 0 }' ".r-$1.out")
  [ "$r" = 0 ] || die "$1: hibernate.jdbc.time_zone is set in $r JVM line(s) outside a block labelled 'C - ' - a fix both services must carry is shown as C, labelled, never inside A or B"; }
ok0() { has "$1" "  exit 0 · 'GenerationTarget encountered exception': 0" "$2: exit 0"; nhas "$1" 'PROBE EXCEPTION' "$2: no exception"; }
OFF() { printf '  PROBE %s%s\n' "$OFFL" "$1"; }        # a gap as the harness prints it: Course 2's label (Connect.java line 108) + the value
P='2026-09-14T18:30:00Z'
chk_course2() { local O; O=$(cat .r-course2.out)
  has "$O" "    $(sed -n 82p "$C2J" | sed -E 's/[[:space:]]+$//')" "course2: Connect.java line 82, the literal"
  [ "$(printf '%s\n' "$O" | sed -n '/^\$ sed -n 80,115p /,/^its script/p' | $G -c '^    ')" = 36 ] || die "course2: Connect.java lines 80-115, 36 lines"
  for l in '        Instant placed = Instant.parse("2026-09-14T18:30:00Z");     // fixed, never now()' '            ps.setTimestamp(2, Timestamp.from(placed), utc);        // wall clock, written in UTC' '                Instant readBack    = rs.getTimestamp("created_at", kolkata).toInstant();' '                IO.println("off by                           : "' '    /// A TIMESTAMP column is a wall clock. A TIMESTAMP WITH TIME ZONE is a moment.'; do has "$O" "    $l" "course2: Course 2's line"; done
  has "$O" "    $C2ON4" "course2: the ON SCREEN capture line"
  has "$O" "  the ON SCREEN off-by line = line 108's label + the gap: yes" "course2: the label byte for byte"
  echo "  course2: $T35 - Connect.java 80-115 (md5 $C2JMD5): 2026-09-14T18:30:00Z, setTimestamp(…, utc), getTimestamp(…, kolkata), off by; the script's ON SCREEN 'off by … : PT5H30M' = line 108's label + PT5H30M"; }
DDL_D='create table order_log (id bigint generated by default as identity, moment timestamp(6) with time zone, moment_no_zone timestamp(6), offset_at timestamp(6) with time zone, wall timestamp(6), zoned_at timestamp(6) with time zone, primary key (id));'
DDL_N='create table order_log (id bigint generated by default as identity, moment timestamp(6) with time zone, moment_no_zone timestamp(6), offset_at timestamp(6), wall timestamp(6), zoned_at timestamp(6), primary key (id));'
DDL_C='create table order_log (offset_at_tz integer, zoned_at_tz integer, id bigint generated by default as identity, moment timestamp(6) with time zone, moment_no_zone timestamp(6), offset_at timestamp(6) with time zone, wall timestamp(6), zoned_at timestamp(6) with time zone, primary key (id));'
scr() { printf '%s\n' "$1" | sed -n '/^  the script it wrote/,/^  [^ ]/p' | sed -n 's/^    //p'; }
same() { [ "$(scr "$1")" = "$2" ] || die "$3: the script - expected, every line: $(printf '%s\n' "$2" | paste -sd'|' -) - read: $(scr "$1" | paste -sd'|' -)"; }
STRAT() { printf "  PROBE Hibernate's reading (SessionFactoryOptions): getDefaultTimeZoneStorageStrategy() %s | getJdbcTimeZone() null\n" "$1"; }
chk_ddl() { local O d W; nowarn ddl; O=$(cat .r-ddl.out); ver ddl 2 1 1; zchk ddl 2
  for d in h2 pg; do W=$(sect ddl "Hibernate's defaults on $(DBNAME $d) - ")
    same "$W" "$DDL_D" "ddl on $(DBNAME $d)"; ok0 "$W" "ddl on $(DBNAME $d)"; done
  has "$(sect ddl "Hibernate's defaults on H2 - ")" "$(STRAT NATIVE)" "ddl: Hibernate's default strategy on H2"
  has "$(sect ddl "Hibernate's defaults on PostgreSQL - ")" "$(STRAT NORMALIZE_UTC)" "ddl: Hibernate's default strategy on PostgreSQL"
  has "$O" "  the script on H2 = the script on PostgreSQL, byte for byte: yes" "ddl: H2 = PostgreSQL"
  echo "  ddl: H2 = PostgreSQL, byte for byte - wall timestamp(6) · moment timestamp(6) with time zone · moment_no_zone timestamp(6) · offset_at, zoned_at timestamp(6) with time zone; the default strategy H2 NATIVE, PostgreSQL NORMALIZE_UTC"; }
# fld BLOCK FIELD-LINE GAP NAME: the field's read-back line, and right under it Course 2's label with the gap
fld() { has "$1" "$2" "$4: the read-back line"; [ "$(nxt "$1" "$2")" = "$(OFF "$3")" ] || die "$4: under '$2' expected '$(OFF "$3")' - read '$(nxt "$1" "$2")'"; }
WALL() { printf "  PROBE wall (LocalDateTime) read back: %s - as an instant in this JVM's zone: %s\n" "$1" "$2"; }
MNZ() { printf '  PROBE momentNoZone (Instant on a timestamp column) read back: %s\n' "$1"; }
MOM="  PROBE moment (Instant) read back: $P"
OFA() { case $1 in h2) printf '  PROBE offsetAt (OffsetDateTime) read back: 2026-09-15T00:00+05:30 - its instant: %s\n' "$P" ;; pg) printf '  PROBE offsetAt (OffsetDateTime) read back: 2026-09-14T18:30Z - its instant: %s\n' "$P" ;; esac; }
ZOA() { case $1 in h2) printf '  PROBE zonedAt (ZonedDateTime) read back: 2026-09-15T00:00+05:30 - its instant: %s\n' "$P" ;; pg) printf '  PROBE zonedAt (ZonedDateTime) read back: 2026-09-14T18:30Z - its instant: %s\n' "$P" ;; esac; }
RAWU() { case $1 in h2) echo '  PROBE the row by a second connection (H2, each column cast as varchar) - wall | moment | moment_no_zone | offset_at | zoned_at: [2026-09-14 18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00 | 2026-09-15 00:00:00+05:30 | 2026-09-15 00:00:00+05:30]' ;;
  pg) echo "  PROBE the row by a second connection (PostgreSQL, set time zone 'UTC' on it first; each column ::text) - wall | moment | moment_no_zone | offset_at | zoned_at: [2026-09-14 18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00+00]" ;; esac; }
RAWK() { case $1 in h2) echo '  PROBE the row by a second connection (H2, each column cast as varchar) - wall | moment | moment_no_zone | offset_at | zoned_at: [2026-09-15 00:00:00 | 2026-09-14 18:30:00+00 | 2026-09-15 00:00:00 | 2026-09-15 00:00:00+05:30 | 2026-09-15 00:00:00+05:30]' ;;
  pg) echo "  PROBE the row by a second connection (PostgreSQL, set time zone 'UTC' on it first; each column ::text) - wall | moment | moment_no_zone | offset_at | zoned_at: [2026-09-15 00:00:00 | 2026-09-14 18:30:00+00 | 2026-09-15 00:00:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00+00]" ;; esac; }
# pairok BLOCK NAME: the pair's own witnesses - two JVMs, one after the other; the reader's no schema step; one INSERT by the writer
# and one SELECT by the reader, each counted three ways (the SQL log, getPrepareStatementCount, the driver's prepareStatement - R.184);
# H2: the file absent before, listed between, gone after (R.195)
pairok() { local W=$1 n=$2 d=$3
  has "$W" "  two JVMs, one after the other (the writer's exit before the reader's start): yes" "$n: two JVMs"
  [ "$(cnt "$W" "  exit 0 · 'GenerationTarget encountered exception': 0")" = 2 ] || die "$n: both JVMs exit 0, no schema WARN"
  nhas "$W" 'PROBE EXCEPTION' "$n: no exception"
  [ "$(printf '%s\n' "$W" | $G -c '^  DEBUG org\.hibernate\.SQL : insert into order_log ')" = 1 ] && [ "$(printf '%s\n' "$W" | $G -c '^  DEBUG org\.hibernate\.SQL : select ol1_0\.')" = 1 ] \
    && [ "$(cnt "$W" '  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 0 | entities loaded (getEntityLoadCount) 0 | entity inserts 1')" = 1 ] \
    && [ "$(cnt "$W" '  PROBE jdbc: prepareStatement 1 | executeUpdate 1 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0')" = 1 ] \
    && [ "$(cnt "$W" '  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 1 | entities loaded (getEntityLoadCount) 1 | entity inserts 0')" = 1 ] \
    && [ "$(cnt "$W" '  PROBE jdbc: prepareStatement 1 | executeUpdate 0 | addBatch 0 | executeBatch 0 | executeQuery 1 | execute 0')" = 1 ] \
    || die "$n: the writer's one INSERT and the reader's one SELECT, each counted three ways - the SQL log, getPrepareStatementCount(), the driver's prepareStatement (R.184)"
  [ "$(printf '%s\n' "$W" | $G -c '^  DEBUG org\.hibernate\.SQL : create table ')" = 1 ] || die "$n: one schema step - the writer's; the reader opens the database as it is"
  if [ $d = h2 ]; then
    has "$W" "  before the writer: .harness/run/db absent" "$n: R.195 - no H2 file before the writer"
    has "$W" "  between the two JVMs - the writer's gone, the reader's not started; .harness/run/db holds: ${4}.mv.db" "$n: the H2 file between the two JVMs"
    has "$W" "  after the reader: .harness/run/db deleted - gone: yes" "$n: R.195 - the H2 file left behind"
  else has "$W" "  between the two JVMs - the writer's gone, the reader's not started; the database $4 stays in the container" "$n: the PostgreSQL database kept between"; fi; }
G5=""; GR=""; G0=""; GC=""; GCW=""
chk_zones() { local d W n; nowarn zones; jtzlabel zones
  for d in h2 pg; do
    # B and A: the writer in UTC, the reader in Asia/Kolkata
    n="zones A and B on $(DBNAME $d)"; W=$(sect zones "A and B on $(DBNAME $d) - ")
    fld "$W" "$(WALL 2026-09-14T18:30 2026-09-14T13:00:00Z)" PT5H30M "$n: B - the LocalDateTime, Course 2's gap"
    fld "$W" "$(MNZ 2026-09-14T13:00:00Z)" PT5H30M "$n: B - the Instant forced onto timestamp, Course 2's gap"
    fld "$W" "$MOM" PT0S "$n: A - the default Instant, no gap"
    fld "$W" "$(OFA $d)" PT0S "$n: the OffsetDateTime"; fld "$W" "$(ZOA $d)" PT0S "$n: the ZonedDateTime"
    has "$W" "$(RAWU $d)" "$n: the row by a second connection"
    has "$W" "  PROBE JVM zone (TimeZone.getDefault().getID()): UTC | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)" "$n: the writer in UTC"
    has "$W" "  PROBE JVM zone (TimeZone.getDefault().getID()): Asia/Kolkata | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)" "$n: the reader in Asia/Kolkata"
    pairok "$W" "$n" $d u13zab
    # reversed: the writer in Asia/Kolkata, the reader in UTC
    n="zones B reversed on $(DBNAME $d)"; W=$(sect zones "B reversed on $(DBNAME $d) - ")
    fld "$W" "$(WALL 2026-09-15T00:00 2026-09-15T00:00:00Z)" PT-5H-30M "$n: the LocalDateTime, the other way"
    fld "$W" "$(MNZ 2026-09-15T00:00:00Z)" PT-5H-30M "$n: the forced Instant, the other way"
    fld "$W" "$MOM" PT0S "$n: the default Instant"; fld "$W" "$(OFA $d)" PT0S "$n: the OffsetDateTime"
    has "$W" "$(RAWK $d)" "$n: the row by a second connection - the writer's clock face in the timestamp columns"
    pairok "$W" "$n" $d u13zrev
    # A': A again - fresh JVMs, a fresh database
    n="zones A' on $(DBNAME $d)"; W=$(sect zones "A' on $(DBNAME $d) - ")
    fld "$W" "$MOM" PT0S "$n: the default Instant, again"
    fld "$W" "$(WALL 2026-09-14T18:30 2026-09-14T13:00:00Z)" PT5H30M "$n: and the LocalDateTime's gap, again"
    pairok "$W" "$n" $d u13za2; done
  # S2.19, R.224: the line the video calls Course 2's is byte-equal to Course 2's capture line (its script's ON SCREEN text)
  [ "$(cnt "$(cat .r-zones.out)" "  PROBE $C2ON4")" = 8 ] || die "zones: Course 2's line, byte for byte ('$C2ON4'), under the LocalDateTime and the forced Instant in A and B and under the LocalDateTime in A', on both databases - 8 expected, read $(cnt "$(cat .r-zones.out)" "  PROBE $C2ON4") (R.224)"
  ver zones 12 6 6; zchk zones 12
  G5=$(nxt "$(sect zones 'A and B on H2 - ')" "$(WALL 2026-09-14T18:30 2026-09-14T13:00:00Z)" | sed "s/^  PROBE $OFFL//")
  GR=$(nxt "$(sect zones 'B reversed on PostgreSQL - ')" "$(WALL 2026-09-15T00:00 2026-09-15T00:00:00Z)" | sed "s/^  PROBE $OFFL//")
  G0=$(nxt "$(sect zones "A' on PostgreSQL - ")" "$MOM" | sed "s/^  PROBE $OFFL//")
  echo "  zones: writer UTC -> reader Asia/Kolkata, H2 (a file) and PostgreSQL (a kept database): B wall and momentNoZone '$C2ON4' (Course 2's line, byte for byte, 8 times) · A moment $G0 · offsetAt/zonedAt PT0S (H2 +05:30 kept, PostgreSQL 18:30Z) · reversed $GR · A' = A; every pair two JVMs, one INSERT + one SELECT counted three ways, the H2 file deleted and gone"; }
chk_storage() { local s d W e; nowarn storage; ver storage 10 5 5; zchk storage 10; jtzlabel storage
  # B - the failure receipt: NATIVE on PostgreSQL refused - exit 1, Hibernate's message, no factory, no script; on PostgreSQL
  W=$(sect storage "B - NATIVE on PostgreSQL - ")
  [ -n "$W" ] || die "storage B: the NATIVE run must be PostgreSQL's - no block 'B - NATIVE on PostgreSQL' (H2 keeps an offset: it starts there)"
  [ "$(ndb "$W" "$DBP")" = 1 ] && [ "$(ndb "$W" "$DBH")" = 0 ] || die "storage B: the refusal must be PostgreSQL's - its database: line"
  has "$W" '  PROBE EXCEPTION org.hibernate.HibernateException: The configured time zone storage type NATIVE is not supported with the configured dialect' "storage B: PostgreSQL's dialect refuses NATIVE"
  has "$W" "  exit 1 · 'GenerationTarget encountered exception': 0" "storage B: exit 1"
  has "$W" '    (none: no such file)' "storage B: no script written"
  nhas "$W" 'org.hibernate.SQL' "storage B: no SQL"; nhas "$W" "Hibernate's reading" "storage B: no factory"
  for s in unset NATIVE NORMALIZE COLUMN AUTO; do for d in h2 pg; do
    [ $s = NATIVE ] && [ $d = pg ] && continue
    W=$(sect storage "$s on $(DBNAME $d) - ")
    case $s-$d in unset-h2|NATIVE-h2|AUTO-h2) e=NATIVE ;; unset-pg) e=NORMALIZE_UTC ;; NORMALIZE-*) e=NORMALIZE ;; COLUMN-*|AUTO-pg) e=COLUMN ;; esac
    has "$W" "$(STRAT $e)" "storage $s on $(DBNAME $d): Hibernate's reading, $e"
    case $e in NATIVE|NORMALIZE_UTC) same "$W" "$DDL_D" "storage $s on $(DBNAME $d)" ;; NORMALIZE) same "$W" "$DDL_N" "storage $s on $(DBNAME $d)" ;; COLUMN) same "$W" "$DDL_C" "storage $s on $(DBNAME $d)" ;; esac
    ok0 "$W" "storage $s on $(DBNAME $d)"; done; done
  echo "  storage: not set -> H2 NATIVE, PostgreSQL NORMALIZE_UTC (both: offset_at/zoned_at with time zone) · NORMALIZE -> timestamp(6), no zone · COLUMN -> + offset_at_tz integer, zoned_at_tz integer · AUTO -> H2 NATIVE, PostgreSQL COLUMN · B NATIVE on PostgreSQL: exit 1, 'The configured time zone storage type NATIVE is not supported with the configured dialect', no script"; }
chk_offset() { local d W; nowarn offset; ver offset 2 1 1; zchk offset 2; jtzlabel offset
  for d in h2 pg; do W=$(sect offset "$(DBNAME $d) - ")
    fld "$W" "$(OFA $d)" PT0S "offset on $(DBNAME $d): the OffsetDateTime read back"; fld "$W" "$(ZOA $d)" PT0S "offset on $(DBNAME $d): the ZonedDateTime read back"
    has "$W" "$(RAWU $d)" "offset on $(DBNAME $d): the row by a second connection"
    has "$W" '  PROBE written by this JVM: wall 2026-09-14T18:30 (this JVM'"'"'s clock face for that instant) | moment 2026-09-14T18:30:00Z | momentNoZone 2026-09-14T18:30:00Z | offsetAt 2026-09-15T00:00+05:30 | zonedAt 2026-09-15T00:00+05:30[Asia/Kolkata]' "offset on $(DBNAME $d): written at +05:30"
    ok0 "$W" "offset on $(DBNAME $d)"; done
  echo "  offset: written 2026-09-15T00:00+05:30 - read back on H2 2026-09-15T00:00+05:30 (the offset kept), on PostgreSQL 2026-09-14T18:30Z (the offset gone, the same instant: PT0S on both); zonedAt the same, its zone id not kept on either"; }
chk_jdbctz() { local d W n; nowarn jdbctz; ver jdbctz 4 2 2; zchk jdbctz 4; jtzlabel jdbctz
  [ "$(cnt "$(cat .r-jdbctz.out)" "  PROBE JVM zone (TimeZone.getDefault().getID()): UTC | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): UTC")" = 2 ] \
    && [ "$(cnt "$(cat .r-jdbctz.out)" "  PROBE JVM zone (TimeZone.getDefault().getID()): Asia/Kolkata | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): UTC")" = 2 ] \
    && [ "$(cat .r-jdbctz.out | $G -c "getJdbcTimeZone() UTC$")" = 4 ] || die "jdbctz: C - both JVMs carry hibernate.jdbc.time_zone=UTC, and Hibernate reads it (getJdbcTimeZone() UTC), on both databases"
  for d in h2 pg; do n="jdbctz C on $(DBNAME $d)"; W=$(sect jdbctz "C - hibernate.jdbc.time_zone=UTC on both JVMs (-Djtz=UTC), on $(DBNAME $d) - ")
    fld "$W" "$(WALL 2026-09-15T00:00 "$P")" PT0S "$n: the LocalDateTime - no gap, its clock face shifted"
    fld "$W" "$(MNZ "$P")" PT0S "$n: the forced Instant - no gap"
    fld "$W" "$MOM" PT0S "$n: the default Instant"
    has "$W" "$(RAWU $d)" "$n: the row by a second connection - the same as A's"
    pairok "$W" "$n" $d u13c; done
  GC=$(nxt "$(sect jdbctz 'C - hibernate.jdbc.time_zone=UTC on both JVMs (-Djtz=UTC), on PostgreSQL - ')" "$(MNZ "$P")" | sed "s/^  PROBE $OFFL//")
  GCW=$(sect jdbctz 'C - hibernate.jdbc.time_zone=UTC on both JVMs (-Djtz=UTC), on PostgreSQL - ' | sed -n -E 's/^  PROBE wall \(LocalDateTime\) read back: ([^ ]+) - .*/\1/p')
  echo "  jdbctz: C (labelled) - hibernate.jdbc.time_zone=UTC on both JVMs, H2 and PostgreSQL: momentNoZone $GC, wall $GC - but the wall clock reads $GCW in Asia/Kolkata (written 2026-09-14T18:30); the row the same as A's"; }
# R.212 (RED #308): the harness's script for the anchor's two entities = Boot's as unit 09 captured it, by md5
chk_xcheck() { local XC l; nowarn xcheck; XC=$(cat .r-xcheck.out); ver xcheck 1 1 0; zchk xcheck 1
  [ "$(printf '%s\n' "$XC" | sed -n '/xcheck.sql - every line:$/,/^  md5 of/p' | $G -c '^    ')" = 3 ] || die "xcheck: three lines"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the harness's script = Boot's (md5 $X09)"
  if [ -n "$BOOT09" ]; then printf '%s\n' "$BOOT09" | while IFS= read -r l; do has "$XC" "    $l" "xcheck: Boot's line as ../c7-unit09/.r-xcheck.out holds it"; done; fi
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity and PauseEntity, md5 $X09 = Boot's script as unit 09 captured it (R.212)"; }
EXQ="Your turn: the README stores the order time as a LocalDateTime and Kolkata reads it five and a half hours early. Store the moment."
chk_exercise() { local EXB EXZ b ER ES l
  nowarn exercise
  EXB=$(sect exercise "in bash"); EXZ=$(sect exercise "in zsh")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the writer, in UTC: exit 0' '    the reader, in Asia/Kolkata: exit 0' '    PROBE JVM zone (TimeZone.getDefault().getID()): UTC | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)' \
        '    PROBE JVM zone (TimeZone.getDefault().getID()): Asia/Kolkata | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)' \
        '    PROBE placedAt (LocalDateTime) written by this JVM: 2026-09-14T18:30' "    PROBE placedAt (LocalDateTime) read back: 2026-09-14T18:30 - as an instant in this JVM's zone: 2026-09-14T13:00:00Z" "    PROBE $C2ON4"; do has "$ER" "$l" "exercise: the README - a LocalDateTime, Kolkata five and a half hours early"; done
    for l in '    the writer, in UTC: exit 0' '    the reader, in Asia/Kolkata: exit 0' "    PROBE placedAt (Instant) written by this JVM: $P" "    PROBE placedAt (Instant) read back: $P" "    PROBE ${OFFL}PT0S"; do has "$ES" "$l" "exercise: the solution - an Instant, no gap"; done
    nhas "$ES" 'PT5H30M' "exercise: the solution has no gap"; nhas "$b" 'EXCEPTION' "exercise: nothing throws"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder · \.harness/run/db after the block: gone")" = 2 ] || die "exercise: the shell back in this folder, the H2 file gone after each block (R.195)"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 24 ] || die "exercise: the spoken line is 24 words (R.203)"
  $G -qxF '    private LocalDateTime placedAt;' harness/src/probe/map/ex/OrderLog.java || die "exercise: ex.OrderLog ships a LocalDateTime"
  echo "  exercise: bash and zsh alike - the README as written (placedAt a LocalDateTime; writer UTC, reader Asia/Kolkata, two JVMs, an H2 file): '$C2ON4'; the solution (one line: an Instant): '${OFFL}PT0S'; the H2 file gone after each; 24 words"; }
cap course2 course2; chk_course2
cap ddl ddl; chk_ddl
cap zones zones; chk_zones
cap storage storage; chk_storage
cap offset offset; chk_offset
cap jdbctz jdbctz; chk_jdbctz
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise
# the values the video says are the captures', never typed: README.md states them in one line, compared with what the checks read
VS="the gaps the video may say: B $G5 · reversed $GR · A and A′ $G0 · C $GC (its wall clock read $GCW)"
$G -qF -- "$VS" README.md || die "README.md does not state the gaps these captures give ('$VS') - a typed value: $($G -oE 'the gaps the video may say: [^*`]*' README.md | head -1)"
echo "  README.md states the captures' gaps: $VS"

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
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE 'https?://' || die "$f runs a command with a URL - this unit makes no request"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL -Duser.timezone=" > /dev/null || die "$f starts a JVM without its locale and its zone pinned on its java line (S6.1, the zone rule)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|String|Long|int|Instant|LocalDateTime|OffsetDateTime|ZonedDateTime) +(order|offset|user|value|key|zone|timestamp)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
# R.195: no H2 database file anywhere in this folder - .harness/ included - nor beside it
[ ! -e .harness/run/db ] || die "R.195: .harness/run/db is still there - the H2 file the two JVMs shared must be deleted"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "R.195: an H2 database file exists - the shared file is deleted after its reader"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 0 raw passwords in every raw capture run and every file but its own; 'GenerationTarget encountered exception' 0; no path, unit number (course2 quotes Course 2's folder by name), time, millisecond figure, OS token, other port, generated name or stack frame in any capture; every JVM pinned - locale and zone; no kill by name; no bare wait; options as arrays; no H2 file left (R.195); no dish name"

# ---- the end: the container removed, the anchor, the ports -------------------------------------------------------------------
docker rm -f "$PGN" > /dev/null 2>&1 || die "docker rm -f $PGN failed"; PGUP=""
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "the container $PGN is still there"
echo "  the container: removed (docker ps -a --filter name=$PGN: 0 lines)"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19920-19929 at the end; 19928 was the container's (127.0.0.1 only), 19929 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit13: every capture 3/3 and = published; every spoken value asserted; 0 raw passwords; the H2 file gone; the container removed"
