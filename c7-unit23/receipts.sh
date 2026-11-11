#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · @Transactional: What the Proxy Does - this unit's receipts, Section 4's first. No change to the anchor (brief flag 1):
# anchor/ is the link to ../c7-unit17/after. @Transactional does nothing by itself: a proxy around the bean opens the transaction
# when a call comes in through it; a call from inside the same object never passes the proxy. Nine captures, each run three
# times and hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right
# after its capture by a check that can fail. One database: H2, in each JVM's memory. TiffinBox runs only in `final`.
#   bean        the proxy, printed (S4.3): Svc23's class, isCglibProxy, its target, its advices; the interface-typed Billing; the one
#               transaction manager - under Boot's default, then LABELLED under --spring.aop.proxy-target-class=false, then LABELLED
#               on a class path without aspectjweaver and spring-aspects; dependency:tree's lines that bring spring-aspects
#   call        one call, S4.1's three witnesses: svc.saveOk(Kavya)
#   trap        the trap (B/A/A', ledger C7-10): B svc.outer(Asha) -> this.inner(Asha); A svc.outerTx(Dev) -> this.inner(Dev); A' = A
#   fixb        another bean calls svc.inner(Nina) through the proxy
#   visibility  @Transactional on a protected, a package-private and a private method: the attribute source's four prints, then
#               each called from outside
#   jdbc        H2's own JDBC trace around svc.saveOk(Kavya) (ledger C7-11, in part): the four calls quoted by regex, the gap counted
#   final       TiffinBox itself (the failure receipt, S4.9): A the anchor as shipped - ready on 20020; B a LABELLED copy with
#               @Transactional on CustomerRepository.add - the start stops (port 20021); A' = A on 20022
#   xcheck      the harness's DDL script (@EntityScan("com.tiffinbox") alone) against the owning-side lesson's published md5 (R.212)
#   exercise    exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#               shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# The anchor is COPIED under .harness/anchor and built there, never in place (its README's package line, offline; its tests run);
# its jar extracted (the anchor's own line). final B is a second copy, .harness/finalb, with ONE line added (L_B below) and built
# offline without its tests (L_BUILDB: its context cannot start, so its full-stack tests could not either). The harness
# (harness/src, packages probe.t and probe.x, outside com.tiffinbox) is compiled against the anchor's extracted libraries with javac
# -parameters into .harness/hc. probe.t.Main is a Spring Boot context with no web server (WebApplicationType.NONE: it binds no port)
# over those, @EntityScan and @EnableJpaRepositories on com.tiffinbox - the anchor's entities and its own CustomerEntityRepository;
# probe.t.Seed builds the shipped Database in code on the run's own H2 database, which seeds it; ddl-auto none. Logback
# (harness/logback.xml) prints Hibernate's SQL logger, JpaTransactionManager's DEBUG lines and the transaction interceptor's TRACE
# lines (S4.1's first witness). The method's own TransactionSynchronizationManager print is the second; the third is the second
# connection: DriverManager on the same jdbc:h2:mem:u23 URL, read after the call returned or threw. probe.x.XMain is xcheck's
# context. Every JVM's flags travel as an array, V, its arguments as an array, A (R.193); every JVM runs under an alarm (perl -e
# 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247). Commands are printed exactly as they
# run: each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) and S4.7's duration-meaning
# family (below, BLUE's s47.py regex) gate this unit's prose: it speaks no time (R.172, R.264). "$M2" is this unit's .m2-demo.
# The locale: every JVM has its locale pinned on its run line (-Duser.language=en -Duser.country=US).
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline is run once more without -o and says so, naming what it fetched. At run time nothing leaves the machine: H2 in memory;
# TiffinBox (final) listens on 127.0.0.1 only, and is asked for nothing but its readiness. This unit reads no version file: the
# section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-10.xml, spring-data-bom-metadata-2026-11-10.xml).
# TiffinBox's token: generated here (openssl rand -hex 16) into .harness/<tree>/secrets/tiffinbox/shutdown-token, mode 0600,
# never printed, masked in every log; the captures and logs are counted for raw copies (0). TiffinBox is stopped by its pid.
# Masks (README.md declares each; awk gsub only): the token; this folder "…", the folder above "…/..", home "~", your user name
# "<user>"; " using Java <version>"; an identity hash "@…"; the JDK's proxy class number "$Proxy<n>"; an EntityManager's identity
# "SessionImpl(<n><open>)"; Spring Data's scan time; TiffinBox's generated database name "jdbc:h2:mem:<uuid>"; H2's trace time stamp.
# Ports (§P, 20020-20029): 20020 final A · 20021 final B · 20022 final A' · 20023-20028 unused (xcheck binds none) · 20029 never
# bound; all ten, 18425 (TiffinBox's default), 8080 and 35729 checked free at the start and the end.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group is stopped. After an interrupt a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script exits 130 after an
# interrupt. No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.t.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - the token lives under .harness/ only"
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit17/after ] || die "anchor must be the link to ../c7-unit17/after - this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
# R.211: anchor/ equals ../c7-tiffinbox until a later unit (26, 27) changes the anchor - a note then, never a stop
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen); diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
XD=tiffinbox-web/target/extracted
HS=harness/src/probe/t
HFILES='dur7.py logback.xml src'
SFILES='probe/t/Billing.java probe/t/BillingImpl.java probe/t/Caller23.java probe/t/H.java probe/t/Main.java probe/t/Run.java probe/t/Seed.java probe/t/Svc23.java probe/t/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20020 20021 20022 20023 20024 20025 20026 20027 20028 20029"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264, RED #1211): dur7.DUR, and BLUE's duration-meaning family beside it (dur7.py misses five of its lines and is
# not edited by BLUE: the family is this builder's, as the brief's CARRIED says)
cat > .harness/dur.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
for t, want in (("forever", 1), ("at once", 1), ("immediately", 1), ("one second", 1), ("a moment", 1), ("3 seconds", 1),
                ("a timeout of one, as configured", 0), ("the second connection reads Ravi", 0), ("another bean", 0)):
    assert bool(m.DUR.search(t) or FAM.search(t)) == bool(want), t
n = f = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1; print("  %s line %d: %s  <- dur7: this unit speaks no time" % (p, i, w.group(0)))
        for w in FAM.finditer(l):
            f += 1; print("  %s line %d: %s  <- S4.7's family: a duration meaning" % (p, i, w.group(0)))
print("duration words: %d · duration meanings: %d" % (n, f))
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py $PROSE) || die "the duration gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0 · duration meanings: 0' || die "a duration word or meaning - this unit speaks no time (R.172, S4.7): $(printf '%s\n' "$DW" | $G '<-' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR) · duration meanings: 0 (S4.7's family) over README.md, exercise/README.md, exercise/SOLUTION.md"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S4.3 (R.260, RED #1202, BLUE s43.py): the UNSCOPED "an interface means a JDK proxy" is refused per sentence; a sentence scoped to
# plain Spring / without Boot / Course 4 / proxy-target-class / the flag passes. S4.14 (R.271): the refuted readings this unit
# could tempt - "private ... ignored with a warning", "AspectJ is required/needed" - refused. The self-test runs BLUE's 8 cases.
cat > .harness/s43.py <<'PY'
import re, sys
CLAIM = re.compile(r"\binterface\w*\b[^.!?]*\b(?:means?|meant|gets?|got|gives?|gave|is|are|was|becomes?|uses?|used)\b[^.!?]*\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b"
                   r"|\b(?:JDK|J-D-K)(?:'s)?\b[^.!?]*\bprox(?:y|ies)\b[^.!?]*\b(?:for|on|around)\b[^.!?]*\binterface", re.I)
SCOPE = re.compile(r"\bplain Spring\b|\bwithout (?:Spring )?Boot\b|\bCourse (?:4|four)\b|proxy[-. ]target[-. ]class|\bthe (?:labelled )?flag\b", re.I)
REFUTED = re.compile(r"\bprivate\b[^.!?]*\bignored\b[^.!?]*\b(?:warn\w*|log line)|\bAspectJ\b[^.!?]*\b(?:required|needed|necessary)\b", re.I)
NEG = re.compile(r"\b(?:not|no|never|without)\b", re.I)
def refused(text):
    return [s for s in re.split(r"(?<=[.!?])\s+", text) if CLAIM.search(s) and not SCOPE.search(s)]
cases = [("An interface means a JDK proxy.", True), ("A bean with an interface gets the JDK's proxy, and a class gets a subclass.", True),
         ("Spring builds a J-D-K proxy for an interface-typed bean.", True), ("The interface bean was given... no: the interface bean used the JDK proxy here.", True),
         ("In plain Spring an interface meant the JDK's proxy; Boot flips the switch Course 4 flipped by hand.", False),
         ("Only with the flag, spring.aop.proxy-target-class=false, does the interface bean get a JDK proxy.", False),
         ("Under Spring Boot, an interface-typed bean is a CGLIB subclass too.", False), ("The proxy opens the transaction when a call comes in through it.", False)]
bad = sum(bool(refused(t)) != w for t, w in cases)
assert bad == 0, "s43 self-test: %d mismatches" % bad
for t, w in (("AspectJ is required for @Transactional.", 1), ("This needs no AspectJ.", 0), ("AspectJ is not needed: the same lines without it.", 0),
             ("A private method is ignored with a warning.", 1), ("The private method is not ignored with a warning: it runs on the proxy.", 0)):
    assert bool(REFUTED.search(t) and not NEG.search(t)) == bool(w), t
n = 0
for p in sys.argv[1:]:
    t = open(p, encoding="utf-8").read().replace("\n", " ")
    for s in refused(t):
        n += 1; print("  %s: %s  <- S4.3: an interface means a JDK proxy, unscoped (Boot gives it CGLIB)" % (p, s[:160]))
    for x in re.split(r"(?<=[.!?])\s+", t):
        if REFUTED.search(x) and not NEG.search(x):
            n += 1; print("  %s: %s  <- S4.14: a refuted reading (private ignored with a warning / AspectJ required)" % (p, x.strip()[:160]))
print("S4.3/S4.14 refused sentences: %d (self-test: %d cases, 0 mismatches)" % (n, len(cases)))
PY
SW=$(python3 -I -B .harness/s43.py $PROSE) || die "S4.3's gate did not run (or its self-test failed)"
printf '%s\n' "$SW" | tail -1 | $G -q '^S4.3/S4.14 refused sentences: 0 ' || die "S4.3 / S4.14: $(printf '%s\n' "$SW" | $G '<-' | head -3 | paste -sd';' -)"
echo "  $(printf '%s\n' "$SW" | tail -1) over README.md, exercise/"
# R.225: a SQL string this unit shows is the logger's, composed into README.md's values line by this script - a line of README.md
# holding the INSERT's head, Hibernate's alias or the count's SELECT anywhere else is a typed SQL string, refused
SQLRE='insert into customer|ce1_0\.|select count\(\*\) from customer'
TS=$($G -nE "$SQLRE" README.md 2> /dev/null | $G -vF 'the values the video may say:' | $G -vE '^[0-9]+:\^/\\\*\\\*/conn' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md outside the values line (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its composed values line"
# S4.2 (R.259): the trap is said as captured - in README.md's trap section no line may put the name inner in a manager line
TI=$(awk '/^## [0-9]+ · trap/ { f = 1; next } /^## / { f = 0 } f' README.md | $G -nE '(Creating new transaction|Getting transaction|Completing transaction).*Svc23\.inner' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TI" ] || die "README.md's trap section names inner in a manager line - trap B's named grep counts 0 such lines (S4.2, R.187): $TI"
echo "  the trap section: no manager line naming inner typed (S4.2)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
CRF=tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/Billing.java $HS/BillingImpl.java $HS/Caller23.java $HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/Svc23.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:\$LIB/*\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_TREE=$(mine 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" dependency:tree -Dincludes=org.springframework:spring-aspects,org.aspectj:aspectjweaver')
L_B=$(mine "perl -pi -e 's/^(    public void add\\(Customer customer\\) throws SQLException \\{)\$/    \\@org.springframework.transaction.annotation.Transactional\\n\$1/' .harness/finalb/$CRF")
L_BUILDB=$(mine 'cd .harness/finalb && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
[ "$(exe "$(at .harness/anchor 20020 "$R_RUN")")" = "cd .harness/anchor && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20020" ] || die "at(): the run line is not the anchor README's"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures -------------------------------------------------------------------------------------------
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
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
TR=$($G -E '^\[(INFO|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' .harness/build-anchor.log | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }')
[ "$TR" = '18 0 0 0' ] || die "the anchor's tests: Tests run, Failures, Errors, Skipped = ${TR:-none} - expected 18 0 0 0"
echo "  the anchor's tests: 18 run, 0 failures, 0 errors, 0 skipped (the build's log, its modules' summary lines summed)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
mbuild "$L_TREE" .harness/tree.log "dependency:tree of both modules, offline (spring-aspects and aspectjweaver: who brings them)"
# final B: a second copy, one line added (L_B), built without its tests
rsync -a --exclude target --exclude secrets .harness/anchor/ .harness/finalb/
(eval "$L_B") || die "L_B did not run"
BD=$(diff .harness/anchor/$CRF .harness/finalb/$CRF | $G -E '^[<>]' || true)
[ "$BD" = '>     @org.springframework.transaction.annotation.Transactional' ] || die "final B: the copy must differ from the anchor by one added line, the annotation above add: ${BD:-no difference}"
[ -z "$(diff -rq -x target .harness/anchor .harness/finalb | $G -v "CustomerRepository.java" || true)" ] || die "final B: the copy differs elsewhere"
mbuild "$L_BUILDB" .harness/build-finalb.log ".harness/finalb (the copy, one line added; -DskipTests)"
(cd .harness/finalb && eval "$R_EXTRACT") > .harness/extract-b.log 2>&1 < /dev/null || die "the extract of finalb failed"
for t in anchor finalb; do (cd .harness/$t && eval "$R_TOKEN") || die "the token for $t was not written"
  [ "$(stat -f '%Lp' .harness/$t/secrets/tiffinbox/shutdown-token)" = 600 ] || die "the token's file must be mode 0600"; done
TOKEN=$(head -n 1 .harness/anchor/secrets/tiffinbox/shutdown-token); TOKENB=$(head -n 1 .harness/finalb/secrets/tiffinbox/shutdown-token)
[ ${#TOKEN} = 32 ] && [ ${#TOKENB} = 32 ] || die "a generated token is not 32 characters"
echo "  the two tokens: generated (openssl rand -hex 16), each in its tree's secrets/tiffinbox/shutdown-token, mode 0600, never printed"
# the class path without AspectJ (the bean capture's labelled run): the extracted lib/ less aspectjweaver and spring-aspects, by hard link
mkdir -p .harness/noaj; for j in .harness/anchor/$XD/lib/*.jar; do case ${j##*/} in aspectjweaver-*|spring-aspects-*) ;; *) ln "$j" .harness/noaj/ ;; esac; done
NL=$(ls .harness/anchor/$XD/lib | wc -l | tr -d ' '); NN=$(ls .harness/noaj | wc -l | tr -d ' ')
[ "$((NL - NN))" = 2 ] && [ -z "$(ls .harness/noaj | $G -E '^(aspectjweaver|spring-aspects)-' || true)" ] || die "the class path without AspectJ: two jars fewer, aspectjweaver and spring-aspects"
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/t/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($NL libraries; without AspectJ: $NN); the harness compiled into .harness/hc"
# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v tb="$TOKENB" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); TB = lit(tb); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(TB, "[masked: the token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9][.0-9]*[+-][0-9][0-9]:[0-9][0-9] /, "<time> ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' "token $TOKEN and $TOKENB" 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' '2026-11-11 15:47:44.230686+01:00 jdbc[3]: ' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' 'token [masked: the token] and [masked: the token]' 'url=jdbc:h2:mem:<uuid> user=SA' '<time> jdbc[3]: ')" ] || die "mask: the planted JDK version, folders, home, identity hash, proxy number, EntityManager identity, scan time, the two tokens, a generated database name and H2's trace time stamp must be masked"
rm -f .harness/p1
# the harness's arguments: this run's own H2 database (in this JVM's memory, kept while the context lives), the harness's Logback
# file, no schema written, no banner, the anchor's Thymeleaf jar not looking for templates
HA=('--spring.datasource.url=jdbc:h2:mem:u23;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
# jdbc: H2's own JDBC trace on (the harness URL only), Boot's pool held to one connection so the trace shows one
HJ=('--spring.datasource.url=jdbc:h2:mem:u23;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3' --spring.datasource.hikari.maximum-pool-size=1 --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
LIBA="../anchor/$XD/lib"; LIB=$LIBA
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ LIB=$LIB"; echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (export LIB; eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
# jview: the jdbc run's log - every line but H2's trace; between the call's markers, of the trace's statement lines (those that
# start /*) the four that match JREGEX in order, and the count of the others between the first and the last of them (R.205)
JREGEX='^/\*\*/conn[0-9]+\.setAutoCommit\(false\);$|^/\*\*/PreparedStatement prep[0-9]+ = conn[0-9]+\.prepareStatement\("insert into customer |^/\*\*/conn[0-9]+\.commit\(\);$|^/\*\*/conn[0-9]+\.setAutoCommit\(true\);$'
jview() { JRE="$JREGEX" awk '
  BEGIN { re = ENVIRON["JRE"] }
  function tr(l) { return l ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:/ || l ~ /^\/\*/ }
  { sub(/[ \t]+$/, "") }
  /^PROBE >>> / { inm = 1; print "  " $0; next }
  /^PROBE <<< / { inm = 0; if (found) print "  (H2 trace) the other statement lines between the first and the last of the four: " gap; print "  " $0; next }
  inm && /^\/\*/ { if ($0 ~ re && k < 4) { print "  (H2 trace) " $0; k++; found = 1; if (k > 1) gap += pend; pend = 0 } else if (k > 0 && k < 4) pend++; next }
  tr($0) { next }
  { print "  " $0 }' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    echo "$(raw "$TOKEN" .harness/cap.raw) $(raw "$TOKENB" .harness/cap.raw)" > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# ---- TiffinBox (final): started from its tree, readiness polled, stopped by its pid -------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
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
ended() { local i=0 e=0 c=""
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do
    c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true)
    [ "$c" != 200 ] || break
    sleep 0.25; i=$((i + 1)); done
  if [ "$c" = 200 ]; then echo "  it did not fail: readiness answered 200 on $1"; stopit "$1"; return 0; fi
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the start on $1 was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something listens on $1"
  echo "  it ended by itself: exit $LASTE · listening on $1: 0 · readiness never answered 200"; }
lvl() { $G -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); t=$((t + $(raw "$TOKENB" .harness/run.out))); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
TPAT='org\.hibernate\.orm\.core|TiffinBoxServer|LocalContainerEntityManagerFactoryBean|RepositoryConfigurationDelegate|SpringApplication$'
tview() { awk -v pat="$TPAT" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ {
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m) }' "$1"
  echo "  its log's lines - WARN: $(lvl WARN "$1") · ERROR: $(lvl ERROR "$1") · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' "$1" || true)"; }
chain() { awk '/ ERROR [0-9]+ --- \[.*\] o\.s\.boot\.SpringApplication +: Application run failed$/ { f = 1; next }
  f == 1 && NF { sub(/[ \t]+$/, ""); print "    " $0; f = 2; next } f == 2 && /^Caused by: / { sub(/[ \t]+$/, ""); print "    " $0 }' "$1"
  echo "  the log's order - Initialized JPA EntityManagerFactory at line $($G -n -m1 'Initialized JPA EntityManagerFactory' "$1" | cut -d: -f1 || true), Application run failed at line $($G -n -m1 'Application run failed' "$1" | cut -d: -f1 || true)"; }

# ---- the captures --------------------------------------------------------------------------------------------------------
bean() { echo "Boot's default (no flag) - the anchor's 91 libraries:"
  V=(-Ds=bean); A=("${HA[@]}"); LIB=$LIBA; hrun; hview
  echo "LABELLED - the same, with --spring.aop.proxy-target-class=false:"
  V=(-Ds=bean); A=("${HA[@]}" --spring.aop.proxy-target-class=false); hrun; hview
  echo "LABELLED - the class path without aspectjweaver and spring-aspects (.harness/noaj, the same libraries less those two):"
  V=(-Ds=bean); A=("${HA[@]}"); LIB=../noaj; hrun; hview; LIB=$LIBA
  echo "dependency:tree of both modules, offline, filtered to the two jars (run at the build: \$ $L_TREE):"
  sed -n -E 's/^\[INFO\] ([+| \\-].*)$/    \1/p; s/^\[INFO\] (com\.tiffinbox:tiffinbox-web:jar:.*)$/    \1/p' .harness/tree.log; }
call() { echo "call - svc.saveOk(Kavya), one harness JVM:"; V=(-Ds=call); A=("${HA[@]}"); hrun; hview; }
trapc() { echo "B - svc.outer(Asha), no annotation, calls this.inner(Asha) - @Transactional, saves, throws (one harness JVM):"
  V=(-Ds=trap -Dv=B); A=("${HA[@]}"); hrun; hview
  echo "A - svc.outerTx(Dev), @Transactional on the outer method, calls this.inner(Dev) (one harness JVM):"
  V=(-Ds=trap -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=trap -Dv=A); A=("${HA[@]}"); hrun; hview; }
fixb() { echo "fixb - Caller23, another bean, calls svc.inner(Nina) through the reference it was given (one harness JVM):"; V=(-Ds=fixb); A=("${HA[@]}"); hrun; hview; }
visibility() { echo "visibility - the attribute source's four prints, then protected, package-private and private, each called from outside (one harness JVM):"; V=(-Ds=visibility); A=("${HA[@]}"); hrun; hview; }
jdbc() { echo "jdbc - LABELLED: H2's JDBC trace on (;TRACE_LEVEL_SYSTEM_OUT=3 on the harness URL only), Boot's pool one connection; svc.saveOk(Kavya) (one harness JVM):"
  V=(-Ds=jdbc); A=("${HJ[@]}"); hrun; jview; }
final() { echo "A - the anchor as shipped (.harness/anchor), port 20020:"
  start "$(at .harness/anchor 20020 "$R_RUN")" 20020; up 20020; ready 20020; stopit 20020; logtok; tview .harness/run.out; rm -f .harness/run.out
  echo "B - LABELLED: .harness/finalb, the copy with @Transactional on CustomerRepository.add (one line added), port 20021 - the failure receipt:"
  start "$(at .harness/finalb 20021 "$R_RUN")" 20021; ended 20021; logtok; tview .harness/run.out
  echo "  the exception, as the log printed it (the line after Application run failed, then each Caused by: line):"; chain .harness/run.out; rm -f .harness/run.out
  echo "A' - the anchor as shipped again, port 20022:"
  start "$(at .harness/anchor 20022 "$R_RUN")" 20022; up 20022; ready 20022; stopit 20022; logtok; tview .harness/run.out; rm -f .harness/run.out; }
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x23;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  echo "  .harness/run/hibernate-ddl.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/run/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/run/hibernate-ddl.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: $( [ "$(md5 -q .harness/run/hibernate-ddl.sql)" = "$X09" ] && echo yes || echo no)"
  rm -f .harness/run/hibernate-ddl.sql; }
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
# ---- the checks of what the video says from each capture, right after it ----------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# S4.13 (R.270): Framework's version in the same capture beside HHH000001 and Spring Data's - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBL='  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u23;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] && [ "$(cnt "$c" "$VERF")" = "$2" ] || die "$1: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in each of its $2 harness JVMs (S4.13)"
  [ "$(cnt "$c" "${3:-$DBL}")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] || die "$1: the database: line (H2 2.5.250), the shipped seed read by the second connection and Spring Data's Found 1 - the anchor's own repository - in each of its $2 harness JVMs"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$1: each of its $2 harness JVMs ends by itself, exit 0"; }
call1() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2" 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 && length($0) == length(b) { f = 0 }'; }
TXP='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : '
TIP='  TRACE org.springframework.transaction.interceptor.TransactionInterceptor : '
txc() { printf '%s\n' "$1" | $G -cF -- "$TXP$2" || true; }
tic() { printf '%s\n' "$1" | $G -cF -- "$TIP$2" || true; }
crt() { printf '%s\n' "$1" | sed -n "s/^$TXP"'Creating new transaction with name \[\(.*\)\]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT$/\1/p'; }
aft() { printf '%s\n' "$1" | sed -n 's/^  PROBE after: the second connection reads //p'; }
thr() { printf '%s\n' "$1" | sed -n 's/^  PROBE threw: //p'; }
lno() { printf '%s\n' "$1" | $G -nF -m1 -- "$2" | cut -d: -f1; }
INS='insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)'
SEED4='customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]'
# S4.1 (R.258): the three witnesses of one call, each read off its block - the manager's lines, the method's own print, the second
# connection's read AFTER the call; the after line is the block's only one and comes after the manager's last line
witness() { local b=$1 w=$2 a n
  n=$(printf '%s\n' "$b" | $G -c '^  PROBE after: ' || true); [ "$n" = 1 ] || die "$w: one read by the second connection, after the call ($n) - never a count inside the transaction (S4.1)"
  a=$(lno "$b" '  PROBE after: '); [ "$a" -gt "$(printf '%s\n' "$b" | $G -nF -- "$TXP" | tail -1 | cut -d: -f1)" ] || die "$w: the second connection's read comes after the manager's last line (S4.1)"; }
BSV=""; BSB=""; BSN=""; BADV=""; BJB=""; BMGR=""; BTREE=""; BTREEP=""
chk_bean() { local D J N l
  ver bean 3
  D=$(blk bean "Boot's default" 'LABELLED - the same'); J=$(blk bean 'LABELLED - the same' 'LABELLED - the class path'); N=$(blk bean 'LABELLED - the class path' 'dependency:tree')
  BSV=$(printf '%s\n' "$D" | sed -n 's/^  PROBE bean svc23: //p')
  [ "$BSV" = 'class probe.t.Svc23$$SpringCGLIB$$0 · AopUtils.isCglibProxy true · isJdkDynamicProxy false · target probe.t.Svc23 · advices 1 [org.springframework.transaction.interceptor.TransactionInterceptor]' ] || die "bean: Svc23's proxy - a CGLIB subclass, its target, one advice, the TransactionInterceptor (S4.3): $BSV"
  # the number of advices: read off the list, len() - and equal to the count the line gives
  BADV=$(printf '%s\n' "$BSV" | sed -n 's/.*advices [0-9]* \[\(.*\)\]$/\1/p' | tr ',' '\n' | $G -c . || true)
  [ "$BADV" = "$(printf '%s\n' "$BSV" | sed -n 's/.* advices \([0-9]*\) \[.*/\1/p')" ] && [ "$BADV" = 1 ] || die "bean: the advices, counted off the list (len): $BADV"
  BSB=$(printf '%s\n' "$D" | sed -n 's/^  PROBE bean billing (interface-typed: Billing <- BillingImpl): \(class [^ ]*\) · AopUtils.isCglibProxy \([a-z]*\) · .*/\1 · isCglibProxy \2/p')
  [ "$BSB" = 'class probe.t.BillingImpl$$SpringCGLIB$$0 · isCglibProxy true' ] || die "bean: under Boot's default the interface-typed bean is CGLIB too (S4.3, READ FIRST 10): $BSB"
  BJB=$(printf '%s\n' "$J" | sed -n 's/^  PROBE bean billing (interface-typed: Billing <- BillingImpl): \(class [^ ]*\) · AopUtils.isCglibProxy [a-z]* · isJdkDynamicProxy \([a-z]*\) · target \([^ ]*\) .*/\1 · isJdkDynamicProxy \2 · target \3/p')
  [ "$BJB" = 'class jdk.proxy2.$Proxy<n> · isJdkDynamicProxy true · target probe.t.BillingImpl' ] || die "bean: only under the labelled flag is it the JDK's proxy: $BJB"
  has "$J" '  PROBE spring.aop.proxy-target-class as this context read it: false' "bean: the flag run is labelled by the context itself"
  has "$D" "  PROBE spring.aop.proxy-target-class as this context read it: (not set: Boot's default)" "bean: the default run sets no flag"
  [ "$(printf '%s\n' "$J" | sed -n 's/^  PROBE bean svc23: //p')" = "$BSV" ] || die "bean: a class with no interface stays CGLIB under the flag"
  BMGR=$(printf '%s\n' "$D" | sed -n 's/^  PROBE transaction manager bean: //p')
  [ "$BMGR" = 'transactionManager · org.springframework.orm.jpa.JpaTransactionManager' ] || die "bean: the one transaction manager: $BMGR"
  for l in "$D" "$J" "$N"; do [ "$(printf '%s\n' "$l" | $G -c '^  PROBE transaction manager bean: ' || true)" = 1 ] || die "bean: one transaction manager in each run"; done
  # no AspectJ: the same lines but the class-path line
  has "$D" '  PROBE on the class path - org.aspectj.weaver.Advice: true · org.springframework.transaction.aspectj.AnnotationTransactionAspect: true' "bean: the default class path holds both"
  has "$N" '  PROBE on the class path - org.aspectj.weaver.Advice: false · org.springframework.transaction.aspectj.AnnotationTransactionAspect: false' "bean: the labelled class path holds neither"
  [ "$(printf '%s\n' "$D" | $G -v '^  PROBE on the class path\|^\$ LIB=' )" = "$(printf '%s\n' "$N" | $G -v '^  PROBE on the class path\|^\$ LIB=')" ] || die "bean: without aspectjweaver and spring-aspects every other line is the same (READ FIRST 10: AspectJ is not needed)"
  BTREE=$(sed -n 's/^    .*- \(org.springframework:spring-aspects:jar:[^:]*:compile\)$/\1/p' .r-bean.out | head -1)
  BTREEP=$(sed -n 's/^    [+\\]- \(org.springframework.boot:spring-boot-starter-data-jpa:jar:[^:]*:compile\)$/\1/p' .r-bean.out | head -1)
  [ "$BTREE" = 'org.springframework:spring-aspects:jar:7.0.10:compile' ] && [ "$BTREEP" = 'org.springframework.boot:spring-boot-starter-data-jpa:jar:4.1.2:compile' ] || die "bean: dependency:tree - spring-aspects 7.0.10 under the data-JPA starter: ${BTREE:-none} <- ${BTREEP:-none}"
  echo "  bean: Svc23 - $BSV ($BADV advice, by len); Billing under Boot - $BSB; under the labelled flag - $BJB; one manager - $BMGR; without aspectjweaver and spring-aspects - the same lines; $BTREE <- $BTREEP"; }
CNAME=""; CIN=""; CROWS=""; CPART=""
chk_call() { local C b
  C=$(cat .r-call.out); ver call 1; b=$(call1 "$C" 'svc.saveOk(Kavya)'); [ -n "$b" ] || die "call: no block"
  CNAME=$(crt "$b"); [ "$CNAME" = probe.t.Svc23.saveOk ] && [ "$(txc "$b" 'Creating new transaction')" = 1 ] || die "call: one transaction created, named for the method (S4.1): ${CNAME:-none}"
  CIN=$(printf '%s\n' "$b" | sed -n 's/^  PROBE   inside saveOk: //p'); [ "$CIN" = 'tx active true · name probe.t.Svc23.saveOk · readOnly false' ] || die "call: the method's own print (S4.1): $CIN"
  CPART=$(txc "$b" 'Participating in existing transaction'); [ "$CPART" = 1 ] || die "call: the repository's save participates"
  [ "$(printf '%s\n' "$b" | $G -cxF -- "  DEBUG org.hibernate.SQL : $INS" || true)" = 1 ] || die "call: one INSERT"
  [ "$(txc "$b" 'Initiating transaction commit')" = 1 ] && [ "$(txc "$b" 'Initiating transaction rollback')" = 0 ] || die "call: committed, not rolled back (S4.2)"
  has "$b" '  PROBE returned' "call: saveOk returned"; witness "$b" call
  CROWS=$(aft "$b"); [ "$CROWS" = 'customer rows 5 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya, 5 Kavya]' ] || die "call: the second connection after the call: $CROWS"
  [ "$(lno "$b" "${TXP}Creating new transaction")" -lt "$(lno "$b" '  PROBE   inside saveOk')" ] && [ "$(lno "$b" '  PROBE   inside saveOk')" -lt "$(lno "$b" "${TXP}Initiating transaction commit")" ] || die "call: the order - the transaction created, the method inside it, then the commit"
  echo "  call: Creating new transaction with name [$CNAME]; inside - $CIN; Participating in existing transaction ($CPART); Initiating transaction commit; after - $CROWS"; }
TBN=""; TBIN=""; TBINNER=""; TBT=""; TBR=""; TAN=""; TAIN=""; TACMP=""; TAR=""; TAT=""
chk_trap() { local B A1 A2 x m
  ver trap 3
  B=$(blk trap 'B - ' 'A - '); A1=$(blk trap 'A - ' "A' - "); A2=$(blk trap "A' - " '')
  x=$(call1 "$B" 'svc.outer(Asha) -> this.inner(Asha)'); [ -n "$x" ] || die "trap B: no block"
  TBN=$(crt "$x"); [ "$TBN" = org.springframework.data.jpa.repository.support.SimpleJpaRepository.save ] && [ "$(txc "$x" 'Creating new transaction')" = 1 ] || die "trap B: the only transaction is SimpleJpaRepository.save's (S4.2): ${TBN:-none}"
  TBIN=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   inside inner: //p'); [ "$TBIN" = 'tx active false · name null · readOnly false' ] && has "$x" '  PROBE   inside outer: tx active false · name null · readOnly false' "trap B: outer" || die "trap B: inside inner - no transaction: $TBIN"
  # R.187: the name inner in the manager's and the interceptor's lines, by a named grep - 0
  TBINNER=$(printf '%s\n' "$x" | $G -F -e "$TXP" -e "$TIP" | $G -c 'Svc23\.inner' || true); [ "$TBINNER" = 0 ] || die "trap B: a manager line names inner ($TBINNER)"
  [ "$(txc "$x" 'Initiating transaction commit')" = 1 ] && [ "$(txc "$x" 'Initiating transaction rollback')" = 0 ] || die "trap B: save's transaction committed, nothing rolled back (S4.2)"
  TBT=$(thr "$x"); [ "$TBT" = 'probe.t.H$Boom: inner failed after the save of Asha' ] || die "trap B: the exception reaches the caller: $TBT"
  [ "$(lno "$x" "${TXP}Initiating transaction commit")" -lt "$(lno "$x" '  PROBE threw: ')" ] || die "trap B: the commit came before the exception"
  witness "$x" "trap B"; TBR=$(aft "$x"); [ "$TBR" = 'customer rows 5 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya, 5 Asha]' ] || die "trap B: Asha kept - the second connection after the call: $TBR"
  for m in "$A1" "$A2"; do x=$(call1 "$m" 'svc.outerTx(Dev) -> this.inner(Dev)'); [ -n "$x" ] || die "trap A: no block"
    [ "$(crt "$x")" = probe.t.Svc23.outerTx ] && [ "$(txc "$x" 'Creating new transaction')" = 1 ] || die "trap A: one transaction, named for outerTx"
    has "$x" '  PROBE   inside inner: tx active true · name probe.t.Svc23.outerTx · readOnly false' "trap A: inner runs inside outerTx's transaction"
    has "$x" "${TIP}Completing transaction for [probe.t.Svc23.outerTx] after exception: probe.t.H\$Boom: inner failed after the save of Dev" "trap A: the interceptor's line"
    [ "$(txc "$x" 'Initiating transaction rollback')" = 1 ] && [ "$(txc "$x" 'Initiating transaction commit')" = 0 ] || die "trap A: rolled back (S4.2)"
    witness "$x" "trap A"; [ "$(aft "$x")" = "$SEED4" ] || die "trap A: Dev gone - the second connection: $(aft "$x")"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "trap A': A again prints what A printed (R.1)"
  x=$(call1 "$A1" 'svc.outerTx(Dev) -> this.inner(Dev)'); TAN=$(crt "$x"); TAIN=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   inside inner: //p')
  TACMP=$(printf '%s\n' "$x" | sed -n "s/^$TIP//p" | $G '^Completing transaction for \[probe.t.Svc23.outerTx\] after exception: ' || true); TAR=$(aft "$x"); TAT=$(thr "$x")
  echo "  trap: B - Creating new transaction with name [$TBN] (the only one), inside inner $TBIN, manager lines naming inner $TBINNER, committed, threw $TBT, after - $TBR; A and A' - [$TAN], inside inner $TAIN, $TACMP, Initiating transaction rollback, after - $TAR"; }
FBN=""; FBIN=""; FBR=""
chk_fixb() { local F x
  F=$(cat .r-fixb.out); ver fixb 1; x=$(call1 "$F" 'caller.viaProxy(Nina) -> svc.inner(Nina), through the proxy'); [ -n "$x" ] || die "fixb: no block"
  FBN=$(crt "$x"); [ "$FBN" = probe.t.Svc23.inner ] || die "fixb: the call through the proxy - a transaction named for inner: $FBN"
  FBIN=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   inside inner: //p'); [ "$FBIN" = 'tx active true · name probe.t.Svc23.inner · readOnly false' ] || die "fixb: inside inner: $FBIN"
  has "$x" "${TIP}Completing transaction for [probe.t.Svc23.inner] after exception: probe.t.H\$Boom: inner failed after the save of Nina" "fixb: the interceptor's line"
  [ "$(txc "$x" 'Initiating transaction rollback')" = 1 ] && [ "$(txc "$x" 'Initiating transaction commit')" = 0 ] || die "fixb: rolled back (S4.2)"
  witness "$x" fixb; FBR=$(aft "$x"); [ "$FBR" = "$SEED4" ] || die "fixb: Nina gone: $FBR"
  echo "  fixb: Creating new transaction with name [$FBN]; inside inner $FBIN; Initiating transaction rollback; after - $FBR"; }
VATT=""; VPN=""; VKN=""; VPRI=""; VNPE=""; VWARN=""; VPR=""
chk_visibility() { local W x m
  W=$(cat .r-visibility.out); ver visibility 1
  for m in 'inner (public)' 'protInner (protected)' 'pkgInner (package-private)' 'privInner (private)'; do has "$W" "  PROBE attribute for Svc23.$m: PROPAGATION_REQUIRED,ISOLATION_DEFAULT" "visibility: the attribute source finds the annotation on $m"; done
  VATT=$(printf '%s\n' "$W" | $G -c '^  PROBE attribute for Svc23\..*: PROPAGATION_REQUIRED,ISOLATION_DEFAULT$' || true)
  x=$(call1 "$W" 'protected: caller.callProtected(Omar)'); VPN=$(crt "$x")
  [ "$VPN" = probe.t.Svc23.protInner ] && [ "$(txc "$x" 'Initiating transaction rollback')" = 1 ] && [ "$(aft "$x")" = "$SEED4" ] || die "visibility: protected - its own transaction, rolled back, Omar gone"; witness "$x" "visibility protected"
  x=$(call1 "$W" 'package-private: caller.callPackage(Lena)'); VKN=$(crt "$x")
  [ "$VKN" = probe.t.Svc23.pkgInner ] && [ "$(txc "$x" 'Initiating transaction rollback')" = 1 ] && [ "$(aft "$x")" = "$SEED4" ] || die "visibility: package-private - its own transaction, rolled back, Lena gone"; witness "$x" "visibility package-private"
  x=$(call1 "$W" 'private: Svc23.callPrivateOn(the proxy, Tara) -> proxy.privInner(Tara)')
  VPRI=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   inside privInner: //p')
  [ "$VPRI" = 'tx active false · name null · readOnly false · this.repo null · this.getClass() probe.t.Svc23$$SpringCGLIB$$0' ] || die "visibility: private - it runs on the proxy object itself, no transaction, its field null: $VPRI"
  VNPE=$(thr "$x"); [ "$VNPE" = 'java.lang.NullPointerException: Cannot invoke "com.tiffinbox.CustomerEntityRepository.save(Object)" because "this.repo" is null' ] || die "visibility: private - the NullPointerException's class and message: $VNPE"
  [ "$(printf '%s\n' "$x" | $G -cF -e "$TXP" -e "$TIP" || true)" = 0 ] || die "visibility: private - no manager or interceptor line"
  witness0() { [ "$(printf '%s\n' "$1" | $G -c '^  PROBE after: ' || true)" = 1 ] || die "visibility private: one read by the second connection, after the call"; }; witness0 "$x"
  VPR=$(aft "$x"); [ "$VPR" = "$SEED4" ] || die "visibility: private - nothing saved: $VPR"
  VWARN=$(printf '%s\n' "$W" | $G -c '^  WARN ' || true); [ "$VWARN" = 0 ] || die "visibility: WARN lines in the whole run: $VWARN"
  echo "  visibility: the attribute found on $VATT of 4 (public, protected, package-private, private); protected - [$VPN], rolled back; package-private - [$VKN], rolled back; private - $VPRI, $VNPE; WARN lines $VWARN"; }
J1=""; J2=""; J3=""; J4=""; JGAP=""; JROWS=""
chk_jdbc() { local W x
  W=$(cat .r-jdbc.out); ver jdbc 1 '  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u23;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3'
  x=$(call1 "$W" "svc.saveOk(Kavya), H2's JDBC trace on"); [ -n "$x" ] || die "jdbc: no block"
  [ "$(printf '%s\n' "$x" | $G -c '^  (H2 trace) /\*' || true)" = 4 ] || die "jdbc: the four trace lines, by the regex (R.205)"
  J1=$(printf '%s\n' "$x" | sed -n 's/^  (H2 trace) //p' | sed -n 1p); J2=$(printf '%s\n' "$x" | sed -n 's/^  (H2 trace) //p' | sed -n 2p)
  J3=$(printf '%s\n' "$x" | sed -n 's/^  (H2 trace) //p' | sed -n 3p); J4=$(printf '%s\n' "$x" | sed -n 's/^  (H2 trace) //p' | sed -n 4p)
  printf '%s\n' "$J1" | $G -qE '^/\*\*/conn[0-9]+\.setAutoCommit\(false\);$' && printf '%s\n' "$J2" | $G -qF 'prepareStatement("insert into customer ' && printf '%s\n' "$J3" | $G -qE '^/\*\*/conn[0-9]+\.commit\(\);$' && printf '%s\n' "$J4" | $G -qE '^/\*\*/conn[0-9]+\.setAutoCommit\(true\);$' || die "jdbc: the order - setAutoCommit(false), the INSERT, commit(), setAutoCommit(true): $J1 | $J2 | $J3 | $J4"
  [ "${J1%%.*}" = "${J3%%.*}" ] && [ "${J1%%.*}" = "${J4%%.*}" ] || die "jdbc: the four on one connection"
  JGAP=$(printf '%s\n' "$x" | sed -n 's/^  (H2 trace) the other statement lines between the first and the last of the four: //p'); [ -n "$JGAP" ] || die "jdbc: the gap, counted"
  [ "$(lno "$x" "${TXP}Creating new transaction with name [probe.t.Svc23.saveOk]")" -lt "$(lno "$x" "  (H2 trace) $J1")" ] && [ "$(lno "$x" "${TXP}Initiating transaction commit")" -lt "$(lno "$x" "  (H2 trace) $J3")" ] || die "jdbc: setAutoCommit(false) after the manager created the transaction; commit() after Initiating transaction commit"
  witness "$x" jdbc; JROWS=$(aft "$x"); [ "$JROWS" = 'customer rows 5 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya, 5 Kavya]' ] || die "jdbc: Kavya committed: $JROWS"
  echo "  jdbc: $J1 · $J2 · $J3 · $J4 (the other statement lines between them: $JGAP); after - $JROWS"; }
FA=""; FBC1=""; FBC2=""; FBE=""
chk_final() { local A1 B A2 o c
  A1=$(blk final 'A - ' 'B - '); B=$(blk final 'B - ' "A' - "); A2=$(blk final "A' - " '')
  for c in "$A1:20020" "$A2:20022"; do o=${c%:*}
    has "$o" "  listens on: 127.0.0.1:${c##*:}" "final A: TiffinBox on loopback ${c##*:}"; has "$o" '  GET /actuator/health/readiness -> 200' "final A: ready"
    has "$o" '    INFO com.tiffinbox.web.TiffinBoxServer: Started TiffinBoxServer' "final A: started"; has "$o" "  stopped by its pid (SIGTERM): exit 143 · listening on ${c##*:} now: 0" "final A: stopped"
    has "$o" '  its log: the token 0 times' "final A: no token in the log"; nhas "$o" 'Application run failed' "final A"; done
  [ "$(printf '%s\n' "$A1" | sed 's/2002[02]/<port>/g')" = "$(printf '%s\n' "$A2" | sed 's/2002[02]/<port>/g')" ] || die "final A': A again prints what A printed, but its port"
  FA=$(printf '%s\n' "$A1" | sed -n "s/^  Boot's first line: //p")
  has "$B" '  it ended by itself: exit 1 · listening on 20021: 0 · readiness never answered 200' "final B: exit 1, never ready (S4.9)"
  nhas "$B" 'Started TiffinBoxServer' "final B: never started"
  has "$B" "    INFO j.LocalContainerEntityManagerFactoryBean: Initialized JPA EntityManagerFactory for persistence unit 'default'" "final B: after the EntityManagerFactory"
  o=$(printf '%s\n' "$B" | sed -n -E 's/^  the log.s order - Initialized JPA EntityManagerFactory at line ([0-9]+), Application run failed at line ([0-9]+)$/\1 \2/p')
  set -- $o; [ $# = 2 ] && [ "$1" -lt "$2" ] || die "final B: the refusal after Initialized JPA EntityManagerFactory (the log's order): ${o:-none}"
  FBC1=$(printf '%s\n' "$B" | $G '^    Caused by: ' | tail -2 | sed -n 1p | sed 's/^    Caused by: //'); FBC2=$(printf '%s\n' "$B" | $G '^    Caused by: ' | tail -1 | sed 's/^    Caused by: //')
  [ "$FBC1" = 'org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.CustomerRepository: Common causes of this problem include using a final class or a non-visible class' ] || die "final B: the CGLIB refusal (S4.9): ${FBC1:-none}"
  [ "$FBC2" = 'java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.CustomerRepository' ] || die "final B: its cause: ${FBC2:-none}"
  FBE=1
  echo "  final: A and A' - $FA, ready, stopped; B (@Transactional on CustomerRepository.add, labelled) - exit $FBE, never ready, after Initialized JPA EntityManagerFactory: $FBC1 <- $FBC2"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's method saves a customer and then fails, and the customer stays. Make the rollback happen."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXBN=""; EXBR=""; EXSN=""; EXSR=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE signUp(Asha) threw: java.lang.IllegalStateException: the welcome step failed after the save of Asha'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    # broken = trap B's: the only transaction save's, committed, Asha kept; solved = trap A's: the outer method's, rolled back, gone
    EXBN=$(printf '%s\n' "$ER" | sed -n 's/^    Creating new transaction with name \[\(.*\)\]$/\1/p'); EXSN=$(printf '%s\n' "$ES" | sed -n 's/^    Creating new transaction with name \[\(.*\)\]$/\1/p')
    [ "$EXBN" = "$TBN" ] && has "$ER" '    Initiating transaction commit' "exercise broken" && nhas "$ER" 'rollback' "exercise broken" || die "exercise: the README's run is trap B's - only save's transaction, committed: ${EXBN:-none}"
    [ "$EXSN" = probe.t.ex.Signup.signUp ] && has "$ES" '    Initiating transaction rollback' "exercise solved" && nhas "$ES" 'commit' "exercise solved" || die "exercise: the solution's run is trap A's - the outer method's transaction, rolled back: ${EXSN:-none}"
    EXBR=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p'); EXSR=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p')
    [ "$EXBR" = "customer rows ${TBR#customer rows } · Asha kept" ] 2> /dev/null || [ "$EXBR" = 'customer rows 5 · Asha kept' ] || die "exercise: the README's row read: $EXBR"
    [ "$EXSR" = "customer rows $(printf '%s\n' "$TAR" | awk '{ print $3 }') · Asha gone" ] || die "exercise: the solution's row read = trap A's count, Asha gone: $EXSR"
    [ "$EXBR" != "$EXSR" ] || die "exercise: broken and solved must differ - by the rows, never only the exit code"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    public void signUp(String name) {' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships signUp without the annotation - the trap"
  echo "  exercise: bash and zsh alike - the README as written: Creating new transaction with name [$EXBN], committed, $EXBR (= trap B's); the solution (one line: @Transactional on signUp): [$EXSN], rolled back, $EXSR (= trap A's); each file's What it prints = the run; $EXW words"; }
cap bean bean; chk_bean; pub bean
cap call call; chk_call; pub call
cap trap trapc; chk_trap; pub trap
cap fixb fixb; chk_fixb; pub fixb
cap visibility visibility; chk_visibility; pub visibility
cap jdbc jdbc; chk_jdbc; pub jdbc
cap final final; chk_final; pub final
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - bean: Svc23 -> ${BSV%% · AopUtils*}, advices $BADV; Billing (an interface) under Boot -> ${BSB%% · *}; under the labelled --spring.aop.proxy-target-class=false -> ${BJB%% · *}; the manager: $BMGR; without aspectjweaver and spring-aspects: the same lines; $BTREE <- $BTREEP · call saveOk(Kavya): Creating new transaction with name [$CNAME] · inside: $CIN · Participating in existing transaction · Initiating transaction commit · the second connection after: $CROWS · trap B outer(Asha) -> this.inner(Asha): Creating new transaction with name [$TBN] (the only one; manager lines naming inner: $TBINNER) · inside inner: $TBIN · Initiating transaction commit · threw $TBT · the second connection after: $TBR · trap A outerTx(Dev): [$TAN] · inside inner: $TAIN · $TACMP · Initiating transaction rollback · after: $TAR · fixb viaProxy(Nina): [$FBN], rolled back, after: $FBR · visibility: the attribute on $VATT of 4; protected [$VPN] and package-private [$VKN] each rolled back; private: $VPRI -> $VNPE; WARN lines $VWARN · jdbc: $J1 · $J2 · $J3 · $J4 (gap $JGAP) · final B: exit $FBE, $FBC1 <- $FBC2 · xcheck: $X09 · exercise: [$EXBN] -> $EXBR; [$EXSN] -> $EXSR ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = '0 0' ] || die "a capture's raw output held a token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] && [ "$(raw "$TOKENB" "$f")" = 0 ] || die "$f holds a token, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '\$Proxy[0-9]|SessionImpl\([0-9]|scanning in [0-9]+ ms' "$f" || die "$f holds a proxy number, an EntityManager's identity or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.t' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked proxy number, identity or generated name, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20020-20029 at the end - TiffinBox bound 20020, 20021 (it never listened: B), 20022 and stopped; 20029 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit23: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20020-20022"
