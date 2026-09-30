#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
# Receipts for "Write Your Own Starter" (Course 5 · Section 2). Two projects of this unit's own - a starter and a
# program that has never seen TiffinBox - and six captures, each run three times and hashed:
#   starter   the starter's four files; the configuration class and its properties record, as written; `mvn install`
#             into this unit's own repository ($M2); the jar's files; the metadata file inside it
#   consumer  lunch-counter: its two dependencies and its one source file; the build; the jar it got from $M2; the
#             class path its manifest names, and the two jars on it that carry an imports file; the run, then the same
#             run with one property
#   report    the same run with --debug: the report's four lists counted, where the starter's class and its one @Bean
#             method land in them, and every line of both imports files, filed by that report
#   hook      a class loader that writes down who asks for the imports file: once, from inside the row-2 hook, and
#             it hands back both files
#   backoff   A lunch-counter as shipped · B plus one Kitchen bean of its own (one file) · A' = A re-run (the file
#             deleted again): all three built and run with the same two commands, in one working copy
#   scan      the break: C TiffinBoxApp's shape - @Configuration, @EnableAutoConfiguration and a plain
#             @ComponentScan("com.tiffinbox"), checked against the living anchor, ../c5-tiffinbox - plus a Kitchen of its own ·
#             D @SpringBootApplication with the same root and the same Kitchen
# Every number the video says is asserted at the bottom by a check that can fail, and cap() DIES when a capture's md5
# differs from receipts.md5 (`./receipts.sh --publish` rewrites that file, and is the only thing that does).
# Nothing here writes into another unit's folder, and c5-tiffinbox is not touched: the starter and its consumer are
# their own projects, built where they stand (their target/ folders are ignored), and B is built in a copy under
# .harness/. No port is used: lunch-counter has no web layer, and TiffinBox is never served here (18720-18729 stay free).
# Filters and masks (README.md declares each): a run's own lines are kept, and the report's entry for the starter's one
# @Bean method where the capture is about it. Everything else a run printed - Boot's banner, its log lines, the rest of
# the condition report - is left out and COUNTED, by kind, on the run's own trailer line ("exit 0 · … N lines not shown:
# Boot's banner 10 · its log 3 …"); show() dies if the kinds do not add up to the whole output. The one mask: the spy
# prints a jar's file name where the class loader gave a whole URL (String.replaceAll, in harness/spy/WhoReads.java).
# No token is masked by awk: nothing volatile (a time, a pid, a path) reaches a kept line.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the starter's install in $M2 and lunch-counter's target/, and one would
# corrupt the other. No JVM here outlives its command (nothing is served), so the exit trap only drops the lock.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
trap 'trap "" INT TERM; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() and the build lines speak to the terminal, even inside a capture
M2="$PWD/.m2-demo"
IMPORTS=META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
S=tiffinbox-spring-boot-starter
LC=lunch-counter
LIB=$LC/target/lib
PUBLISH=0; [ "$1" = "--publish" ] && PUBLISH=1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 expected; JAVA_HOME gives: $(java -version 2>&1 | head -1)"

rm -rf .harness; mkdir -p .harness
MVNLOG="$PWD/.harness/mvn.log"
# mvnq DIR GOALS...: offline first, from this unit's own repository; Central once, only if that fails. Maven's own lines
# carry times and paths, so they go to .harness/mvn.log; a capture keeps the exit code, and the terminal says, build by
# build, whether it ran offline (offline: yes / no), so a run that went online is never silent.
mvnq() { local d=$1 how=yes; shift
  (cd "$d" && mvn -o -q -B -DskipTests -Dmaven.repo.local="$M2" "$@" >> "$MVNLOG" 2>&1) \
    || { how="no - the offline build failed, so Maven Central was asked"
         (cd "$d" && mvn -q -B -DskipTests -Dmaven.repo.local="$M2" "$@" >> "$MVNLOG" 2>&1) \
           || { echo "  built $d ($*) · offline: $how - and that failed too" >&3; return 1; }; }
  echo "  built $d ($*) · offline: $how" >&3; }

# cap NAME FUNCTION: three runs, one md5, or the script dies. A capture that differs from receipts.md5 is printed first,
# with the reason to suspect, and then the script DIES: the panel on screen is not what this machine produced.
unpublished=""
cap() { local nm=$1 h pub; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ "$PUBLISH" = 1 ]; then printf '  %-9s md5 %s  3/3  (publishing)\n' "$nm" "$h"; published="$published$nm $h"$'\n'
  elif [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpublished="$unpublished $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect a different JDK, Boot or Maven, an edited source, or this machine; diff .r-$nm.out against its block in README.md"; fi; }

# ---- helpers over one run's raw output -----------------------------------------------------------------------------
# run RAW CMD...: run it, keep stdout+stderr in RAW and the exit code in $ec.
run() { local raw=$1; shift; ec=0; "$@" > "$raw" 2>&1 || ec=$?; }
# own RAW: the run's own lines - everything that is not Boot's banner, not a log line (a timestamp first), and not the
# condition report (from its logger's line to the next log line). The banner is the ten lines from the blank line above
# its art to the blank line below ":: Spring Boot ::", recognised by both ends; a program may print before it.
own() { awk 'FNR == NR { if (!b && /^ :: Spring Boot ::/ && FNR > 8) b = FNR; art[FNR] = $0; next }
       FNR == 1 { if (b && art[b - 7] ~ /^  \.   ____/ && art[b - 8] == "" && art[b + 1] == "") { from = b - 8; to = b + 1 } }
       from && FNR >= from && FNR <= to { next }
       /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { inrep = ($0 ~ /ConditionEvaluationReportLogger *: *$/); next }
       inrep { next }
       { print }' "$1" "$1"; }
# body RAW: the condition report alone, from its title to the last line before the next log line.
body() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { inrep = ($0 ~ /ConditionEvaluationReportLogger *: *$/); next }
              inrep' "$1"; }
# section RAW p|n|x|u: the lines of one of the report's four lists.
section() { body "$1" | awk -v want="$2" '/^Positive matches:$/ { s = "p"; next } /^Negative matches:$/ { s = "n"; next }
  /^Exclusions:$/ { s = "x"; next } /^Unconditional classes:$/ { s = "u"; next } s == want'; }
# lists RAW: the report's lists, counted - entries at its first indent (three spaces) under the matches, excluded classes
# and unconditional classes at four ("None" is not a class).
lists() { echo "the report's $(body "$1" | grep -cE '^(Positive matches|Negative matches|Exclusions|Unconditional classes):$') lists: positive matches $(section "$1" p | grep -c '^   [A-Za-z]') · negative matches $(section "$1" n | grep -c '^   [A-Za-z]') · exclusions $(section "$1" x | grep -E '^    [A-Za-z]' | grep -vc '^    None$') · unconditional classes $(section "$1" u | grep -c '^    [a-z]')"; }
# kitchen RAW: the report's entry for the starter's one @Bean method, whichever list it is in (up to its blank line).
kitchen() { body "$1" | awk '/^   KitchenAutoConfiguration#kitchen( matched)?:$/ { f = 1 } f && !NF { exit } f'; }
# parts RAW: how the run's lines divide - "banner log report own", where report is every line of the condition report
# after its logger's line. The four must add up to the whole file, or the filters above are wrong.
parts() { awk 'FNR == NR { if (!b && /^ :: Spring Boot ::/ && FNR > 8) b = FNR; art[FNR] = $0; next }
       FNR == 1 { if (b && art[b - 7] ~ /^  \.   ____/ && art[b - 8] == "" && art[b + 1] == "") { from = b - 8; to = b + 1 } }
       from && FNR >= from && FNR <= to { ban++; next }
       /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { inrep = ($0 ~ /ConditionEvaluationReportLogger *: *$/); log_++; next }
       inrep { rep++; next }
       { own++ }
       END { printf "%d %d %d %d %d\n", ban, log_, rep, own, FNR }' "$1" "$1"; }
# show RAW [report]: a run as the video shows it - its own lines, the report's entry for the starter's @Bean method when
# asked, then one trailer: the exit code, and every line NOT shown, counted by kind.
show() { local raw=$1 kl=0 ban lg rep own all
  own "$raw"
  if [ "$2" = report ]; then kitchen "$raw"; kl=$(kitchen "$raw" | wc -l | tr -d ' '); fi
  read -r ban lg rep own all < <(parts "$raw")
  [ $((ban + lg + rep + own)) = "$all" ] || die "the filters do not account for every line of $raw"
  printf 'exit %s · … %d lines not shown: ' "$ec" $((ban + lg + rep - kl))
  { [ "$ban" -gt 0 ] && printf "Boot's banner %d\n" "$ban"; [ "$lg" -gt 0 ] && printf 'its log %d\n' "$lg"
    [ $((rep - kl)) -gt 0 ] && printf 'the rest of its report %d\n' $((rep - kl)); true; } | paste -sd'|' - | sed 's/|/ · /g; s/$/ …/'; }
# src FILE: a Java file from its first annotation on (the package and import lines above it are the only lines cut).
src() { awk '/^@/ { f = 1 } f' "$1"; }
# deps POM: each <dependency> as groupId:artifactId[:version], in the order the POM declares them.
deps() { awk '/<dependency>/ { g = a = v = ""; d = 1 } d && /<groupId>/ { g = $0; gsub(/.*<groupId>|<\/groupId>.*/, "", g) }
  d && /<artifactId>/ { a = $0; gsub(/.*<artifactId>|<\/artifactId>.*/, "", a) } d && /<version>/ { v = $0; gsub(/.*<version>|<\/version>.*/, "", v) }
  /<\/dependency>/ { d = 0; print "  " g ":" a (v == "" ? "" : ":" v) }' "$1"; }
# classes JAR: how many .class files it holds.
classes() { unzip -Z1 "$1" | grep -c '\.class$' || true; }

# ---- starter: the files, the class, install, the jar ----------------------------------------------------------------
starter() { local J=$S/target/$S-1.0.0.jar I="$M2/com/tiffinbox/$S/1.0.0"
  echo "the starter's files, pom.xml aside ($S/):"
  (cd $S && find src -type f | sort | sed 's/^/  /')
  echo "the imports file, whole ($(wc -l < $S/src/main/resources/$IMPORTS | tr -d ' ') line):"
  sed 's/^/  /' $S/src/main/resources/$IMPORTS
  echo "KitchenAutoConfiguration.java, from its first annotation:"
  src $S/src/main/java/com/tiffinbox/autoconfigure/KitchenAutoConfiguration.java | sed 's/^/  /'
  echo "KitchenProperties.java, from its first annotation:"
  src $S/src/main/java/com/tiffinbox/autoconfigure/KitchenProperties.java | sed 's/^/  /'
  # a stale copy in $M2 must not satisfy the check below: the install has to put it there, now
  rm -rf "$M2/com/tiffinbox/$S"
  echo "\$ (cd $S && mvn -q -DskipTests clean install -Dmaven.repo.local=\"\$M2\")"
  ec=0; mvnq $S clean install || ec=$?; echo "exit $ec"
  echo "\$M2/com/tiffinbox/$S/1.0.0/ now holds: $(ls "$I" 2> /dev/null | grep -E '\.(jar|pom)$' | paste -sd' ' - | sed 's/ / · /g')"
  cmp -s "$J" "$I/$S-1.0.0.jar" && echo "the jar there is byte for byte target/$S-1.0.0.jar: yes" || echo "the jar there is byte for byte target/$S-1.0.0.jar: NO"
  echo "the jar's files, directories aside ($(unzip -Z1 "$J" | grep -vc '/$')):"
  unzip -Z1 "$J" | grep -v '/$' | sort | sed 's/^/  /'
  echo "its .class files: $(classes "$J")"
  unzip -p "$J" META-INF/spring-configuration-metadata.json | awk '
    /"groups": \[/ { s = "g" } /"properties": \[/ { s = "p" } /"hints": \[/ { s = "h" }
    s == "g" && /"name":/ { groups++ }
    s == "p" && /"name":/ { n = $0; sub(/^[^:]*: "/, "", n); sub(/",?$/, "", n); names[++k] = n }
    s == "p" && /"type":/ { t = $0; sub(/^[^:]*: "/, "", t); sub(/",?$/, "", t); types[k] = t }
    s == "p" && /"description":/ { d = $0; sub(/^[^:]*: /, "", d); sub(/,$/, "", d); descs[k] = d }
    s == "p" && /"defaultValue":/ { v = $0; sub(/^[^:]*: /, "", v); sub(/,$/, "", v); defs[k] = v }
    END { printf "inside it, META-INF/spring-configuration-metadata.json: groups %d · properties %d\n", groups, k
          for (i = 1; i <= k; i++) printf "  %-24s %-18s default %-20s %s\n", names[i], types[i], defs[i], descs[i] }'; }
cap starter starter

# ---- consumer: lunch-counter, built against the installed starter, and run --------------------------------------------
consumer() { local raw=.harness/consumer.raw J=$LC/target/lunch-counter-1.0.0.jar
  echo "lunch-counter's dependencies, as its pom.xml declares them ($(deps $LC/pom.xml | wc -l | tr -d ' ')):"
  deps $LC/pom.xml
  echo "its sources: $(cd $LC && find src -type f | wc -l | tr -d ' ') file · @Bean methods in them: $(cat $(find $LC/src -name '*.java') | grep -c '@Bean' || true)"
  (cd $LC && find src -type f | sort | sed 's/^/  /')
  echo "LunchCounter.java, from its first annotation:"
  src $LC/src/main/java/com/lunchcounter/LunchCounter.java | sed 's/^/  /'
  echo "\$ (cd $LC && mvn -q -DskipTests clean package -Dmaven.repo.local=\"\$M2\")"
  ec=0; mvnq $LC clean package || ec=$?; echo "exit $ec"
  cmp -s "$LIB/$S-1.0.0.jar" "$S/target/$S-1.0.0.jar" && echo "target/lib/$S-1.0.0.jar is byte for byte the jar the starter's build made: yes" \
    || echo "target/lib/$S-1.0.0.jar is byte for byte the jar the starter's build made: NO"
  echo "the class path, as the jar's manifest names it: $(unzip -p "$J" META-INF/MANIFEST.MF | tr -d '\r' | awk '/^Class-Path:/ { c = 1; s = substr($0, 13); next } c && /^ / { s = s substr($0, 2); next } { c = 0 } END { print s }' | tr ' ' '\n' | grep -c '^lib/') jars, all in target/lib · TiffinBox's own jars among them: $(ls $LIB | grep -cE '^tiffinbox-(core|web)-' || true)"
  echo ".class files: $S-1.0.0.jar $(classes $LIB/$S-1.0.0.jar) · Boot's own starters on this class path: $(for j in $LIB/spring-boot-starter*.jar; do printf '%s %s · ' "$(basename "$j")" "$(classes "$j")"; done | sed 's/ · $//')"
  echo "the jars on this class path holding $IMPORTS: $(for j in $J $LIB/*.jar; do unzip -l "$j" "$IMPORTS" > /dev/null 2>&1 && echo x; done | wc -l | tr -d ' ') of $(( $(ls $LIB/*.jar | wc -l) + 1 ))"
  for j in $J $LIB/*.jar; do unzip -l "$j" "$IMPORTS" > /dev/null 2>&1 || continue
    printf '  %-40s %2d line%s\n' "$(basename "$j")" "$(unzip -p "$j" "$IMPORTS" | grep -v '^#' | grep -c .)" "$( [ "$(unzip -p "$j" "$IMPORTS" | grep -v '^#' | grep -c .)" = 1 ] || echo s)"; done
  echo "\$ java -jar target/lunch-counter-1.0.0.jar"
  run $raw java -jar $J; show $raw
  echo "\$ java -jar target/lunch-counter-1.0.0.jar --tiffinbox.kitchen.cooks=5"
  run $raw java -jar $J --tiffinbox.kitchen.cooks=5; show $raw; }
cap consumer consumer

# ---- report: the same run with --debug -------------------------------------------------------------------------------
report() { local raw=.harness/report.raw J=$LC/target/lunch-counter-1.0.0.jar j e s u m no
  echo "\$ java -jar target/lunch-counter-1.0.0.jar --debug"
  run $raw java -jar $J --debug; show $raw report
  lists $raw
  echo "the starter's class in this report: under unconditional classes $(section $raw u | grep -cxF '    com.tiffinbox.autoconfigure.KitchenAutoConfiguration' || true) · as a class under positive or negative matches $(body $raw | grep -cxE '   KitchenAutoConfiguration( matched)?:' || true) · its @Bean method, #kitchen, under positive matches $(section $raw p | grep -cxF '   KitchenAutoConfiguration#kitchen matched:' || true)"
  echo "every line of both imports files, as this report files it:"
  for j in $J $LIB/*.jar; do unzip -l "$j" "$IMPORTS" > /dev/null 2>&1 || continue
    u=0; m=0; no=0; n=0; out=0
    for e in $(unzip -p "$j" "$IMPORTS" | grep -v '^#' | grep .); do n=$((n + 1)); s=${e##*.}
      if section $raw u | grep -qxF "    $e"; then u=$((u + 1))
      elif section $raw p | grep -qxF "   $s matched:"; then m=$((m + 1))
      elif section $raw n | grep -qxF "   $s:"; then no=$((no + 1))
      else out=$((out + 1)); fi; done
    printf '  %-40s %2d: unconditional %d · matched %d · did not match %d · not in the report %d\n' "$(basename "$j")" "$n" "$u" "$m" "$no" "$out"
  done; }
cap report report

# ---- hook: who asks for the imports file ------------------------------------------------------------------------------
javac -cp "$(ls $LIB/*.jar | paste -sd: -)" -d .harness/classes $(find harness -name '*.java' | sort) || die "the harness did not compile"
CP=".harness/classes:$LC/target/lunch-counter-1.0.0.jar:$(ls $LIB/*.jar | paste -sd: -)"
printf '%s\n' "$CP" > .harness/classpath      # README.md builds its $CP from this file
cpline() { echo "\$CP: .harness/classes (harness/, compiled) + $LC/target/lunch-counter-1.0.0.jar + the $(ls $LIB/*.jar | wc -l | tr -d ' ') jars in $LIB · TiffinBox's own jars on it: $(ls $LIB | grep -cE '^tiffinbox-(core|web)-' || true)"; }
hook() { local raw=.harness/hook.raw
  cpline
  echo "\$ java -cp \"\$CP\" spy.WhoReads"
  run $raw java -cp "$CP" spy.WhoReads; show $raw; }
cap hook hook

# ---- backoff: A / B / A' in ONE working copy of lunch-counter ---------------------------------------------------------
backoff() { local W=.harness/backoff raw=.harness/backoff.raw k
  rm -rf $W; mkdir -p $W; rsync -a --exclude target $LC/ $W/$LC/
  for k in "A   lunch-counter as shipped" "B   plus one file, src/main/java/com/lunchcounter/OwnKitchen.java" "A′  that file deleted again: A, re-run"; do
    case "$k" in B*) cp own-kitchen/OwnKitchen.java $W/$LC/src/main/java/com/lunchcounter/OwnKitchen.java ;;
                 A′*) rm $W/$LC/src/main/java/com/lunchcounter/OwnKitchen.java ;; esac
    echo "$k"
    case "$k" in B*) echo "  OwnKitchen.java, from its first annotation:"; src own-kitchen/OwnKitchen.java | sed 's/^/    /' ;; esac
    echo "  its sources: $(cd $W/$LC && find src -name '*.java' | sort | sed 's|.*/||' | paste -sd' ' -)"
    ec=0; mvnq $W/$LC clean package || ec=$?; echo "  built with lunch-counter's own mvn command: exit $ec"
    echo "\$ java -jar target/lunch-counter-1.0.0.jar --debug"
    run $raw java -jar $W/$LC/target/lunch-counter-1.0.0.jar --debug; show $raw report
  done; }
cap backoff backoff

# ---- scan: the break (C) and the fix (D) ------------------------------------------------------------------------------
scan() { local raw=.harness/scan.raw c f
  cpline
  for c in "C   TiffinBoxApp's shape - a plain @ComponentScan of com.tiffinbox - plus a Kitchen of its own:TiffinBoxShape" \
           "D   the same root and the same Kitchen, through @SpringBootApplication:SpringBootShape"; do
    f=harness/trap/${c##*:}.java
    echo "${c%:*}"
    echo "  $f: $(grep -E '^@' $f | paste -sd' ' - | sed 's/ @/ · @/g') · @Bean $(grep -A1 '^    @Bean' $f | tail -1 | sed 's/^ *//; s/ *{$//')"
    echo "\$ java -cp \"\$CP\" trap.${c##*:} --debug"
    run $raw java -cp "$CP" trap.${c##*:} --debug; show $raw report
  done; }
cap scan scan

[ "$PUBLISH" = 1 ] && { printf '%s' "$published" > receipts.md5; echo "  receipts.md5 written: $(wc -l < receipts.md5 | tr -d ' ') captures"; }

# ---- every number the video says, asserted ------------------------------------------------------------------------------
echo
# x NAME LINE: that exact line is in the capture. n NAME COUNT REGEX: the regex matches exactly COUNT lines.
x() { grep -qxF -- "$2" ".r-$1.out" || die "$1: expected the line [$2]"; }
n() { local c; c=$(grep -cE -- "$3" ".r-$1.out" || true); [ "$c" = "$2" ] || die "$1: expected $2 line(s) matching /$3/, found $c"; }
# blk NAME FROM TO: the lines after the one starting with FROM, up to the one starting with TO (or the end).
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
# ran NAME COMMAND: what one command printed - the lines after that exact "$ ..." line, up to the next command line.
ran() { awk -v a="$2" 'f && /^\$ / { exit } $0 == a { f = 1; next } f' ".r-$1.out"; }
K=com.tiffinbox.kitchen.Kitchen

# starter: four files - three classes and a one-line file; one condition, bare; the defaults 3 and "TiffinBox kitchen"
[ "$(blk starter "the starter's files" "the imports file")" = "$(printf '  %s\n' src/main/java/com/tiffinbox/autoconfigure/KitchenAutoConfiguration.java src/main/java/com/tiffinbox/autoconfigure/KitchenProperties.java src/main/java/com/tiffinbox/kitchen/Kitchen.java "src/main/resources/$IMPORTS")" ] \
  || die "starter: expected exactly four files - three classes and the imports file"
x starter "the imports file, whole (1 line):"; x starter "  com.tiffinbox.autoconfigure.KitchenAutoConfiguration"
x starter "  @AutoConfiguration"; x starter "  @EnableConfigurationProperties(KitchenProperties.class)"
x starter "      @ConditionalOnMissingBean"; x starter "      Kitchen kitchen(KitchenProperties props) {"
n starter 1 '@Conditional'
x starter '  @ConfigurationProperties("tiffinbox.kitchen")'
x starter '  public record KitchenProperties(@DefaultValue("TiffinBox kitchen") String name, @DefaultValue("3") int cooks) {'
x starter "exit 0"
x starter "\$M2/com/tiffinbox/$S/1.0.0/ now holds: $S-1.0.0.jar · $S-1.0.0.pom"
x starter "the jar there is byte for byte target/$S-1.0.0.jar: yes"
x starter "the jar's files, directories aside (8):"; x starter "its .class files: 3"
x starter "  META-INF/spring-configuration-metadata.json"; x starter "  $IMPORTS"
x starter "inside it, META-INF/spring-configuration-metadata.json: groups 1 · properties 2"
n starter 1 '^  tiffinbox\.kitchen\.cooks +java\.lang\.Integer +default 3 +"how many cooks it has"$'
n starter 1 '^  tiffinbox\.kitchen\.name +java\.lang\.String +default "TiffinBox kitchen" +"what the kitchen is called"$'
echo "  starter: 4 files = 3 classes + a 1-line imports file; 1 condition (@ConditionalOnMissingBean, bare); install exit 0 into \$M2, byte for byte; the jar: 8 files, 3 classes, metadata 2 keys (defaults 3, \"TiffinBox kitchen\")"

# consumer: two dependencies, one class with no @Bean; the jar it got is the starter's; 3 cooks, then 5 with one property
[ "$(blk consumer "lunch-counter's dependencies" "its sources")" = "$(printf '  %s\n' org.springframework.boot:spring-boot-starter com.tiffinbox:$S:1.0.0)" ] || die "consumer: expected exactly the two dependencies"
x consumer "lunch-counter's dependencies, as its pom.xml declares them (2):"
x consumer "its sources: 1 file · @Bean methods in them: 0"
x consumer "exit 0"
x consumer "target/lib/$S-1.0.0.jar is byte for byte the jar the starter's build made: yes"
x consumer "the class path, as the jar's manifest names it: 22 jars, all in target/lib · TiffinBox's own jars among them: 0"
x consumer ".class files: $S-1.0.0.jar 3 · Boot's own starters on this class path: spring-boot-starter-4.1.1.jar 0 · spring-boot-starter-logging-4.1.1.jar 0"
[ "$(ran consumer '$ java -jar target/lunch-counter-1.0.0.jar')" = \
  "$(printf '%s\n' 'Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks' "exit 0 · … 13 lines not shown: Boot's banner 10 · its log 3 …")" ] \
  || die "consumer: expected the starter's kitchen, 3 cooks, exit 0, and nothing else of lunch-counter's own"
[ "$(ran consumer '$ java -jar target/lunch-counter-1.0.0.jar --tiffinbox.kitchen.cooks=5')" = \
  "$(printf '%s\n' 'Kitchen beans: [kitchen] -> TiffinBox kitchen with 5 cooks' "exit 0 · … 13 lines not shown: Boot's banner 10 · its log 3 …")" ] \
  || die "consumer: expected the same kitchen with 5 cooks, exit 0"
n consumer 2 '^exit 0 · '
x consumer "the jars on this class path holding $IMPORTS: 2 of 23"
n consumer 1 '^  spring-boot-autoconfigure-4\.1\.1\.jar +12 lines$'
n consumer 1 "^  $S-1\.0\.0\.jar +1 line$"
echo "  consumer: 2 dependencies, 1 class, 0 @Bean methods; the starter's jar byte for byte; 22 jars, TiffinBox's 0; Boot's starters 0 classes, ours 3; 2 of 23 jars carry an imports file (12 lines, 1 line); kitchen 3 cooks, then 5"

# report: 4 lists; the method matched, the class unconditional; both files, every line filed
x report 'Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks'
x report "the report's 4 lists: positive matches 16 · negative matches 13 · exclusions 0 · unconditional classes 7"
x report "   KitchenAutoConfiguration#kitchen matched:"
x report "      - @ConditionalOnMissingBean (types: $K; SearchStrategy: all) did not find any beans (OnBeanCondition)"
x report "the starter's class in this report: under unconditional classes 1 · as a class under positive or negative matches 0 · its @Bean method, #kitchen, under positive matches 1"
n report 1 '^  spring-boot-autoconfigure-4\.1\.1\.jar +12: unconditional 6 · matched 3 · did not match 3 · not in the report 0$'
n report 1 "^  $S-1\.0\.0\.jar +1: unconditional 1 · matched 0 · did not match 0 · not in the report 0$"
n report 1 '^exit 0 · '
echo "  report: 4 lists 16/13/0/7; #kitchen matched, did not find any beans; the class: unconditional; both files' 12 + 1 lines, all 13 filed"

# hook: one request, from inside the row-2 hook; both files handed back and taken
x hook "requests for $IMPORTS: 1"
x hook "  1  asked by ImportCandidates.findUrlsInClasspath, called from ImportCandidates.load · inside the row-2 hook: yes"
x hook "     files handed back 2 · taken 2: spring-boot-autoconfigure-4.1.1.jar, $S-1.0.0.jar"
x hook "     the stack from the hook down, 11 frames:"
[ "$(blk hook "     the stack from the hook down" "exit" | head -1)" = "       ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry" ] || die "hook: the stack does not start at the row-2 hook"
x hook "       AutoConfigurationImportSelector.getCandidateConfigurations"; x hook "       ImportCandidates.load"
x hook "\$CP: .harness/classes (harness/, compiled) + $LC/target/lunch-counter-1.0.0.jar + the 22 jars in $LIB · TiffinBox's own jars on it: 0"
n hook 1 '^exit 0 · '
echo "  hook: asked for 1x, inside the row-2 hook (11 frames, through AutoConfigurationImportSelector); 2 files handed back, 2 taken"

# backoff: A the starter's kitchen · B one file of yours, and it backs off · A' = A, line for line
A=$(blk backoff "A   " "B   " | grep -v '^  its sources'); A2=$(blk backoff "A′  " "")
[ "$A" = "$(echo "$A2" | grep -v '^  its sources')" ] || die "backoff: A' is not A"
blk backoff "A   " "B   " | grep -qxF 'Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks' || die "backoff A: the starter's kitchen"
blk backoff "A   " "B   " | grep -qxF "      - @ConditionalOnMissingBean (types: $K; SearchStrategy: all) did not find any beans (OnBeanCondition)" || die "backoff A: did not find any beans"
blk backoff "B   " "A′  " | grep -qxF '  its sources: LunchCounter.java OwnKitchen.java' || die "backoff B: one file more"
blk backoff "B   " "A′  " | grep -qxF "Kitchen beans: [myKitchen] -> Lunch counter's own kitchen with 2 cooks" || die "backoff B: yours alone"
blk backoff "B   " "A′  " | grep -qxF "         - @ConditionalOnMissingBean (types: $K; SearchStrategy: all) found beans of type '$K' myKitchen (OnBeanCondition)" || die "backoff B: found myKitchen"
n backoff 3 '^  built with lunch-counter.s own mvn command: exit 0$'; n backoff 3 '^exit 0 · '
echo "  backoff: A [kitchen] 3 cooks, did not find any beans · B one file more: [myKitchen], found beans … myKitchen · A' = A, line for line"

# scan: C two kitchens, the report unchanged · D one, the filter says match. C's shape is checked against the LIVING
# anchor: its TiffinBoxApp must still scan without @SpringBootApplication, and its scan-shaping annotations - whatever
# arguments @ComponentScan now carries - must be exactly TiffinBoxShape's.
APP=../c5-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
[ -f "$APP" ] || die "scan: $APP is missing"
! grep -q '^@SpringBootApplication' "$APP" || die "scan: the anchor's TiffinBoxApp now carries @SpringBootApplication - C is no longer TiffinBox's shape"
[ "$(grep -E '^@' "$APP" | grep -xE '@Configuration|@EnableAutoConfiguration|@ComponentScan(\(.*\))?' | sort)" = \
  "$(grep -E '^@' harness/trap/TiffinBoxShape.java | sort)" ] || die "scan: TiffinBoxShape does not carry the anchor's three scan-shaping annotations"
C=$(blk scan "C   " "D   "); D=$(blk scan "D   " "")
for l in '  harness/trap/TiffinBoxShape.java: @Configuration · @EnableAutoConfiguration · @ComponentScan("com.tiffinbox") · @Bean Kitchen myKitchen()' \
         "KitchenAutoConfiguration carries @Component: @AutoConfiguration → @Configuration → @Component" \
         "its scan: basePackages [com.tiffinbox] · exclude filters []" \
         "Kitchen beans, in the order they were registered: [kitchen, myKitchen]" \
         "the starter's configuration class, registered as: kitchenAutoConfiguration" \
         "asking for one Kitchen: NoUniqueBeanDefinitionException: No qualifying bean of type '$K' available: expected single matching bean but found 2: kitchen,myKitchen" \
         "      - @ConditionalOnMissingBean (types: $K; SearchStrategy: all) did not find any beans (OnBeanCondition)"; do
  echo "$C" | grep -qxF -- "$l" || die "scan C: expected [$l]"; done
for l in '  harness/trap/SpringBootShape.java: @SpringBootApplication(scanBasePackages = "com.tiffinbox") · @Bean Kitchen myKitchen()' \
         "its scan: basePackages [com.tiffinbox] · exclude filters [TypeExcludeFilter, AutoConfigurationExcludeFilter]" \
         "AutoConfigurationExcludeFilter, asked about com.tiffinbox.autoconfigure.KitchenAutoConfiguration: match true" \
         "Kitchen beans, in the order they were registered: [myKitchen]" \
         "the starter's configuration class, registered as: com.tiffinbox.autoconfigure.KitchenAutoConfiguration" \
         "asking for one Kitchen: TiffinBox's own kitchen with 2 cooks" \
         "         - @ConditionalOnMissingBean (types: $K; SearchStrategy: all) found beans of type '$K' myKitchen (OnBeanCondition)"; do
  echo "$D" | grep -qxF -- "$l" || die "scan D: expected [$l]"; done
n scan 2 '^exit 0 · '
echo "  scan: C a plain scan of com.tiffinbox - [kitchen, myKitchen], registered as kitchenAutoConfiguration, NoUniqueBeanDefinitionException, the report: did not find any beans · D @SpringBootApplication, same root - the filter: match true, [myKitchen], registered by its full name"
[ -z "$unpublished" ] || die "no published hash for:$unpublished - check the captures, then run ./receipts.sh --publish"
echo "  receipts: every capture = published, every check passed"
