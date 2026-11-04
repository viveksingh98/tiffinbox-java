#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Columns, Enums and Converters - this unit's receipts. The course's third change to the anchor and Section 2's
# second: CustomerEntity's meal type, a String until now, becomes the anchor's own enum, MealType, stored by its name
# (@Enumerated(EnumType.STRING)); the column Database creates stays VARCHAR(10). Ten captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number and string the video says is asserted right after its capture
# by a check that can fail; the demo token and the database password are masked, and the checks count 0 raw copies of either in
# every capture and every log. Two databases: H2 (in a JVM's memory, or - for the two builds - a file under .harness/run/db that
# outlives the first JVM and is deleted after the second), and PostgreSQL 18.6 in this unit's own container (the image by
# digest, never pulled, published on 127.0.0.1:19868 only, removed at the end and by every exit).
#   enumddl   Hibernate's DDL for one enum attribute mapped six ways (ORDINAL, none, STRING, STRING with a length, STRING with a
#             column type written by hand, a converter), H2 and Postgres side by side; and NAMED_ENUM, on Postgres only
#   reorder   two builds, one database (A/B/A'): build 1 writes Ravi=VEG, Meera=NON_VEG, Priya=VEGAN into an ORDINAL, a STRING and
#             a converter table; build 2 - a copy of build 1 with MealType.class compiled again - reads them back in a JVM of its
#             own. A: build 2's enum the same; B: reordered (NON_VEG, VEG, VEGAN); A' = A. H2 then Postgres
#   added     the same two builds, build 2's enum with a fourth constant (EGG); build 2 inserts Kavya=EGG into each table
#   renamed   build 2's VEG renamed VEGETARIAN; build 2 reads, and inserts Kavya=VEGETARIAN
#   converter @Enumerated and @Convert on one attribute (the EntityManagerFactory refused); a converter with autoApply = true
#             beside an unannotated, an ORDINAL and a STRING attribute
#   anchor    the anchor's own change: after/ against before/; the shipped Database seeds its tables, then the anchor's
#             CustomerEntity reads them as MealType constants and persists Kavya (the bind logger on), H2 and Postgres; then
#             TiffinBox itself on Postgres (port 19860) adds Kavya over HTTP, and the anchor's CustomerEntity reads that database
#   seven     before/'s jar and after/'s, the seven each (a fresh JVM each, port 19861): a guard (R.190)
#   tests     TiffinBox's tests on after/ (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   xcheck    the harness's DDL for the anchor's CustomerEntity against Boot's own (after/'s jar, port 19862), cmp (R.212)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# "The previous tree" is before/, the link to ../c7-unit06/after: the anchor before this change. after/ is this unit's frozen copy
# of ../c7-tiffinbox after the change; its equality with ../c7-tiffinbox is printed at the start and the end, and a later anchor
# change makes it a note, never a stop (R.211). Both trees are COPIED under .harness/ and built there, never in place. Every run of
# TiffinBox starts in a folder under .harness/ that holds a config tree with a fake token (secrets/), listed before every start.
# The harness (harness/src, package probe.map, outside com.tiffinbox) is compiled with javac -parameters against after/'s
# extracted jar and the PostgreSQL driver into .harness/hc - build 1. A build 2 is .harness/bN: a copy of .harness/hc with
# probe/map/enums/MealType.class compiled again from MealType.java with its one line of constants changed by sed (the class
# directories differ in that one file, listed). probe.map.H builds one EntityManagerFactory per run (Jakarta Persistence 3.2's
# PersistenceConfiguration, Boot's two naming strategies, statistics on, schema generation on that run's throwaway database only)
# over a DataSource wrapped in a proxy that counts the driver calls. It runs from .harness/run and binds no port. Its JVM flags
# travel as an array, V, its arguments as an array, A (R.193).
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST
# /shutdown with the token read from its file); harness/shutdown.sh (the CORS lesson's, byte for byte) stops a JVM;
# harness/surefire.py (the testing lesson's, byte for byte) reads Surefire's reports; harness/dur7.py (Course 7's builders'
# duration pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. The image is never pulled (--pull never): a missing image stops the run before anything starts. At run time nothing
# leaves 127.0.0.1: every database is H2 in a JVM (memory or a file under .harness/run/db) or a database in the container on
# 127.0.0.1:19868. This unit reads no version file: unit 06 made the section's dated sweep (R.223).
# The database password: 24 characters this script generates at every run (never committed), held in .harness/pg/password (mode
# 0600); the harness reads that file; TiffinBox gets it in its --tiffinbox.jdbc-url (?user=sa&password=...), as BLUE settled
# (R.214). Hibernate prints that URL once per start (HHH10001005) - every TiffinBox log is masked in place after its raw copies
# are counted, and the checks count 0 raw copies in every capture and every file under this folder at the end.
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]", the password "[masked: the
# 24-character password]"; this folder "…", the folder above it "…/..", home "~", your user name "<user>"; " using Java
# <version>"; H2's generated database name "jdbc:h2:mem:<uuid>"; an identity hash "@…"; H2's generated constraint names
# "CONSTRAINT_<n>"; a harness JVM's pid "<masked>" (the two-build check compares the unmasked pids first). A JVM's log is never
# printed whole except the harness's (every line it prints, trailing spaces dropped); a TiffinBox log: the named loggers' lines,
# the exception's first line and its distinct "Caused by" lines.
# Ports (§P, 19860-19869): anchor's TiffinBox run 19860 · seven 19861 · xcheck's Boot run 19862 · the container 19868 · 19869
# never bound. 18425 (TiffinBox's default), 8080 and 35729 are checked free too, and never bound. The harness's JVMs, tests and
# the exercise bind none.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
PGN=c7-u07-pg; PGP=19868
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a harness JVM, a Maven, Surefire's fork -
# is stopped; then this run's container is removed (docker rm -f), if this run started it. After an interrupt a capture's
# unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C, and the script still
# exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""; PGUP=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.map.Main") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 curl rsync lsof unzip mvn md5 cmp git tar docker shasum /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS PGPASSWORD PGUSER; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|PG[A-Z]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c7-unit06/after ] || die "before must be the link to ../c7-unit06/after - the anchor before this change"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
# after/ is this unit's frozen tree; the anchor, ../c7-tiffinbox, equals it until a later unit changes the anchor - a note then,
# never a stop (R.211, the Course 6 form)
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3; fi; }
anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-enums-and-columns
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HS=harness/src/probe/map
HFILES='dur7.py logback.xml pom.xml shutdown.sh src surefire.py'
SFILES='probe/map/H.java probe/map/Main.java probe/map/enums/AutoCode.java probe/map/enums/BareCustomer.java probe/map/enums/BothCustomer.java probe/map/enums/ConvCustomer.java probe/map/enums/DefCustomer.java probe/map/enums/LenCustomer.java probe/map/enums/MealCode.java probe/map/enums/MealType.java probe/map/enums/NamedCustomer.java probe/map/enums/OrdCustomer.java probe/map/enums/StrCustomer.java probe/map/ex/ExCustomer.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19860 19861 19862 19863 19864 19865 19866 19867 19868 19869"
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
# list is refused, whole words, any case, in this unit's prose, its harness and (at the end) every capture
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, over README.md, exercise/, harness/src)"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
DDLO1='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create'
DDLO2='--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql'
R_DDL=$(readme "$R_RUN $DDLO1 $DDLO2")
EN='{ VEG, NON_VEG, VEGAN }'                       # MealType's one line of constants, as harness/src writes it
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_PG=$(mine "docker run -d --pull never --name $PGN -e POSTGRES_USER=sa -e POSTGRES_PASSWORD=\"\$PGPW\" -p 127.0.0.1:$PGP:5432 $IMG")
L_DB=$(mine "docker exec $PGN psql -q -v ON_ERROR_STOP=1 -U sa -d sa -c 'set client_min_messages = warning' -c 'drop database if exists t1 with (force)' -c 'create database t1'")
L_READ=$(mine "docker exec $PGN psql -At -U sa -d t1 -c \"select id || '|' || name || '|' || meal_type from customer order by id\"")
L_LIST=$(mine "docker exec $PGN psql -At -U sa -d sa -c \"select datname from pg_database where datname = 'u07enum'\"")
L_DRV=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*:.harness/drv/*\" $HS/H.java $HS/Main.java $HS/enums/*.java")
L_VSED=$(mine "sed 's/$EN/{ NON_VEG, VEG, VEGAN }/' $HS/enums/MealType.java > .harness/b2src/MealType.java")
L_VJAVAC=$(mine 'rsync -a --delete .harness/hc/ .harness/b2/ && javac -parameters -d .harness/b2 .harness/b2src/MealType.java')
L_H=$(mine "java $JL -Dlogback.configurationFile=../../harness/logback.xml \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*:../drv/*\" probe.map.Main \"\${A[@]}\"")
L_TPG=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../drv/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 \"\${V[@]}\"")
L_KAVYA=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Kavya\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
# The derivations, each asserted: one change each, and nothing else
P_='java -cp "'; Q_="java $JL -cp \""; T_="$R_CP"; T_=${T_/"$P_"/$Q_}; P_='lib/*" com.'; Q_='lib/*:../drv/*" com.'; T_=${T_/"$P_"/$Q_}
[ "$T_ \"\${V[@]}\"" = "$L_TPG" ] || die "the Postgres run line must be the anchor's extracted-jar line with $JL, ../drv/* (the driver) last on the class path and the options array after it, and nothing else"
P_='"name":"Asha"'; Q_='"name":"Kavya"'; [ "${R_POST/"$P_"/$Q_}" = "$L_KAVYA" ] || die "Kavya's POST must be the README's POST with the name Kavya, and nothing else"
[ "${R_DDL#"$R_RUN "}" = "$DDLO1 $DDLO2" ] || die "the DDL line must be the anchor's run line with the two schema-generation options, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'LINE': the line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# vsed N 'CONSTANTS' / vjavac N: README.md's two variant lines with build 2 made build N and the constants made CONSTANTS
vsed() { local l=$L_VSED P_="{ NON_VEG, VEG, VEGAN }/'" Q_="$2/'"; l=${l/"$P_"/$Q_}; printf '%s\n' "${l//b2src/b$1src}"; }
vjavac() { printf '%s\n' "${L_VJAVAC//b2/b$1}"; }
[ "$(exe "$(at .harness/x 19861 "$R_RUN")")" = "cd .harness/x && exec java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19861" ] && [ "$(vsed 2 '{ NON_VEG, VEG, VEGAN }')" = "$L_VSED" ] && [ "$(vjavac 2)" = "$L_VJAVAC" ] \
  && [ "$(vsed 3 '{ VEG, NON_VEG, VEGAN, EGG }')" = "sed 's/$EN/{ VEG, NON_VEG, VEGAN, EGG }/' $HS/enums/MealType.java > .harness/b3src/MealType.java" ] && [ "$(vjavac 4)" = 'rsync -a --delete .harness/hc/ .harness/b4/ && javac -parameters -d .harness/b4 .harness/b4src/MealType.java' ] || die "at()/vsed()/vjavac(): the run lines are not README.md's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- the password: generated now, kept in a file only this user reads, never printed -------------------------------------
PGPW=$(head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 24)   # bounded: a tr reading /dev/urandom itself never ends where SIGPIPE is ignored
[ ${#PGPW} = 24 ] || die "the generated password must be 24 characters"
PF=.harness/pg/password; (umask 077 && printf '%s\n' "$PGPW" > "$PF"); chmod 700 .harness/pg

# ---- build: before the captures - before/ and after/, each copied and built with the README's package line offline (each runs
# ---- its tree's tests); each jar extracted (the anchor's line); the driver resolved by Maven; the harness compiled --------
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
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy before .harness/before; copy after .harness/after
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
for t in before after; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
mkdir -p .harness/drvpom; cp harness/pom.xml .harness/drvpom/pom.xml
mbuild "cd .harness/drvpom && $L_DRV" .harness/build-drv.log ".harness/drvpom (harness/pom.xml: the PostgreSQL driver at the version Boot 4.1.2 manages)"
tr ':' '\n' < .harness/drvpom/classpath.txt > .harness/drv.list
while IFS= read -r j || [ -n "$j" ]; do [ -f "$j" ] || die "the driver's class path names a file that is not there: $j"; cp "$j" .harness/drv/; done < .harness/drv.list
[ "$(ls .harness/drv | paste -sd' ' -)" = 'checker-qual-3.55.1.jar postgresql-42.7.14.jar' ] || die "the driver's class path is not postgresql-42.7.14.jar and checker-qual-3.55.1.jar: $(ls .harness/drv | paste -sd' ' -)"
PGJ=.harness/drv/postgresql-42.7.14.jar
[ "$(shasum -a 1 "$PGJ" | awk '{ print $1 }')" = "$(head -c 40 "$M2/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar.sha1")" ] || die "postgresql-42.7.14.jar does not match its .sha1"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the builds - README.md, The repository"; done
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/map/ex ] || die "the exercise's class was compiled into the harness - it is the exercise's own"
echo "  extracted both jars ($(ls .harness/before/$XD/lib | wc -l | tr -d ' ') and $(ls .harness/after/$XD/lib | wc -l | tr -d ' ') libraries), resolved the driver ($(ls .harness/drv | paste -sd' ' -)) and compiled the harness into .harness/hc"

# ---- the container: started once, before the captures; every capture makes fresh databases in it --------------------------
pgmask() { awk -v p="$PGPW" '{ gsub(p, "[masked: the 24-character password]"); print }'; }
echo "  \$ $(printf '%s\n' "${L_PG/\"\$PGPW\"/$PGPW}" | pgmask)" >&3
PGUP=1; (eval "$L_PG") > .harness/pg/cid 2>&1 < /dev/null || die "docker run failed: $(tail -2 .harness/pg/cid | pgmask)"
i=0; while [ $i -lt 120 ]; do docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 && break; sleep 0.5; i=$((i + 1)); done
docker exec "$PGN" pg_isready -q -h 127.0.0.1 -U sa > /dev/null 2>&1 || die "Postgres never became ready in the container"
[ "$(docker port "$PGN")" = "5432/tcp -> 127.0.0.1:$PGP" ] || die "the container is not published on 127.0.0.1:$PGP alone: $(docker port "$PGN" | paste -sd';' -)"
echo "  the container $PGN: up, published on $(docker port "$PGN") only" >&3

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
pv() { echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))" | pgmask; }
start() { sec "$(dir "$1")"; [ -z "${2:-}" ] || pv; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out | pgmask >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19869 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19869 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out | pgmask >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; }
# a TiffinBox log, kept: the token counted (0), the password counted (Hibernate's URL line), then the log masked in place
keep() { local t w; t=$(raw "$TOKEN" .harness/run.out); w=$(raw "$PGPW" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out
  [ "$t" = 0 ] || die "a log held the demo token ($t)"
  pgmask < .harness/run.out > "$1"; rm -f .harness/run.out
  echo "  its log: the demo token 0 times · the password, raw: $w ($( [ "$w" = 0 ] && echo 'none' || echo "Hibernate's Database JDBC URL line") - masked in place)"; }
LASTE=""
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# fails PORT: a start that must not get up - waited for (bounded, 120 s), its exit code, nothing ever listening on PORT
fails() { local i=0 e=0 l=""
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do [ -n "$l" ] || l=$(addrs "$pid"); sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the start on $1 was still running after 120 s"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  echo "  exit $e · it listened on: ${l:-nothing} · listening on $1 now: $(listeners "$1")"; }
lvl() { $G -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; }
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; }
mask() { awk -v t="$TOKEN" -v w="$PGPW" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); W = lit(w); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(W, "[masked: the 24-character password]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/CONSTRAINT_[0-9A-F]+/, "CONSTRAINT_<n>"); gsub(/this JVM'"'"'s pid: [0-9]+/, "this JVM'"'"'s pid: <masked>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" "Database JDBC URL [jdbc:postgresql://127.0.0.1:$PGP/b1?user=sa&password=$PGPW]" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 32-character token]' "Database JDBC URL [jdbc:postgresql://127.0.0.1:$PGP/b1?user=sa&password=[masked: the 24-character password]]")" ] || die "mask: the planted JDK version, generated database name, token and password must be masked"
rm -f .harness/p1                                    # it held the password: gone before any capture
# tview FILE: a TiffinBox log, in order - the named loggers' lines (level, logger: message), Hibernate's "Database JDBC URL" and
# "Database version" lines under its HHH10001005, and for SpringApplication's ERROR line the exception's first line and each
# distinct "Caused by:" line (at most four); frames never; then the counts
TPAT='org\.hibernate\.orm\.core|org\.hibernate\.orm\.connections\.pooling|com\.zaxxer\.hikari\.pool\.HikariPool|org\.hibernate\.SQL|TiffinBoxServer'
tview() { awk -v pat="$TPAT" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); gsub(/ defined in URL \[[^]]*\]/, " defined in […]", x); gsub(/ defined in file \[[^]]*\]/, " defined in […]", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { ex = 0; dbi = 0
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ /SpringApplication$/ && $2 == "ERROR") { print "    " $2 " " lg ": " cut(m); ex = 1; nc = 0; delete seen; next }
    if (lg ~ pat) { print "    " $2 " " lg ": " cut(m); if (m ~ /^HHH10001005/) dbi = 1 }
    next }
  dbi && /^\tDatabase (JDBC URL|version)/ { sub(/^\t/, ""); print "      " cut($0); next }
  ex == 1 && NF > 0 && !/^\tat / && !/^\t\.\.\. / && !/^Caused by: / { print "      " cut($0); ex = 2; next }
  ex && /^Caused by: / { c = cut($0); if (!(c in seen) && nc < 4) { seen[c] = 1; nc++; print "      " c } }' "$1"
  echo "  its log's lines - org.hibernate.SQL: $($G -cE ' org\.hibernate\.SQL +: ' "$1" || true) · of them 'insert into': $($G -cE ' org\.hibernate\.SQL +: insert into ' "$1" || true) · WARN: $(lvl WARN "$1") · ERROR: $(lvl ERROR "$1") · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' "$1" || true)"; }
# hrun [TREE [BUILD]]: the harness line (V, A set by the caller), run from .harness/run, the tree's extracted jar on the class path
# (after/ unless named) and the build's classes (.harness/hc - build 1 - unless named); it exits by itself (bounded: 240 s); its
# exit code in HE, the pid it started in HP; its log .harness/h.log
HE=""; HP=""
hrun() { local t=${1:-after} b=${2:-hc} c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "$L_H"); P_='../after/'; Q_="../$t/"; [ "$t" = after ] || c=${c/"$P_"/$Q_}
  P_='"../hc:'; Q_="\"../$b:"; [ "$b" = hc ] || c=${c/"$P_"/$Q_}
  pv; echo "\$ A=($(printf '%s ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!; HP=$pid
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 240 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$(raw "$TOKEN" .harness/h.log)" = 0 ] && [ "$(raw "$PGPW" .harness/h.log)" = 0 ] || die "a harness log held the token or the password"; }
# hview: the harness's whole log (PROBE lines, the SQL, bind and batch loggers' lines), trailing spaces dropped; then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
HV=(-Dpg.port=$PGP -Dpg.passfile=../pg/password)       # every harness run's two: where the container is, and the password's file
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; raw "$PGPW" .harness/cap.raw >> ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $($G -c '^@@ ' .harness/code.diff || true) · lines out: $($G -c '^-' .harness/code.diff || true) · in: $($G -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }


# ---- enumddl: one attribute, six mappings, two databases --------------------------------------------------------------
DDLH=(enums.OrdCustomer enums.BareCustomer enums.StrCustomer enums.LenCustomer enums.DefCustomer enums.ConvCustomer)
enumddl() { local d n
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    rm -f .harness/run/ddl-$d.sql
    if [ $d = h2 ]; then echo "on $n - Hibernate's DDL for six mappings of one MealType attribute, a script written and run on the throwaway database:"; A=(ddl ddl-$d.sql "${DDLH[@]}")
    else echo "on $n - the same six, and NamedCustomer (STRING with @JdbcTypeCode(SqlTypes.NAMED_ENUM), Postgres only):"; A=(ddl ddl-$d.sql "${DDLH[@]}" enums.NamedCustomer); fi
    V=("${HV[@]}" -Ddb=$d -Dsql=WARN); hrun; hview
    echo "  the script it wrote, .harness/run/ddl-$d.sql - every line:"; sed 's/^/    /' .harness/run/ddl-$d.sql; done; }

# ---- the two builds: build 1 is .harness/hc; a build 2 is a copy of it with MealType.class compiled again ------------------
EN='{ VEG, NON_VEG, VEGAN }'
# variant N 'CONSTANTS': .harness/bN = .harness/hc with probe/map/enums/MealType.class compiled from MealType.java whose one line
# of constants says CONSTANTS - the two lines printed and run, then the class directories' difference and both md5s
variant() { local s c l
  s=$(vsed "$1" "$2"); c=$(vjavac "$1")
  rm -rf ".harness/b$1" ".harness/b$1src"; mkdir -p ".harness/b$1src"
  echo "\$ $s"; (eval "$s") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  its constants: $(sed -n 's/^public enum MealType \(.*\)$/\1/p' ".harness/b$1src/MealType.java")"
  l=$(diff -rq .harness/hc ".harness/b$1" | sed -E 's#^Files \.harness/hc/([^ ]+) and .*#\1#' | paste -sd' ' -)
  echo "  build 1 (.harness/hc) against build 2 (.harness/b$1), diff -rq - the files that differ: ${l:-none} ($(diff -rq .harness/hc ".harness/b$1" | wc -l | tr -d ' '))"
  echo "  md5 of probe/map/enums/MealType.class - build 1: $(md5 -q .harness/hc/probe/map/enums/MealType.class) · build 2: $(md5 -q ".harness/b$1/probe/map/enums/MealType.class")"; }
jpid() { sed -n "s/^PROBE this JVM's pid: \([0-9]*\)$/\1/p" .harness/h.log | head -1; }
ENT=(enums.OrdCustomer enums.StrCustomer enums.ConvCustomer)
# twobuild DB N INSERT: build 1 (.harness/hc) writes Ravi, Meera and Priya into each table, the schema generated, on a database
# that outlives its JVM (H2: the file .harness/run/db/enum.mv.db; Postgres: the database u07enum, kept); the database listed;
# build 2 (.harness/bN), a JVM of its own, schema generation off, reads them back and inserts Kavya with INSERT ("-": none);
# then the two-build check (R.218): two pids, different; the database there between them; build 2's first SQL a SELECT
twobuild() { local d=$1 b=b$2 p1 p2 h1 h2 l f w
  if [ $d = h2 ]; then w=enum.mv.db; else w=u07enum; fi
  rm -rf .harness/run/db
  echo "  build 1 (.harness/hc):"
  if [ $d = h2 ]; then V=("${HV[@]}" -Ddb=h2 -Dh2file=./db/enum); else V=("${HV[@]}" -Ddb=pg); fi
  A=(write "${ENT[@]}"); hrun after hc; p1=$(jpid); h1=$HP; hview
  echo "  the database, between the two JVMs:"
  if [ $d = h2 ]; then echo "\$ ls .harness/run/db"; l=$(ls .harness/run/db 2> /dev/null | paste -sd' ' -)
  else echo "\$ $L_LIST"; l=$( (eval "$L_LIST") 2> /dev/null < /dev/null | paste -sd' ' -); fi
  echo "  ${l:-nothing}"
  echo "  build 2 (.harness/$b), a JVM of its own:"
  if [ $d = h2 ]; then V=("${HV[@]}" -Ddb=h2 -Dh2file=./db/enum); else V=("${HV[@]}" -Ddb=pg -Dfresh=false); fi
  A=(read "$3" "${ENT[@]}"); hrun after "$b"; p2=$(jpid); h2=$HP; hview
  f=$($G -m1 -E ' org\.hibernate\.SQL : ' .harness/h.log | sed -E 's/^.* org\.hibernate\.SQL : ([a-z]+).*$/\1/' || true)
  echo "  the two-build check: two pids, different: $( [ -n "$p1" ] && [ -n "$p2" ] && [ "$p1" != "$p2" ] && echo yes || echo no) · each the pid this script started: $( [ -n "$p1" ] && [ "$p1" = "$h1" ] && [ "$p2" = "$h2" ] && echo yes || echo no) · the database there between them ($w): $( [ "$l" = "$w" ] && echo yes || echo no) · build 2's first SQL: ${f:-none} - a SELECT: $( [ "$f" = select ] && echo yes || echo no)"
  if [ $d = h2 ]; then rm -rf .harness/run/db; echo "  \$ rm -rf .harness/run/db · a database file left under .harness/run: $(find .harness/run -name '*.db' | wc -l | tr -d ' ')"; fi; }
reorder() { local d n
  echo "the builds - build 1 is .harness/hc, the harness as compiled; a build 2 is a copy of it with MealType.class compiled again from one changed line:"
  echo "build 2 for A and A' (the same constants, the same order):"; variant 1 "$EN"
  echo "build 2 for B (reordered - an alphabetical tidy-up):"; variant 2 '{ NON_VEG, VEG, VEGAN }'
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - A: build 2's enum the same:"; twobuild $d 1 -
    echo "on $n - B: build 2's enum reordered:"; twobuild $d 2 -
    echo "on $n - A': A again:"; twobuild $d 1 -; done; }
added() { local d n
  echo "build 2 (a fourth constant, EGG, at the end):"; variant 3 '{ VEG, NON_VEG, VEGAN, EGG }'
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - build 1 writes, build 2 reads and inserts Kavya=EGG:"; twobuild $d 3 EGG; done; }
renamed() { local d n
  echo "build 2 (VEG renamed VEGETARIAN, in its place):"; variant 4 '{ VEGETARIAN, NON_VEG, VEGAN }'
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - build 1 writes, build 2 reads and inserts Kavya=VEGETARIAN:"; twobuild $d 4 VEGETARIAN; done; }

# ---- converter: two mappings on one attribute; a converter that applies itself ---------------------------------------------
converter() { local d n e
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - @Enumerated(EnumType.STRING) and @Convert(converter = MealCode.class) on one attribute (probe.map.enums.BothCustomer):"
    V=("${HV[@]}" -Ddb=$d); A=(both); hrun; hview
    e=$($G -m1 '^PROBE EXCEPTION ' .harness/h.log || true)
    echo "  the trio: exit $HE · ${e:-no exception printed} · the EntityManagerFactory built: $($G -q 'the EntityManagerFactory was built' .harness/h.log && echo yes || echo no)"
    echo "on $n - AutoCode (@Converter(autoApply = true)) beside three attributes - no annotation, ORDINAL, STRING - a script written and run:"
    rm -f .harness/run/auto-$d.sql
    V=("${HV[@]}" -Ddb=$d -Dsql=WARN); A=(auto auto-$d.sql); hrun; hview
    echo "  the script it wrote, .harness/run/auto-$d.sql - every line:"; sed 's/^/    /' .harness/run/auto-$d.sql; done; }

# ---- anchor: the change, and the anchor's CustomerEntity on the shipped Database's tables -----------------------------------
tpg() { V=("--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:$PGP/$3?user=sa&password=$PGPW" --logging.level.org.hibernate.SQL=debug)
  start "$(at .harness/$1 "$2" "$L_TPG")" v; }
anchor() { local a=tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java d n c
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#' | sort
  echo "CustomerEntity.java:"; cdiff "before/$a" "after/$a"
  echo "the column, as the shipped Database creates it - after/'s Database.java, grep -n meal_type:"
  (cd after && $G -n meal_type tiffinbox-core/src/main/java/com/tiffinbox/Database.java) | sed 's/^ */  /' | sed -E 's/^  ([0-9]+):[[:space:]]*/  \1: /'
  for d in h2 pg; do n=H2; [ $d = h2 ] || n=PostgreSQL
    echo "on $n - the shipped Database (createAndSeed) seeds this run's database; the anchor's CustomerEntity (after/'s jar) reads it and persists Kavya, the bind logger on:"
    rm -f .harness/run/anchor-$d.sql
    V=("${HV[@]}" -Ddb=$d -Dbind=TRACE); A=(anchor anchor-$d.sql); hrun; hview
    echo "  Hibernate's DDL for CustomerEntity, .harness/run/anchor-$d.sql (a file, never run) - every line:"; sed 's/^/    /' .harness/run/anchor-$d.sql; done
  echo "on PostgreSQL - TiffinBox itself (after/'s jar) on a fresh database t1, port 19860, Kavya added over HTTP; then the anchor's CustomerEntity reads t1:"
  echo "\$ $L_DB"; (eval "$L_DB") 2>&1 < /dev/null | sed 's/^/  /'
  tpg after 19860 t1; up 19860; ready 19860
  c=$(url "$L_KAVYA" 19860); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $L_READ"; (eval "$L_READ") 2>&1 < /dev/null | paste -sd' ' - | sed 's/^/  /'
  stop 19860 .harness/after; keep .harness/anchor-tb.log; tview .harness/anchor-tb.log
  V=("${HV[@]}" -Ddb=pg -Dfresh=false -Dpg.db=t1); A=(anchorread); hrun; hview; }

# ---- seven: the H2 regression - both trees' jars (a guard, R.190) -----------------------------------------------------------
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a log held the demo token ($t)"; echo "  its log: the demo token 0 times"; }
jlog() { local h v
  h=$($G -m1 -oE 'HikariPool-1 - Added connection conn0: url=[^ ]+' "$1" || true); v=$($G -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' "$1" || true)
  echo "  its pool: ${h:-no Hikari line} · Hibernate: ${v:-no Hibernate line} · WARN lines: $(lvl WARN "$1") · ERROR lines: $(lvl ERROR "$1")"; }
seven7() { local t
  for t in before after; do
    echo "the seven - $t/'s jar, port 19861, a fresh JVM:"
    start "$(at .harness/$t 19861 "$R_RUN")"; up 19861; ready 19861
    echo "\$ \$CURLSET 19861 .harness/$t/$TF"
    "$CURLSET" 19861 ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    $G '^POST ' .harness/seven-$t.txt | sed 's/^/  /' || echo "  (no POST line)"
    gone 19861
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"; jlog .harness/run.out; logtok; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }

# ---- tests: TiffinBox's tests, read from Surefire's reports -----------------------------------------------------------------------
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: $($G -c 'Initialized JPA EntityManagerFactory' .harness/tests.log || true) · Hibernate's SQL lines: $($G -c ' org\.hibernate\.SQL  *: ' .harness/tests.log || true)"
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) (the tests' own kitchen-on-fire cases) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }

# ---- xcheck: the harness's DDL for the anchor's CustomerEntity against Boot's --------------------------------------------------
xcheck() {
  echo "Boot's DDL - after/'s jar with the anchor README's DDL line (a file, never run), port 19862:"
  rm -f .harness/after/hibernate-ddl.sql
  start "$(at .harness/after 19862 "$R_DDL")"; up 19862; ready 19862; stop 19862 .harness/after; logtok
  echo "  .harness/after/hibernate-ddl.sql - every line:"; sed 's/^/    /' .harness/after/hibernate-ddl.sql
  echo "the harness's DDL - its own EntityManagerFactory over com.tiffinbox.CustomerEntity (from after/'s jar), a file, never run:"
  rm -f .harness/run/xcheck.sql
  V=("${HV[@]}" -Ddb=h2); A=(xcheck xcheck.sql); hrun; hview
  echo "  .harness/run/xcheck.sql - every line:"; sed 's/^/    /' .harness/run/xcheck.sql
  echo "\$ cmp .harness/after/hibernate-ddl.sql .harness/run/xcheck.sql"
  echo "  the same, byte for byte: $(cmp -s .harness/after/hibernate-ddl.sql .harness/run/xcheck.sql && echo yes || echo no) · md5 $(md5 -q .harness/run/xcheck.sql)"; }


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
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the class it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
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
x() { $G -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
# "ORDINAL is a number with a range check on both; STRING is H2's own enum type (its names sorted) and Postgres's varchar with a
# check (declaration order); the length ignored by H2's enum; a column type by hand drops H2's check and keeps Postgres's; the
# converter's codes in the check; NAMED_ENUM a type of Postgres's own" (R.217: both captures, two database: lines)
chk_enumddl() { local EH EP
  EH=$(blk enumddl "on H2 -" "on PostgreSQL -"); EP=$(blk enumddl "on PostgreSQL -" "")
  printf '%s\n' "$EH" | $G -q '^  PROBE database: H2 2\.5\.250 ' && printf '%s\n' "$EP" | $G -q '^  PROBE database: PostgreSQL 18\.6 ' || die "enumddl: the two database: lines, H2 and PostgreSQL (R.217)"
  for l in "    create table ord_customer (meal_type tinyint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table bare_customer (meal_type tinyint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table str_customer (id bigint generated by default as identity, name varchar(255), meal_type enum ('NON_VEG','VEG','VEGAN'), primary key (id));" \
      "    create table len_customer (id bigint generated by default as identity, name varchar(255), meal_type enum ('NON_VEG','VEG','VEGAN'), primary key (id));" \
      "    create table def_customer (id bigint generated by default as identity, name varchar(255), meal_type varchar(10), primary key (id));" \
      "    create table conv_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('non-veg','veg','vegan'))), name varchar(255), primary key (id));"; do has "$EH" "$l" "enumddl H2"; done
  for l in "    create table ord_customer (meal_type smallint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table bare_customer (meal_type smallint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table str_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('VEG','NON_VEG','VEGAN'))), name varchar(255), primary key (id));" \
      "    create table len_customer (id bigint generated by default as identity, meal_type varchar(10) check ((meal_type in ('VEG','NON_VEG','VEGAN'))), name varchar(255), primary key (id));" \
      "    create table def_customer (id bigint generated by default as identity, meal_type varchar(10) check ((meal_type in ('VEG','NON_VEG','VEGAN'))), name varchar(255), primary key (id));" \
      "    create table conv_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('non-veg','veg','vegan'))), name varchar(255), primary key (id));" \
      "    create type MealType as enum ('NON_VEG','VEG','VEGAN');" "    create table named_customer (id bigint generated by default as identity, name varchar(255), meal_type MealType, primary key (id));"; do has "$EP" "$l" "enumddl PostgreSQL"; done
  [ "$(printf '%s\n' "$EH" | $G -c '^    create ')" = 6 ] && [ "$(printf '%s\n' "$EP" | $G -c '^    create table ')" = 7 ] || die "enumddl: six tables on H2, seven on Postgres"
  [ "$(cnt "$(cat .r-enumddl.out)" "$VERL")" = 2 ] && [ "$(cnt "$(cat .r-enumddl.out)" "  exit 0 · 'GenerationTarget encountered exception': 0")" = 2 ] || die "enumddl: the version line and exit 0 in both runs (R.222, R.213)"
  echo "  enumddl: ORDINAL and no annotation - H2 tinyint, PG smallint, check between 0 and 2; STRING - H2 enum ('NON_VEG','VEG','VEGAN') (sorted, length 10 ignored), PG varchar + check in declaration order; columnDefinition varchar(10) - H2 no check, PG the check; the converter's codes in the check on both; NAMED_ENUM - create type MealType (PG)"; }
# the two-build check (R.218), on every pair of JVMs in a capture: two pids, different, each the one this script started; the
# database there between them; build 2's first SQL a SELECT; and no database file left
TWOB='  the two-build check: two pids, different: yes · each the pid this script started: yes · the database there between them'
twob() { [ "$(cnt "$2" "$TWOB (enum.mv.db): yes · build 2's first SQL: select - a SELECT: yes")" = "$3" ] && [ "$(cnt "$2" "$TWOB (u07enum): yes · build 2's first SQL: select - a SELECT: yes")" = "$3" ] \
    && [ "$(cnt "$2" '  $ rm -rf .harness/run/db · a database file left under .harness/run: 0')" = "$3" ] || die "$1: the two-build check - two JVMs, the database between them, build 2's first SQL a SELECT ($3 per database; R.218)"; }
# one build pair's lines: rd BLOCK TABLE -> "raw | read by Hibernate" of build 2
b2() { printf '%s\n' "$1" | sed -n '/^  build 2 (/,$p'; }
# "Ravi wrote VEG; after an alphabetical tidy-up of the enum, Hibernate reads him back as NON_VEG, no error, both databases; the
# raw column still 0, 1, 2; by name, or through the converter, he is still VEG" - A/B/A' (R.1), two builds each (R.218)
chk_reorder() { local d R A B A2 n
  R=$(cat .r-reorder.out); twob reorder "$R" 3
  has "$R" '  build 1 (.harness/hc) against build 2 (.harness/b1), diff -rq - the files that differ: none (0)' "reorder A: build 2 = build 1, class for class"
  has "$R" '  build 1 (.harness/hc) against build 2 (.harness/b2), diff -rq - the files that differ: probe/map/enums/MealType.class (1)' "reorder B: build 2 differs from build 1 in MealType.class alone"
  has "$R" '  its constants: { NON_VEG, VEG, VEGAN }' "reorder B: the reordered constants"
  md5s() { printf '%s\n' "$R" | $G '^  md5 of probe/map/enums/MealType.class' | sed -n "$1p" | sed -E 's/^.* - build 1: ([0-9a-f]{32}) · build 2: ([0-9a-f]{32})$/\1 \2/' | awk 'NF == 2 { print ($1 == $2) ? "same" : "differ" }'; }
  [ "$(md5s 1)" = same ] || die "reorder A: MealType.class's md5 the same in both builds"
  [ "$(md5s 2)" = differ ] || die "reorder B: MealType.class's md5 differs between the builds"
  for d in H2 PostgreSQL; do
    A=$(blk reorder "on $d - A:" "on $d - B:"); B=$(blk reorder "on $d - B:" "on $d - A':"); A2=$(blk reorder "on $d - A':" "on ")
    for n in "$A" "$A2"; do for l in '  PROBE MealType in this build: [VEG, NON_VEG, VEGAN] - ordinals [0, 1, 2]' '  PROBE ord_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' \
        '  PROBE str_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' '  PROBE conv_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]'; do has "$(b2 "$n")" "$l" "reorder $d A/A'"; done; done
    [ "$(printf '%s\n' "$A" | $G -v '^\$ ')" = "$(printf '%s\n' "$A2" | $G -v '^\$ ')" ] || die "reorder $d: A' = A, line for line"
    for l in '  PROBE ord_customer read by Hibernate: [Ravi=NON_VEG, Meera=VEG, Priya=VEGAN]' '  PROBE MealType in this build: [NON_VEG, VEG, VEGAN] - ordinals [0, 1, 2]' \
        '  PROBE ord_customer raw, read by a second connection: [Ravi=0, Meera=1, Priya=2]' '  PROBE str_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' \
        '  PROBE conv_customer raw, read by a second connection: [Ravi=veg, Meera=non-veg, Priya=vegan]' '  PROBE conv_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' \
        "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$(b2 "$B")" "$l" "reorder $d B"; done
    ! printf '%s\n' "$(b2 "$B")" | $G -qE '^  (WARN|ERROR) |EXCEPTION' || die "reorder $d B: no WARN, no error, no exception - the corruption is quiet"
    printf '%s\n' "$B" | $G -q "^  PROBE database: $( [ $d = H2 ] && echo 'H2 2\.5\.250' || echo 'PostgreSQL 18\.6') " || die "reorder $d: its database: line"; done
  [ "$(cnt "$R" "$VERL")" = 12 ] || die "reorder: the version line in each of the twelve JVMs (R.222)"
  echo "  reorder: A/A' (build 2 = build 1, 0 files differ) Ravi=VEG in all three tables; B (MealType.class alone differs) ORDINAL reads Ravi=NON_VEG, Meera=VEG, raw still 0, 1, 2, no WARN, no exception; STRING and the converter read Ravi=VEG - H2 and PostgreSQL; two JVMs per pair, the database between them, build 2's first SQL a SELECT"; }
# "an added constant: the three rows read as written; Kavya=EGG refused on insert in all three tables - by the check Hibernate
# wrote (ORDINAL: H2 CONSTRAINT_<n>, 23513 / PG ord_customer_meal_type_check, 23514), by H2's enum type (STRING, 22030) or PG's check"
chk_added() { local d A W
  A=$(cat .r-added.out); twob added "$A" 1
  has "$A" '  build 1 (.harness/hc) against build 2 (.harness/b3), diff -rq - the files that differ: probe/map/enums/MealType.class (1)' "added: MealType.class alone differs"
  for d in H2 PostgreSQL; do W=$(b2 "$(blk added "on $d -" "on ")")
    for l in '  PROBE MealType in this build: [VEG, NON_VEG, VEGAN, EGG] - ordinals [0, 1, 2, 3]' '  PROBE ord_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' \
        '  PROBE str_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' '  PROBE conv_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' \
        '  PROBE ord_customer insert Kavya=EGG: refused' '  PROBE str_customer insert Kavya=EGG: refused' '  PROBE conv_customer insert Kavya=EGG: refused'; do has "$W" "$l" "added $d"; done
    nhas "$W" 'insert Kavya=EGG: done' "added $d: no insert of EGG got through"; done
  W=$(b2 "$(blk added "on H2 -" "on ")")
  for l in '  WARN  org.hibernate.orm.jdbc.error : HHH000247: ErrorCode: 23513, SQLState: 23513' '  WARN  org.hibernate.orm.jdbc.error : Check constraint violation: "CONSTRAINT_<n>: "; SQL statement:' \
      '  insert into ord_customer (meal_type,name,id) values (?,?,default) [23513-250]' '  WARN  org.hibernate.orm.jdbc.error : HHH000247: ErrorCode: 22030, SQLState: 22030' \
      "  WARN  org.hibernate.orm.jdbc.error : Value not permitted for column \"('NON_VEG', 'VEG', 'VEGAN')\": \"EGG\"; SQL statement:" \
      "  PROBE EXCEPTION org.hibernate.exception.DataException: could not execute statement [Value not permitted for column \"('NON_VEG', 'VEG', 'VEGAN')\": \"EGG\"; SQL statement:"; do has "$W" "$l" "added H2: the refusals"; done
  W=$(b2 "$(blk added "on PostgreSQL -" "")")
  for t in ord str conv; do has "$W" "  WARN  org.hibernate.orm.jdbc.error : ERROR: new row for relation \"${t}_customer\" violates check constraint \"${t}_customer_meal_type_check\"" "added PostgreSQL: $t's check"; done
  [ "$(cnt "$W" '  WARN  org.hibernate.orm.jdbc.error : HHH000247: ErrorCode: 0, SQLState: 23514')" = 3 ] || die "added PostgreSQL: 23514 three times"
  for l in '    Detail: Failing row contains (3, 4, Kavya).' '    Detail: Failing row contains (4, EGG, Kavya).' '    Detail: Failing row contains (4, ?EGG, Kavya).'; do has "$W" "$l" "added PostgreSQL: the failing rows"; done
  echo "  added: EGG appended - the three rows read as written; Kavya=EGG refused in all three tables: H2 ORDINAL CONSTRAINT_<n> 23513, STRING 'Value not permitted' 22030 (H2's enum type), converter 23513; PG each table's <table>_meal_type_check, 23514 - the checks Hibernate's DDL wrote"; }
# "a renamed constant: ORDINAL reads Ravi=VEGETARIAN quietly; STRING and the converter fail on read - No enum constant ...VEG -
# and refuse Kavya=VEGETARIAN; ORDINAL takes her (0)"
chk_renamed() { local d A W
  A=$(cat .r-renamed.out); twob renamed "$A" 1
  has "$A" '  build 1 (.harness/hc) against build 2 (.harness/b4), diff -rq - the files that differ: probe/map/enums/MealType.class (1)' "renamed: MealType.class alone differs"
  for d in H2 PostgreSQL; do W=$(b2 "$(blk renamed "on $d -" "on ")")
    for l in '  PROBE MealType in this build: [VEGETARIAN, NON_VEG, VEGAN] - ordinals [0, 1, 2]' '  PROBE ord_customer read by Hibernate: [Ravi=VEGETARIAN, Meera=NON_VEG, Priya=VEGAN]' \
        '  PROBE ord_customer insert Kavya=VEGETARIAN: done - raw, read by a second connection: [Kavya=0]' \
        '  PROBE str_customer read by Hibernate: refused' '  PROBE EXCEPTION java.lang.IllegalArgumentException: No enum constant probe.map.enums.MealType.VEG' \
        '  PROBE conv_customer read by Hibernate: refused' '  PROBE EXCEPTION jakarta.persistence.PersistenceException: Error attempting to apply AttributeConverter' \
        '  PROBE   Caused by java.lang.IllegalArgumentException: No enum constant probe.map.enums.MealType.VEG' \
        '  PROBE str_customer insert Kavya=VEGETARIAN: refused' '  PROBE conv_customer insert Kavya=VEGETARIAN: refused'; do has "$W" "$l" "renamed $d"; done
    ! printf '%s\n' "$W" | sed -n '/ord_customer raw/,/str_customer raw/p' | $G -qE '^  (WARN|ERROR) |EXCEPTION' || die "renamed $d: the ORDINAL table - no WARN, no exception: the rename is quiet"; done
  echo "  renamed: VEG renamed VEGETARIAN - ORDINAL reads Ravi=VEGETARIAN with no WARN and takes Kavya=VEGETARIAN as 0; STRING's read fails 'No enum constant probe.map.enums.MealType.VEG', the converter's too, and both refuse Kavya=VEGETARIAN - H2 and PostgreSQL"; }
# the failure receipt: "@Enumerated and @Convert together - the EntityManagerFactory is refused, AnnotationException, before any
# SQL" (the trio: exit 1, the exception, no factory), both databases; "autoApply applies to the bare attribute only"
chk_converter() { local d C W
  C=$(cat .r-converter.out)
  [ "$(cnt "$C" "  the trio: exit 1 · PROBE EXCEPTION org.hibernate.AnnotationException: 'AttributeConverter' not allowed for attribute 'mealType' annotated '@jakarta.persistence.Enumerated' · the EntityManagerFactory built: no")" = 2 ] || die "converter: the trio - exit 1, the AnnotationException, no EntityManagerFactory - on both databases"
  for d in H2 PostgreSQL; do W=$(blk converter "on $d - @Enumerated" "on $d - AutoCode")
    [ "$(printf '%s\n' "$W" | $G -c ' org\.hibernate\.SQL : ')" = 0 ] || die "converter $d: the refusal comes before any SQL"; done
  W=$(blk converter "on H2 - AutoCode" "on PostgreSQL -")
  for l in "    create table bare_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('non-veg','veg','vegan'))), name varchar(255), primary key (id));" \
      "    create table ord_customer (meal_type tinyint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table str_customer (id bigint generated by default as identity, name varchar(255), meal_type enum ('NON_VEG','VEG','VEGAN'), primary key (id));"; do has "$W" "$l" "converter H2: autoApply"; done
  W=$(blk converter "on PostgreSQL - AutoCode" "")
  for l in "    create table bare_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('non-veg','veg','vegan'))), name varchar(255), primary key (id));" \
      "    create table ord_customer (meal_type smallint check ((meal_type between 0 and 2)), id bigint generated by default as identity, name varchar(255), primary key (id));" \
      "    create table str_customer (id bigint generated by default as identity, meal_type varchar(255) check ((meal_type in ('VEG','NON_VEG','VEGAN'))), name varchar(255), primary key (id));"; do has "$W" "$l" "converter PostgreSQL: autoApply"; done
  ! printf '%s\n' "$C" | $G -qE '^  WARN ' || die "converter: autoApply beside @Enumerated logs no WARN"
  echo "  converter: @Enumerated + @Convert - exit 1, AnnotationException (AttributeConverter not allowed for an attribute annotated @Enumerated), no EntityManagerFactory, 0 SQL lines, H2 and PG; autoApply - the bare attribute gets the codes' check, ORDINAL and STRING keep theirs, no WARN"; }
# the anchor change's witness (R.190/R.194, RED #319): "the seed reads back as constants - Meera=NON_VEG, Priya=VEGAN, Ravi=VEG,
# Sunil=VEG - on both databases; a persist binds VEGAN as H2's ENUM / Postgres's VARCHAR; the column stays VARCHAR(10); Hibernate's
# own DDL would be H2's enum (...); TiffinBox's own JDBC row (Kavya, by CustomerRepository: 0 insert lines) reads back as VEG"
chk_anchor() { local AN AH AP AT d
  AN=$(cat .r-anchor.out); AH=$(blk anchor "on H2 -" "on PostgreSQL - the shipped"); AP=$(blk anchor "on PostgreSQL - the shipped" "on PostgreSQL - TiffinBox"); AT=$(blk anchor "on PostgreSQL - TiffinBox" "")
  # the witness first (RED #319): the seed read through the entity, on both databases - a plant on the field fails here
  for d in "$AH" "$AP"; do for l in '  PROBE seeded by the shipped Database (createAndSeed), the raw column, read by a second connection: [Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG]' \
      '  PROBE read by Hibernate (the anchor'"'"'s CustomerEntity): [Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG]' '  PROBE getMealType()'"'"'s class: com.tiffinbox.MealType' \
      '  PROBE persisted Kavya, mealType VEGAN' "  PROBE Kavya's row, read by a second connection: [Kavya=VEGAN]" "$VERL" "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$d" "$l" "anchor: the seed read through the entity"; done; done
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^CustomerEntity.java:/p' | $G '^  ' | paste -sd' ' -)" = '  README.md   tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java' ] || die "anchor: the change is CustomerEntity.java and the README, nothing else"
  for l in '    +    @Enumerated(EnumType.STRING)' '    -    private String mealType;' '    +    private MealType mealType;' '    +    public CustomerEntity(String name, int mealsPerDay, int pricePerMeal, MealType mealType) {' \
      '    +    public MealType getMealType() {' '  39: meal_type     VARCHAR(10) NOT NULL'; do has "$AN" "$l" "anchor: the change, the column"; done
  for l in '  TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:ENUM) <- [VEGAN]' '  PROBE the column, as the catalogue gives it: [CHARACTER VARYING 10]' \
      "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));"; do has "$AH" "$l" "anchor H2"; done
  printf '%s\n' "$AH" | $G -q '^  PROBE database: H2 2\.5\.250 ' && printf '%s\n' "$AP" | $G -q '^  PROBE database: PostgreSQL 18\.6 ' || die "anchor: the two database: lines (R.217)"
  for l in '  TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:VARCHAR) <- [VEGAN]' '  PROBE the column, as the catalogue gives it: [character varying 10]' \
      "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, meal_type varchar(10) not null check ((meal_type in ('VEG','NON_VEG','VEGAN'))), name varchar(60) not null unique, primary key (id));"; do has "$AP" "$l" "anchor PostgreSQL"; done
  for l in '  listens on: 127.0.0.1:19860 · loopback only: yes' '  {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201' '  1|Ravi|VEG 2|Meera|NON_VEG 3|Sunil|VEG 4|Priya|VEGAN 5|Kavya|VEG' \
      '    INFO org.hibernate.orm.core: HHH000001: Hibernate ORM core version 7.4.13.Final' '      Database JDBC URL [jdbc:postgresql://127.0.0.1:19868/t1?user=sa&password=[masked: the 24-character password]]' \
      "  its log's lines - org.hibernate.SQL: 0 · of them 'insert into': 0 · WARN: 0 · ERROR: 0 · 'GenerationTarget encountered exception': 0" \
      '  PROBE read by Hibernate (the anchor'"'"'s CustomerEntity): [Kavya=VEG, Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG]' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$AT" "$l" "anchor: TiffinBox on Postgres, its rows read through the entity"; done
  [ "$($G -cF '(Hibernate'"'"'s Database JDBC URL line - masked in place)' .r-anchor.out)" = 1 ] || die "anchor: TiffinBox's log held the password once, masked"
  echo "  anchor: CustomerEntity.java (and the README) changed, Database's meal_type VARCHAR(10) NOT NULL unchanged; the shipped seed read through the entity as [Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG] (com.tiffinbox.MealType) on H2 and PG; Kavya bound (1:ENUM) on H2, (1:VARCHAR) on PG; the column VARCHAR 10 on both; Hibernate's DDL H2 enum (...) / PG varchar(10) + check; TiffinBox on PG: Kavya 201 by its JDBC repository (0 insert lines), read back as VEG; HHH000001 7.4.13.Final"; }
# guards (R.190): the seven the same on both trees; the eighteen tests
chk_seven() { local SV S466='466c20ed7e0d5439cb052f32ce09de1b'
  SV=$(cat .r-seven.out)
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  [ "$(printf '%s\n' "$SV" | $G -c '· Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final ·')" = 2 ] || die "seven: Boot's HHH000001 line in both logs (R.222)"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard: the web layer never reads CustomerEntity)"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: 2 · Hibernate's SQL lines: 0"; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) from the reports, the console the same; 2 EntityManagerFactories, 0 SQL lines (a guard, R.190; C7-4)"; }
# R.212: Boot's script for the moved entity = the harness's, byte for byte; its md5 is what units 08 and 10-14 compare with
XMD5=""
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  XMD5=$(printf '%s\n' "$XC" | sed -n 's/^  the same, byte for byte: yes · md5 \([0-9a-f]\{32\}\)$/\1/p')
  [ -n "$XMD5" ] || die "xcheck: the harness's DDL is not Boot's, byte for byte"
  [ "$(cnt "$XC" "    create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));")" = 2 ] || die "xcheck: the one line, twice - meal_type enum (...) now"
  [ "$XMD5" != 6ca9a85044b6d4f2b346478bbd35b92a ] || die "xcheck: the script still hashes as unit 06's (6ca9a850…) - the entity did not change"
  echo "  xcheck: Boot's script (after/'s jar, port 19862) = the harness's, byte for byte, md5 $XMD5 (was 6ca9a850… before this change: meal_type enum (...) now)"; }
EXQ="Your turn: the README's enum was reordered and Ravi became non-veg. Change how the column stores it so he stays vegetarian."
chk_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    build 1: exit 0' '    build 2: exit 0' '    PROBE MealType in this build: [VEG, NON_VEG, VEGAN] - ordinals [0, 1, 2]' '    PROBE MealType in this build: [NON_VEG, VEG, VEGAN] - ordinals [0, 1, 2]'; do has "$ER" "$l" "exercise: the README's two builds"; has "$ES" "$l" "exercise: the solution's two builds"; done
    has "$ER" '    PROBE ex_customer read by Hibernate: [Ravi=NON_VEG, Meera=VEG, Priya=VEGAN]' "exercise: the README - Ravi=NON_VEG"
    has "$ES" '    PROBE ex_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' "exercise: the solution - Ravi=VEG"
    has "$ER" '    PROBE ex_customer raw, read by a second connection: [Ravi=0, Meera=1, Priya=2]' "exercise: the README stores positions"
    has "$ES" '    PROBE ex_customer raw, read by a second connection: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]' "exercise: the solution stores names"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  [ ! -e .harness/ex/db ] || die "exercise: its database file is still there"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" = 21 ] || die "exercise: the spoken line is 21 words (R.203)"
  $G -qF '@Enumerated(EnumType.ORDINAL)' harness/src/probe/map/ex/ExCustomer.java || die "exercise: ExCustomer ships ORDINAL"
  echo "  exercise: bash and zsh alike - the README as written: ORDINAL, build 2 (reordered) reads Ravi=NON_VEG; the solution (one line: STRING): Ravi=VEG; two fresh JVMs each half; the file database gone; 21 words"; }
cap enumddl enumddl; chk_enumddl
cap reorder reorder; chk_reorder
cap added added; chk_added
cap renamed renamed; chk_renamed
cap converter converter; chk_converter
cap anchor anchor; chk_anchor
cap seven seven7; chk_seven
cap tests tests; chk_tests
cap xcheck xcheck; chk_xcheck
cap exercise exercise; chk_exercise

# hygiene: every raw capture run and every file this unit holds - 0 raw tokens, 0 raw passwords
for f in .harness/raw-*; do [ "$(paste -sd' ' "$f")" = "0 0" ] || die "a capture's raw output held the token or the password ($f: $(paste -sd' ' "$f"))"; done
[ "$(find . -type f ! -path './.m2-demo/*' -print0 | xargs -0 cat 2> /dev/null | LC_ALL=C $G -aoF -- "$PGPW" | wc -l | tr -d ' ')" = 1 ] || die "the password is held raw somewhere but its own file, .harness/pg/password"
[ "$(raw "$PGPW" "$PF")" = 1 ] || die "the password's file does not hold it"
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 harness/src/probe/map/*.java .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$LOGS" -gt 0 ] || die "a token count never ran"
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  # a line quoted from the anchor's own files (grep -rn's "FILE:LINE:" lines, a diff's -/+ lines) may name the unit that wrote it
  ! $G -vE '^(  (README\.md|tiffinbox-core/[^ :]+):[0-9]+:|    [-+])' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! $G -qE '[0-9]+\.[0-9]+ ms' "$f" || die "$f holds a millisecond figure, unmasked (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -oE 'https?://[^ '"'"']+' | $G -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! $G -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do a=$($G -cE '^\$ cd \.harness/(before|after) && java ' "$f" || true); b=$($G -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/shutdown.sh; do ! $G -v '^ *#' "$f" | $G -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.map' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
# R.213: SQL keywords are never a name here (the harness's tables and columns)
! $G -rqiwE '(class|String|Long|UUID) +(order|offset|user|value|key)\b' harness/src || die "a harness entity or field is named after an SQL keyword (R.213)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory"
echo "  hygiene: 0 raw tokens and 0 raw passwords in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs; the password only in its own file); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, random port or stack frame in any capture; every JVM pinned; every start's secrets/ listed; no kill by name; no bare wait; options as arrays; no H2 file; no dish name"

# ---- the end: the container removed, the anchor, the ports ------------------------------------------------------------------
docker rm -f "$PGN" > /dev/null 2>&1 || die "docker rm -f $PGN failed"; PGUP=""
[ -z "$(docker ps -aq --filter "name=^${PGN}\$")" ] || die "the container $PGN is still there"
echo "  the container: removed (docker ps -a --filter name=$PGN: 0 lines)"
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19860-19869 at the end; 19869 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit07: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens, 0 raw passwords; the container removed"
