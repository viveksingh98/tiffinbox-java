#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Inheritance: Three Strategies - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit09/after,
# the tree Section 2 froze (= ../c7-tiffinbox when this unit was built; compared at the start and the end, a note when they differ,
# never a stop - R.211). Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every
# number and string the video says is asserted right after its capture by a check that can fail. Two databases: H2, in each harness
# JVM's memory, gone with it; and PostgreSQL 18.6 in a container of this run's (postgres@sha256:77f58511..., --pull never, published
# on 127.0.0.1:19918 only), a fresh database for every harness run, the container removed at the end and by the trap. Every capture
# says which database answered (a database: line per run). One abstract Meal (id, title, int price), two kinds - PlatterMeal (int
# dishes), SaladMeal (String dressing) - one Platter and one Salad written by every run (English names only, R.215):
#   ddl         the three strategies' DDL - SINGLE_TABLE, JOINED, TABLE_PER_CLASS (+ SEQUENCE) - on H2 and on PostgreSQL, the two
#               scripts compared byte for byte; the rows each table holds, by a second connection
#   tpcidentity the failure receipt: TABLE_PER_CLASS with IDENTITY (the id TiffinBox uses) - B: the factory refuses to start, on H2 and
#               on PostgreSQL (the trio: exit 1, the PersistenceException and its MappingException, no script written); A' = the same
#               strategy with SEQUENCE - it starts, two rows
#   sql         select m from Meal m order by m.id, per strategy and database: the one SQL statement Hibernate sent (counted three ways,
#               R.184) - one table, two left joins, a union all; PostgreSQL's typed nulls beside H2's
#   plans       the plan slide: that SQL, as a StatementInspector kept it, handed to PostgreSQL's EXPLAIN (no ANALYZE) on three fresh
#               databases per strategy, the plan text's md5 compared (RE-MEASURE 13); H2's EXPLAIN beside it - the query rewritten
#   mapped      @MappedSuperclass, the fourth way and not a strategy: two tables, two id counters each starting at 1; select m
#               from Meal m refused (Meal is no entity) - and the same class named in full answered by two SELECTs, one per table (H2)
#   xcheck      the harness's DDL for the anchor's CustomerEntity and PauseEntity against Boot's script as the owning-side lesson
#               captured it (its md5, f5956370..., in ../c7-unit09/README.md - R.212, RED #308: this unit runs no Boot)
#   exercise    exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#               shell - /bin/bash, then again in /bin/zsh -f (H2)
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar is extracted (the anchor's own line). The PostgreSQL driver is resolved by Maven from .m2-demo (harness/pom.xml: Boot's
# managed version, none written). The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with javac
# -parameters against that extracted jar and the driver into .harness/hc. probe.map.H builds one EntityManagerFactory per run
# (Jakarta Persistence 3.2's PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that
# run's own database only) over a DataSource wrapped in a proxy that counts the driver calls. It runs from .harness/run and binds
# no port. Its JVM flags travel as an array, V, its arguments as an array, A (R.193). Commands are printed exactly as they run:
# each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) gates this unit's prose: it
# speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
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
# constraint names "FK<hash>" and "UK<hash>"; H2's generated index names "PRIMARY_KEY_<n>" and constraint names "CONSTRAINT_<n>".
# A harness JVM's log is printed whole (every line, trailing spaces dropped).
# Ports (§P, 19910-19919): the container 19918, published on 127.0.0.1 only (docker port asserted); 19919 never bound. Every one of
# 19910-19919 is checked free at the start and the end (19918 after the container is gone), with 18425 (TiffinBox's default), 8080
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
PGN=c7-u12-pg; PGP=19918
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
for t in python3 rsync lsof unzip mvn md5 cmp docker /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY PGPASSWORD PGUSER PGHOST DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
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
SFILES='probe/map/H.java probe/map/Main.java probe/map/Shown.java probe/map/ex/Meal.java probe/map/ex/PlatterMeal.java probe/map/ex/SaladMeal.java probe/map/joined/Meal.java probe/map/joined/PlatterMeal.java probe/map/joined/SaladMeal.java probe/map/mapped/Meal.java probe/map/mapped/PlatterMeal.java probe/map/mapped/SaladMeal.java probe/map/single/Meal.java probe/map/single/PlatterMeal.java probe/map/single/SaladMeal.java probe/map/tpc/Meal.java probe/map/tpc/PlatterMeal.java probe/map/tpc/SaladMeal.java probe/map/tpcid/Meal.java probe/map/tpcid/PlatterMeal.java probe/map/tpcid/SaladMeal.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19910 19911 19912 19913 19914 19915 19916 19917 19918 19919"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
# the image, by digest, already on this computer (a receipt never pulls); no container of this unit's name
docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack here); this unit runs PostgreSQL 18 in a container"
[ "$(docker image inspect "$IMG" --format '{{.Id}}' 2> /dev/null || true)" = "${IMG#postgres@}" ] || die "the image is not on this computer: docker pull $IMG"
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "a container named $PGN exists - an interrupted run's? remove it: docker rm -f $PGN"
rm -rf .harness; mkdir -p .harness/run .harness/pg .harness/drv .harness/hc


# ---- duration words: none - this unit speaks no time (R.172); and English names only (R.215) ---------------------------------
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
# R.215: meals and dishes have English names here - the AI voice mispronounces Indian dish names (the course's memory rule); the
# list is refused, whole words, any case, in this unit's prose, its harness and (at the end) every capture. And the probe's own
# names for this lesson's classes (ThaliMeal, curries - RE-MEASURE 9) are refused inside any identifier too, any case.
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain|curry|curries'
PROBEN='thali|curries|khichdi'
dishes() { { $G -rniwE -- "$DISH" "$@" 2> /dev/null; $G -rniE -- "[a-z_]($PROBEN)|($PROBEN)[a-z_]" "$@" 2> /dev/null; } | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes harness/src exercise)
[ -z "$DN" ] || die "an Indian dish name, or the probe's ThaliMeal/curries (R.215, RE-MEASURE 9: English names only): $DN"
# this README names the probe's old names once each, as history (What differed) - only on lines that say so
DN=$({ $G -niwE -- "$DISH" README.md; $G -niE -- "[a-z_]($PROBEN)|($PROBEN)[a-z_]" README.md; } | $G -v 'the probe' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name in README.md (R.215: English names only; the probe's names only on a line that says 'the probe'): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, and the probe's ThaliMeal/curries inside any name, over README.md, exercise/, harness/src)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_PG=$(mine "docker run -d --pull never --name $PGN -e POSTGRES_USER=sa -e POSTGRES_PASSWORD=\"\$PGPW\" -p 127.0.0.1:$PGP:5432 $IMG")
L_DRV=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*:.harness/drv/*\" $HS/H.java $HS/Main.java $HS/Shown.java $HS/single/*.java $HS/joined/*.java $HS/tpc/*.java $HS/tpcid/*.java $HS/mapped/*.java")
L_H=$(mine "java $JL -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*:../drv/*\" probe.map.Main \"\${A[@]}\"")
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

# ---- the container: started once, before the captures; every harness run on PostgreSQL makes its own fresh database in it ----
pgmask() { awk -v p="$PGPW" '{ gsub(p, "[masked: the 24-character password]"); print }'; }
echo "  \$ $(printf '%s\n' "${L_PG/\"\$PGPW\"/$PGPW}" | pgmask)" >&3
PGUP=1; (eval "$L_PG") > .harness/pg/cid 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/pg/cid | pgmask)"
i=0; while [ $i -lt 120 ]; do docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 && break; sleep 0.5; i=$((i + 1)); done
docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 || die "Postgres never became ready in the container"
[ "$(docker port "$PGN")" = "5432/tcp -> 127.0.0.1:$PGP" ] || die "the container is not published on 127.0.0.1:$PGP alone: $(docker port "$PGN" | paste -sd';' -)"
[ "$(listeners 19919)" = 0 ] || die "something listens on 19919 - it is never bound"
echo "  the container $PGN: up, published on $(docker port "$PGN") only" >&3

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; }
PGV=(-Ddb=pg -Dpg.port=$PGP -Dpg.passfile=../pg/password)    # a harness run on PostgreSQL: where the container is, and the password's file
# hrun: the harness line (V, A set by the caller), run from .harness/run; it exits by itself (bounded: 240 s); its exit code in
# HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H")
  pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
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
printf '%s\n' "Starting probe using Java 25.0.4.1" "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'alter table if exists platter_meal add constraint FKf6bjesl03vnrm7801593526l1 foreign key (id) references meal;' 'alter table if exists t add constraint UKm2mc7dy22sku3hjrgease2abs unique (x);' '    /* PUBLIC.PRIMARY_KEY_9: ID = M1_0.ID */' 'Check constraint violation: "CONSTRAINT_8A"' "jdbc:postgresql://127.0.0.1:$PGP/u12x?user=sa&password=$PGPW" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting probe using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'alter table if exists platter_meal add constraint FK<hash> foreign key (id) references meal;' 'alter table if exists t add constraint UK<hash> unique (x);' '    /* PUBLIC.PRIMARY_KEY_<n>: ID = M1_0.ID */' 'Check constraint violation: "CONSTRAINT_<n>"' "jdbc:postgresql://127.0.0.1:$PGP/u12x?user=sa&password=[masked: the 24-character password]")" ] || die "mask: the planted JDK version, folders, home, identity hash, constraint and index names and the password must be masked"
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
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or image, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
SNAME() { case $1 in single) echo SINGLE_TABLE ;; joined) echo JOINED ;; tpc) echo TABLE_PER_CLASS ;; esac; }
DBNAME() { case $1 in h2) echo H2 ;; pg) echo PostgreSQL ;; esac; }
dbv() { if [ "$1" = pg ]; then V=("${PGV[@]}"); else V=(); fi; }



# ---- ddl: the three strategies' DDL, on H2 and on PostgreSQL, compared; the rows each table holds ---------------------------------
ddl() { local s d
  for s in single joined tpc; do
    for d in h2 pg; do rm -f .harness/run/ddl-$s-$d.sql
      echo "$(SNAME $s) on $(DBNAME $d) - probe.map.$s (@Inheritance(strategy = InheritanceType.$(SNAME $s)), ids $( [ $s = tpc ] && echo SEQUENCE || echo IDENTITY)); one Platter and one Salad:"
      dbv $d; A=(ddl $s ddl-$s-$d.sql); hrun; hview; script ddl-$s-$d.sql; done
    echo "  $(SNAME $s): the script on H2 = the script on PostgreSQL, byte for byte: $(cmp -s .harness/run/ddl-$s-h2.sql .harness/run/ddl-$s-pg.sql && echo yes || echo no)"; done; }

# ---- tpcidentity: TABLE_PER_CLASS with IDENTITY (B, the failure receipt) and with SEQUENCE (A'), on H2 and PostgreSQL --------------
TPCB=tpcid                                           # B: the strategy package with IDENTITY ids
tpcidentity() { local d
  for d in h2 pg; do rm -f .harness/run/tpcb-$d.sql
    echo "B on $(DBNAME $d) - probe.map.tpcid (TABLE_PER_CLASS, @GeneratedValue(strategy = GenerationType.IDENTITY)):"
    dbv $d; A=(start $TPCB tpcb-$d.sql); hrun; hview; script tpcb-$d.sql; done
  for d in h2 pg; do rm -f .harness/run/tpca-$d.sql
    echo "A' on $(DBNAME $d) - probe.map.tpc (TABLE_PER_CLASS, @GeneratedValue(strategy = GenerationType.SEQUENCE)), its own JVM:"
    dbv $d; A=(start tpc tpca-$d.sql); hrun; hview; script tpca-$d.sql; done; }

# ---- sql: the polymorphic query, per strategy and database -----------------------------------------------------------------------
sql() { local s d
  for s in single joined tpc; do for d in h2 pg; do
    echo "$(SNAME $s) on $(DBNAME $d) - select m from Meal m order by m.id, a new EntityManager, the counters reset:"
    dbv $d; A=(sql $s); hrun; hview; done; done; }

# ---- plans: the plan slide - PostgreSQL's EXPLAIN of the SQL Hibernate prepared, three fresh databases; H2's beside it -----------
PLANDB=pg; ROUNDS=3                                  # the plan slide's database, and its fresh databases per strategy (RE-MEASURE 13)
plans() { local s
  for s in single joined tpc; do
    echo "$(SNAME $s) - the plan slide: PostgreSQL's EXPLAIN of the SQL Hibernate prepared, on $ROUNDS fresh databases in one JVM:"
    dbv $PLANDB; A=(plan $s $ROUNDS); hrun; hview
    echo "$(SNAME $s) - beside it: H2's EXPLAIN of its SQL:"
    dbv h2; A=(plan $s 1); hrun; hview; done; }

# ---- mapped: @MappedSuperclass - two tables, two id counters, the polymorphic query refused ---------------------------------------
mapped() { rm -f .harness/run/mapped.sql
  echo "@MappedSuperclass on H2 - probe.map.mapped (Meal a @MappedSuperclass with the id, IDENTITY; PlatterMeal and SaladMeal the entities):"
  V=(); A=(mapped mapped.sql); hrun; hview; script mapped.sql; }

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
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# R.222: a version-shaped claim prints its version in the same capture - Hibernate's own HHH000001 line (its core logger at INFO)
# and the harness's org.hibernate.Version.getVersionString() line, once per harness JVM, read off the log, never typed; S2.9/S2.17:
# the driver's version on every PostgreSQL run, from the connection's metadata; S2.12: the database: lines say H2 and PostgreSQL
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
DBH='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:'
DBP="  PROBE database: PostgreSQL 18.6 | select version(): PostgreSQL 18.6 (the platform after ' on ' cut) | url jdbc:postgresql://127.0.0.1:$PGP/"
DRVP=' (a fresh database) | user sa | driver PostgreSQL JDBC Driver 42.7.14'
ndb() { printf '%s\n' "$1" | $G -F -- "$2" | { [ "$2" = "$DBP" ] && $G -F -- "$DRVP" || cat; } | wc -l | tr -d ' '; }
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] || die "$1: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its $2 harness JVMs (R.222)"
  [ "$(ndb "$c" "$DBH")" = "$3" ] && [ "$(ndb "$c" "$DBP")" = "$4" ] || die "$1: the database: lines - $3 on H2 2.5.250 and $4 on PostgreSQL 18.6 with driver 42.7.14 (S2.12, S2.17) - read $(ndb "$c" "$DBH") and $(ndb "$c" "$DBP")"; }
ok0() { has "$1" "  exit 0 · 'GenerationTarget encountered exception': 0" "$2: exit 0"; nhas "$1" 'PROBE EXCEPTION' "$2: no exception"; }
ROWS2='  PROBE persisted: PlatterMeal 1 | Platter | 120 | dishes 3 ; SaladMeal 2 | Salad | 90 | dressing lemon'
FKP='alter table if exists platter_meal add constraint FK<hash> foreign key (id) references meal;'
FKS='alter table if exists salad_meal add constraint FK<hash> foreign key (id) references meal;'
DDL_S="create table meal (dishes integer, price integer not null, id bigint generated by default as identity, dtype varchar(31) not null check ((dtype in ('PlatterMeal','SaladMeal'))), dressing varchar(255), title varchar(255), primary key (id), check (dtype <> 'PlatterMeal' or (dishes is not null)));"
DDL_JM='create table meal (price integer not null, id bigint generated by default as identity, title varchar(255), primary key (id));'
DDL_JP='create table platter_meal (dishes integer not null, id bigint not null, primary key (id));'
DDL_JS='create table salad_meal (id bigint not null, dressing varchar(255), primary key (id));'
DDL_TQ='create sequence meal_seq start with 1 increment by 50;'
DDL_TP='create table platter_meal (dishes integer not null, price integer not null, id bigint not null, title varchar(255), primary key (id));'
DDL_TS='create table salad_meal (price integer not null, id bigint not null, dressing varchar(255), title varchar(255), primary key (id));'
scr() { printf '%s\n' "$1" | sed -n '/^  the script it wrote/,/^  [^ ]/p' | sed -n 's/^    //p'; }
same() { [ "$(scr "$1")" = "$2" ] || die "$3: the script - expected, every line: $(printf '%s\n' "$2" | paste -sd'|' -) - read: $(scr "$1" | paste -sd'|' -)"; }
chk_ddl() { local O s d W e; O=$(cat .r-ddl.out); ver ddl 6 3 3
  for s in single joined tpc; do
    case $s in single) e="$DDL_S" ;; joined) e=$(printf '%s\n' "$DDL_JM" "$DDL_JP" "$DDL_JS" "$FKP" "$FKS") ;; tpc) e=$(printf '%s\n' "$DDL_TQ" "$DDL_TP" "$DDL_TS") ;; esac
    for d in h2 pg; do W=$(blk ddl "$(SNAME $s) on $(DBNAME $d) - " "  $(SNAME $s): the script on H2")
      [ "$d" = h2 ] && W=$(printf '%s\n' "$W" | sed "/^$(SNAME $s) on PostgreSQL - /,\$d")
      same "$W" "$e" "ddl $(SNAME $s) on $(DBNAME $d)"
      has "$W" "$ROWS2" "ddl $(SNAME $s) on $(DBNAME $d): the two rows"; ok0 "$W" "ddl $(SNAME $s) on $(DBNAME $d)"
      case $s in
        single) has "$W" '  PROBE meal (id | dtype | title | price | dishes | dressing): [1 | PlatterMeal | Platter | 120 | 3 | null, 2 | SaladMeal | Salad | 90 | null | lemon]' "ddl SINGLE_TABLE: one table, the dtype column says which" ;;
        joined) has "$W" '  PROBE meal (id | title | price): [1 | Platter | 120, 2 | Salad | 90]' "ddl JOINED: meal holds both"
                has "$W" '  PROBE platter_meal (id | dishes): [1 | 3]' "ddl JOINED: platter_meal keyed by id"; has "$W" '  PROBE salad_meal (id | dressing): [2 | lemon]' "ddl JOINED: salad_meal keyed by id" ;;
        tpc) has "$W" '  PROBE platter_meal (id | title | price | dishes): [1 | Platter | 120 | 3]' "ddl TABLE_PER_CLASS: each kind its own whole table"
             has "$W" '  PROBE salad_meal (id | title | price | dressing): [2 | Salad | 90 | lemon]' "ddl TABLE_PER_CLASS: ids 1 and 2 from one sequence" ;;
      esac; done
    has "$O" "  $(SNAME $s): the script on H2 = the script on PostgreSQL, byte for byte: yes" "ddl $(SNAME $s): H2 = PostgreSQL"; done
  nhas "$(blk ddl 'TABLE_PER_CLASS on H2 - ' '')" 'create table meal ' "ddl TABLE_PER_CLASS: no meal table"
  echo "  ddl: SINGLE_TABLE one meal table - dtype varchar(31) not null check ((dtype in ('PlatterMeal','SaladMeal'))), dishes integer (nullable) and check (dtype <> 'PlatterMeal' or (dishes is not null)) · JOINED meal + platter_meal + salad_meal keyed by id (two FK<hash>) · TABLE_PER_CLASS platter_meal + salad_meal, no meal table, one meal_seq (increment by 50); each script H2 = PostgreSQL, byte for byte; the rows on both"; }
MEX='  PROBE   Caused by org.hibernate.MappingException: Cannot use identity column key generation with <union-subclass> mapping for: probe.map.tpcid.Meal'
chk_tpcidentity() { local d W; ver tpcidentity 4 2 2
  # B first - the failure trio: exit 1, the exception and its cause, nothing built and no script
  for d in h2 pg; do W=$(blk tpcidentity "B on $(DBNAME $d) - " "$( [ $d = h2 ] && echo 'B on PostgreSQL - ' || echo "A' on H2 - ")")
    has "$W" '  PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u12starttpcid]' "tpcidentity B on $(DBNAME $d): the failure trio - PersistenceException: Unable to build Hibernate SessionFactory"
    has "$W" "$MEX" "tpcidentity B on $(DBNAME $d): the failure trio - its MappingException"
    has "$W" "  exit 1 · 'GenerationTarget encountered exception': 0" "tpcidentity B on $(DBNAME $d): the failure trio - exit 1"
    nhas "$W" 'PROBE the EntityManagerFactory was built' "tpcidentity B on $(DBNAME $d): no factory"
    has "$W" '    (none: no such file)' "tpcidentity B on $(DBNAME $d): no script written"
    nhas "$W" 'org.hibernate.SQL' "tpcidentity B on $(DBNAME $d): no SQL"; done
  for d in h2 pg; do W=$(blk tpcidentity "A' on $(DBNAME $d) - " "$( [ $d = h2 ] && echo "A' on PostgreSQL - " || echo '')")
    has "$W" '  PROBE the EntityManagerFactory was built' "tpcidentity A' on $(DBNAME $d): SEQUENCE starts"
    same "$W" "$(printf '%s\n' "$DDL_TQ" "$DDL_TP" "$DDL_TS")" "tpcidentity A' on $(DBNAME $d)"
    has "$W" "$ROWS2" "tpcidentity A' on $(DBNAME $d): two rows"; ok0 "$W" "tpcidentity A' on $(DBNAME $d)"; done
  echo "  tpcidentity: B TABLE_PER_CLASS + IDENTITY - exit 1 on H2 and on PostgreSQL: PersistenceException: Unable to build Hibernate SessionFactory <- MappingException: Cannot use identity column key generation with <union-subclass> mapping for: probe.map.tpcid.Meal; no factory, no SQL, no script · A' SEQUENCE: starts on both, meal_seq, ids 1 and 2"; }
SQL_S='select m1_0.id,m1_0.dtype,m1_0.price,m1_0.title,m1_0.dishes,m1_0.dressing from meal m1_0 order by m1_0.id'
SQL_J='select m1_0.id,case when m1_1.id is not null then 1 when m1_2.id is not null then 2 end,m1_0.price,m1_0.title,m1_1.dishes,m1_2.dressing from meal m1_0 left join platter_meal m1_1 on m1_0.id=m1_1.id left join salad_meal m1_2 on m1_0.id=m1_2.id order by m1_0.id'
SQL_TH='select m1_0.id,m1_0.clazz_,m1_0.price,m1_0.title,m1_0.dishes,m1_0.dressing from (select dishes, price, id, title, null as dressing, 1 as clazz_ from platter_meal union all select null as dishes, price, id, title, dressing, 2 as clazz_ from salad_meal) m1_0 order by m1_0.id'
SQL_TP='select m1_0.id,m1_0.clazz_,m1_0.price,m1_0.title,m1_0.dishes,m1_0.dressing from (select dishes, price, id, title, cast(null as varchar) as dressing, 1 as clazz_ from platter_meal union all select cast(null as integer) as dishes, price, id, title, dressing, 2 as clazz_ from salad_meal) m1_0 order by m1_0.id'
esql() { case $1-$2 in single-*) echo "$SQL_S" ;; joined-*) echo "$SQL_J" ;; tpc-h2) echo "$SQL_TH" ;; tpc-pg) echo "$SQL_TP" ;; esac; }
# R.184: the query's statements both ways - the SQL logger's lines between "the query" and "after the query", getPrepareStatementCount()
# - and the driver's prepareStatement beside them: 1, 1, 1
one() { local W=$1 n=$2 s
  s=$(printf '%s\n' "$W" | sed -n '/^  PROBE the query: /,/^  PROBE after the query/p' | $G -c '^  DEBUG org\.hibernate\.SQL : ' || true)
  [ "$s" = 1 ] && printf '%s\n' "$W" | $G -qF -- '  PROBE statistics: statements prepared (getPrepareStatementCount) 1 | queries executed (getQueryExecutionCount) 1 | entities loaded (getEntityLoadCount) 2 |' \
    && printf '%s\n' "$W" | $G -qF -- '  PROBE jdbc: prepareStatement 1 | executeUpdate 0 |' || die "$n: one statement - the SQL log's lines ($s) and getPrepareStatementCount() and the driver's prepareStatement, all three 1 (R.184)"; }
SQLORDER='single h2 single pg joined h2 joined pg tpc h2 tpc pg'
nexth() { printf '%s\n' $SQLORDER | paste -d' ' - - | awk -v k="$1 $2" 'f { print; exit } $0 == k { f = 1 }'; }
chk_sql() { local s d W nx; ver sql 6 3 3
  for s in single joined tpc; do for d in h2 pg; do
    nx=$(nexth $s $d); [ -z "$nx" ] || nx="$(SNAME ${nx% *}) on $(DBNAME ${nx#* }) - "
    W=$(blk sql "$(SNAME $s) on $(DBNAME $d) - " "$nx")
    has "$W" "  DEBUG org.hibernate.SQL : $(esql $s $d)" "sql $(SNAME $s) on $(DBNAME $d): the SQL Hibernate sent"
    has "$W" "  PROBE the SQL the inspector kept (1): $(esql $s $d)" "sql $(SNAME $s) on $(DBNAME $d): the inspector kept the same one statement"
    has "$W" '  PROBE after the query - it returned 2: PlatterMeal 1 | Platter | 120 | dishes 3 ; SaladMeal 2 | Salad | 90 | dressing lemon' "sql $(SNAME $s) on $(DBNAME $d): both kinds back, each its own class"
    one "$W" "sql $(SNAME $s) on $(DBNAME $d)"; ok0 "$W" "sql $(SNAME $s) on $(DBNAME $d)"; done; done
  echo "  sql: select m from Meal m - one statement every time (SQL lines = getPrepareStatementCount = prepareStatement = 1): SINGLE_TABLE from meal · JOINED two left joins + case when ... then 1 ... then 2 end · TABLE_PER_CLASS a union all of the two tables - H2 null as dressing, PostgreSQL cast(null as varchar) as dressing (S2.12: both database: lines)"; }
PGLABEL="  PROBE the plan, PostgreSQL's EXPLAIN (no ANALYZE) - its cost=, rows= and width= are planner estimates for tables never analysed, not measurements:"
H2LABEL="  PROBE H2's EXPLAIN - the query rewritten, with its index comments:"
PL_single=""; PL_joined=""; PL_tpc=""; HL_single=""; HL_joined=""; HL_tpc=""; PM_single=""; PM_joined=""; PM_tpc=""
chk_plans() { local s W H n m r k c
  for s in single joined tpc; do
    W=$(blk plans "$(SNAME $s) - the plan slide: " "$(SNAME $s) - beside it: ")
    H=$(blk plans "$(SNAME $s) - beside it: " "$( [ $s = single ] && echo 'JOINED - the plan slide: ' || { [ $s = joined ] && echo 'TABLE_PER_CLASS - the plan slide: ' || echo ''; })")
    # RE-MEASURE 13: three rounds, three fresh databases, the plan text's md5 the same in all three
    has "$W" '  PROBE round 3 of 3:' "plans $(SNAME $s): three rounds - three fresh databases (RE-MEASURE 13)"
    n=$(printf '%s\n' "$W" | $G -E '^  PROBE plan lines: ' | sort -u)
    [ "$(printf '%s\n' "$W" | $G -cE '^  PROBE plan lines: ')" = 3 ] && [ "$(printf '%s\n' "$n" | wc -l | tr -d ' ')" = 1 ] || die "plans $(SNAME $s): the plan text stable over three fresh databases - three 'plan lines' lines, one md5 (RE-MEASURE 13): $(printf '%s\n' "$n" | paste -sd';' -)"
    # S2.12: the plan slide is PostgreSQL's - three database: lines, each PostgreSQL 18.6, each a fresh database of its own name
    for r in 1 2 3; do has "$W" "$DBP"u12plan$s$r"$DRVP" "plans $(SNAME $s): the plan slide must be PostgreSQL's - the database: line of fresh database $r (u12plan$s$r)"; done
    [ "$(ndb "$W" "$DBH")" = 0 ] || die "plans $(SNAME $s): the plan slide holds an H2 database: line - it is PostgreSQL's"
    k=$(printf '%s\n' "$n" | sed -E 's/^  PROBE plan lines: ([0-9]+) \| md5 of the plan text: ([0-9a-f]{32})$/\1/'); m=$(printf '%s\n' "$n" | sed -E 's/^.*md5 of the plan text: //')
    # the costs: labelled, every round, right before the plan's lines - planner estimates, not measurements (R.201)
    [ "$(cnt "$W" "$PGLABEL")" = 3 ] || die "plans $(SNAME $s): the plan's cost numbers are on screen without their label ('planner estimates for tables never analysed, not measurements') in every round"
    c=$(printf '%s\n' "$W" | awk -v l="$PGLABEL" '$0 == l { f = 1; next } /^  PROBE \| / { if (!f) bad++; next } { f = 0 } END { print bad + 0 }')
    [ "$c" = 0 ] || die "plans $(SNAME $s): $c plan line(s) printed without the cost label right above them"
    [ "$(printf '%s\n' "$W" | sed -n "/^  PROBE round 1 of 3:/,/^  PROBE plan lines: /p" | $G -c '^  PROBE | ')" = "$k" ] || die "plans $(SNAME $s): the plan's lines counted again from the capture are not its 'plan lines' $k"
    # H2 beside it: one database: line, H2's; the query rewritten
    [ "$(ndb "$H" "$DBH")" = 1 ] && [ "$(ndb "$H" "$DBP")" = 0 ] || die "plans $(SNAME $s): H2's EXPLAIN beside the slide - one H2 database: line"
    has "$H" "$H2LABEL" "plans $(SNAME $s): H2's EXPLAIN said as the query rewritten"
    has "$H" '  PROBE | SELECT' "plans $(SNAME $s): H2 answers with the query rewritten (a SELECT, not a plan tree)"
    eval "PL_$s=$k; PM_$s=$m; HL_$s=$(printf '%s\n' "$H" | sed -n -E 's/^  PROBE plan lines: ([0-9]+) .*/\1/p')"
    ok0 "$W" "plans $(SNAME $s) PostgreSQL"; ok0 "$H" "plans $(SNAME $s) H2"; done
  has "$(blk plans 'SINGLE_TABLE - the plan slide: ' 'SINGLE_TABLE - beside it: ')" '  PROBE |   ->  Seq Scan on meal m1_0  (cost=0.00..10.70 rows=70 width=1128)' "plans SINGLE_TABLE: a Seq Scan on meal"
  has "$(blk plans 'JOINED - the plan slide: ' 'JOINED - beside it: ')" '  PROBE |   ->  Index Scan using platter_meal_pkey on platter_meal m1_1  (cost=0.15..0.51 rows=1 width=12)' "plans JOINED: an Index Scan using platter_meal_pkey"
  has "$(blk plans 'TABLE_PER_CLASS - the plan slide: ' 'TABLE_PER_CLASS - beside it: ')" '  PROBE |   ->  Append  (cost=0.00..23.15 rows=210 width=729)' "plans TABLE_PER_CLASS: an Append over the two tables"
  # the version and database: lines of the whole capture last, so a plan slide on H2 or on one database fails on its own words first
  ver plans 6 3 9
  # the numbers the video says are this capture's, never typed: README.md states them in one line, compared with the counts above
  PLS="the plan line counts: PostgreSQL $PL_single / $PL_joined / $PL_tpc · H2 $HL_single / $HL_joined / $HL_tpc"
  $G -qF -- "$PLS" README.md || die "README.md does not state the plan line counts this capture gives ('$PLS') - a typed count: $($G -oE 'the plan line counts: [^*`]*' README.md | head -1)"
  echo "  plans: PostgreSQL's EXPLAIN of the one SQL - SINGLE_TABLE $PL_single lines (Sort, Seq Scan on meal), JOINED $PL_joined (Nested Loop Left Join, Merge Left Join, Index Scan using platter_meal_pkey), TABLE_PER_CLASS $PL_tpc (Sort, Append, two Seq Scans); each md5 the same over 3 fresh databases ($PM_single · $PM_joined · $PM_tpc - RE-MEASURE 13); costs labelled planner estimates · H2's EXPLAIN beside it, the query rewritten: $HL_single / $HL_joined / $HL_tpc lines"; }
chk_mapped() { local W R1 R2; W=$(cat .r-mapped.out); ver mapped 1 1 0
  same "$W" "$(printf '%s\n' 'create table platter_meal (dishes integer not null, price integer not null, id bigint generated by default as identity, title varchar(255), primary key (id));' 'create table salad_meal (price integer not null, id bigint generated by default as identity, dressing varchar(255), title varchar(255), primary key (id));')" "mapped: two tables, each its own identity, no meal table"
  has "$W" '  PROBE persisted: PlatterMeal 1 | Platter | 120 | dishes 3 ; SaladMeal 1 | Salad | 90 | dressing lemon' "mapped: two id counters, both start at 1"
  has "$W" '  PROBE platter_meal (id | title | price | dishes): [1 | Platter | 120 | 3]' "mapped: platter_meal id 1"
  has "$W" '  PROBE salad_meal (id | title | price | dressing): [1 | Salad | 90 | lemon]' "mapped: salad_meal id 1 too"
  has "$W" "  PROBE EXCEPTION java.lang.IllegalArgumentException: org.hibernate.query.sqm.UnknownEntityException: Could not resolve root entity 'Meal'" "mapped: select m from Meal m refused"
  has "$W" "  PROBE   Caused by org.hibernate.query.sqm.UnknownEntityException: Could not resolve root entity 'Meal'" "mapped: its cause"
  R1=$(printf '%s\n' "$W" | sed -n "/^  PROBE the query: select m from Meal m order by m.id$/,/^  PROBE the query: select m from probe/p")
  nhas "$R1" 'PROBE after the query' "mapped: select m from Meal m returned nothing"
  has "$R1" '  PROBE jdbc: prepareStatement 0 | executeUpdate 0 | addBatch 0 | executeBatch 0 | executeQuery 0 | execute 0' "mapped: select m from Meal m - no statement reached the driver"
  # the same class named in full: Hibernate queries every entity that extends it - one SELECT per table, two meals with id 1
  R2=$(printf '%s\n' "$W" | sed -n '/^  PROBE the query: select m from probe.map.mapped.Meal m$/,$p')
  has "$R2" '  PROBE after the query - it returned 2: PlatterMeal 1 | Platter | 120 | dishes 3 ; SaladMeal 1 | Salad | 90 | dressing lemon' "mapped: the full class name - both kinds, each id 1"
  [ "$(printf '%s\n' "$R2" | sed -n '/^  PROBE the query: /,/^  PROBE after the query/p' | $G -c '^  DEBUG org\.hibernate\.SQL : select ' || true)" = 2 ] \
    && printf '%s\n' "$R2" | $G -qF -- '  PROBE statistics: statements prepared (getPrepareStatementCount) 2 |' && printf '%s\n' "$R2" | $G -qF -- '  PROBE jdbc: prepareStatement 2 |' \
    || die "mapped: the full class name - two statements, one per table: the SQL log's lines, getPrepareStatementCount() and prepareStatement (R.184)"
  ok0 "$R2" "mapped"
  echo "  mapped: @MappedSuperclass - platter_meal and salad_meal, each its own identity; Platter id 1 and Salad id 1; select m from Meal m refused - IllegalArgumentException <- UnknownEntityException: Could not resolve root entity 'Meal', 0 statements; the class named in full (select m from probe.map.mapped.Meal m) - 2 SELECTs, one per table, both meals back with id 1; H2"; }
# R.212 (RED #308): the harness's script for the anchor's two entities = Boot's as unit 09 captured it, by md5
chk_xcheck() { local XC l; XC=$(cat .r-xcheck.out); ver xcheck 1 1 0
  [ "$(printf '%s\n' "$XC" | sed -n '/xcheck.sql - every line:$/,/^  md5 of/p' | $G -c '^    ')" = 3 ] || die "xcheck: three lines"
  has "$XC" '  the same, byte for byte (md5): yes' "xcheck: the harness's script = Boot's (md5 $X09)"
  if [ -n "$BOOT09" ]; then printf '%s\n' "$BOOT09" | while IFS= read -r l; do has "$XC" "    $l" "xcheck: Boot's line as ../c7-unit09/.r-xcheck.out holds it"; done; fi
  echo "  xcheck: the harness's DDL for the anchor's CustomerEntity and PauseEntity, md5 $X09 = Boot's script as unit 09 captured it (R.212)"; }
EXQ="Your turn: the README stores each meal kind in its own table and Hibernate refuses to start. Give it an id it can use."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    exit 1' '    PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u12ex]' \
        '    PROBE   Caused by org.hibernate.MappingException: Cannot use identity column key generation with <union-subclass> mapping for: probe.map.ex.Meal'; do has "$ER" "$l" "exercise: the README - IDENTITY, Hibernate refuses to start"; done
    nhas "$ER" 'EntityManagerFactory was built' "exercise: the README - no factory"
    for l in '    exit 0' '    PROBE the EntityManagerFactory was built' '    PROBE platter_meal (id | title | price | dishes): [1 | Platter | 120 | 3]' '    PROBE salad_meal (id | title | price | dressing): [2 | Salad | 90 | lemon]'; do has "$ES" "$l" "exercise: the solution - SEQUENCE, it starts, two rows"; done
    nhas "$ES" 'EXCEPTION' "exercise: the solution throws nothing"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 24 ] || die "exercise: the spoken line is 24 words (R.203)"
  $G -qF '@Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;' harness/src/probe/map/ex/Meal.java || die "exercise: ex.Meal ships IDENTITY"
  $G -qF '@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)' harness/src/probe/map/ex/Meal.java || die "exercise: ex.Meal ships TABLE_PER_CLASS"
  echo "  exercise: bash and zsh alike - the README as written (TABLE_PER_CLASS + IDENTITY): exit 1, PersistenceException <- MappingException: Cannot use identity column key generation with <union-subclass> mapping for: probe.map.ex.Meal; the solution (one line: SEQUENCE): exit 0, it starts, ids 1 and 2; H2; 24 words"; }
cap ddl ddl; chk_ddl
cap tpcidentity tpcidentity; chk_tpcidentity
cap sql sql; chk_sql
cap plans plans; chk_plans
cap mapped mapped; chk_mapped
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise

# hygiene: every capture and every file this unit holds - 0 raw passwords (counted in each raw run above, and here in every file)
[ "$LOGS" -gt 0 ] || die "no harness log was read"
[ "$(find . -type f ! -path './.m2-demo/*' -print0 | xargs -0 cat 2> /dev/null | LC_ALL=C $G -aoF -- "$PGPW" | wc -l | tr -d ' ')" = 1 ] || die "the password is held raw somewhere but its own file, .harness/pg/password"
[ "$(raw "$PGPW" "$PF")" = 1 ] || die "the password's file does not hold it"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name or the probe's names (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl|x86_64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -oE '(127\.0\.0\.1:|port )[0-9]+' "$f" | $G -vxF "127.0.0.1:$PGP" > /dev/null || die "$f holds a port other than the container's $PGP"
  ! $G -qE '[0-9]+\.[0-9]+ ms' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'FK[0-9A-Za-z]{11,}|PRIMARY_KEY_[0-9]|CONSTRAINT_[0-9]' "$f" || die "$f holds a generated constraint or index name, unmasked (#320)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -qE 'https?://' || die "$f runs a command with a URL - this unit makes no request"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|String|Long|int) +(order|offset|user|value|key)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures and $LOGS harness logs; 0 raw passwords in every raw capture run and every file but its own; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, other port, generated name or stack frame in any capture; every JVM pinned; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the container removed, the anchor, the ports -------------------------------------------------------------------
docker rm -f "$PGN" > /dev/null 2>&1 || die "docker rm -f $PGN failed"; PGUP=""
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "the container $PGN is still there"
echo "  the container: removed (docker ps -a --filter name=$PGN: 0 lines)"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19910-19919 at the end; 19918 was the container's (127.0.0.1 only), 19919 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit12: every capture 3/3 and = published; every spoken number asserted; 0 raw passwords; the container removed"
