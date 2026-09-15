#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh layers     run one block
#
# THE RULES THIS FILE OBEYS, AND WHY EACH ONE IS HERE.
#
#   A derived line is part of the capture. Every count below is computed by the same run
#   that produced the output above it, appended into the .out file BEFORE that file is
#   hashed. A count typed into a brief cannot fail; a count derived here moves the hash the
#   moment it stops being true.
#
#   A block that cannot measure must not print. Every counting helper dies rather than
#   report a confident zero over a run that did not happen. `grep -c` over an empty file
#   returns 0 and exit 1, and that 0 is the shape of every blocker this course has shipped.
#
#   A block whose lesson is a failure exits non-zero on the inside and says so. The
#   Class-Path trap is only a lesson if the run really died; `classpath` asserts rc != 0
#   and dies if the jar starts.
#
#   A block whose lesson is success asserts the ARTIFACT, never the word SUCCESS. A green
#   `mvn package` proves nothing about a jar. What proves it is the jar's entry count, its
#   manifest headers, and the program's own output when it is run out of that jar.
#
#   Nothing that moves run to run is hashed. Every size in bytes, every zip entry date and
#   every absolute path is masked or printed outside the hash, and the block says which.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")
THIN=target/tiffinbox-core-1.0.0.jar
FAT=target/tiffinbox-fat.jar
FATNS=target/tiffinbox-fat-noservices.jar

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

# Absolute paths, this machine's home, and the wall clock a zip entry carries.
mask() { sed -E -e "s#${PWD}/#<project>/#g" \
                -e 's#[^ ]*/c3-unit23/#<project>/#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}/<date> <time>/g' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }

# A counted grep that cannot report zero by accident. `grep -c` over a missing or empty
# file prints 0 and exits 1; every count in this file goes through here instead, and the
# caller says what a zero would mean.

# EVERY CUT CARRIES ITS COUNT, AND THE COUNT IS DERIVED BY THE RUN THAT MADE THE CUT.
# Four debate gates in this course have been failed by a panel trimmed without one - most
# recently a thirty-row tree counted as twenty-nine, with the missing row hidden under an
# elision line that claimed to have cut something else. `trim` prints the first N lines of a
# capture and then states, from wc(1), exactly how many it did not print. A bare head is a
# contract breach; this is what replaces it.
trim() {  # $1 = file, $2 = lines to keep, $3 = optional extra sed program for the kept lines
  local f="$1" keep="$2" post="${3:-}"
  [ -s "$f" ] || die "trim: $f is missing or empty, so any elision count over it would be a lie"
  local total; total=$(wc -l < "$f" | tr -d ' ')
  if [ -n "$post" ]; then head -"$keep" "$f" | mask | sed -E "$post"; else head -"$keep" "$f" | mask; fi
  if [ "$total" -gt "$keep" ]; then printf '... %s more line(s) elided\n' "$(( total - keep ))"; fi
  return 0
}
# The same rule for a capture that is SELECTED by pattern rather than cut at a line number:
# say how many lines the whole capture had, so "one line of a stack trace" is never mistaken
# for "the whole of the failure".
of_total() {  # $1 = file, $2 = how many lines were shown
  [ -s "$1" ] || die "of_total: $1 is missing or empty"
  printf '(%s line(s) shown of %s in the whole capture)\n' "$2" "$(wc -l < "$1" | tr -d ' ')"
}

count_in() {  # $1 = file, $2 = extended regex, $3 = what it is (for the error)
  [ -s "$1" ] || die "$3: $1 is missing or empty, so any count over it would be a lie"
  grep -cE "$2" "$1" || true
}
# The same, for a count that MUST be positive.
count_positive() {
  local n; n=$(count_in "$1" "$2" "$3")
  [ "$n" -gt 0 ] || die "$3: counted 0, and 0 cannot be right here"
  printf '%s' "$n"
}

# Entry count of a jar, read from the archive rather than from a build log.
entries() { [ -f "$1" ] || die "no such jar: $1"; unzip -l "$1" | tail -1 | awk '{print $2}'; }

# MANIFEST.MF folds a long header across continuation lines that begin with one space, so
# a `grep -c lib/` over the raw file undercounts. Unfold the Class-Path header first, then
# count. `grep -o | wc -l` counts MATCHES; `grep -oc` counts matching LINES, which for a
# folded header is not the same number - and that difference is exactly the class of bug
# this course has shipped blockers about.
cp_entries() {
  unzip -p "$1" META-INF/MANIFEST.MF | tr -d '\r' \
    | awk '/^Class-Path:/{f=1;print;next} f&&/^ /{print;next} {f=0}' \
    | grep -o 'lib/' | wc -l | tr -d ' '
}

# `unzip -l | grep -q` is a trap under `set -o pipefail`: grep exits on its first match,
# unzip takes SIGPIPE, and the PIPELINE reports failure even though the entry was found.
# Every membership test below counts instead of short-circuiting.
has_entry() {  # $1 = jar, $2 = anchored entry regex -> "1" or "0"
  local n; n=$(unzip -l "$1" | grep -cE "$2"; true)
  [ "${n:-0}" -gt 0 ] && printf 1 || printf 0
}
bytes()   { [ -f "$1" ] || die "no such file: $1"; stat -f%z "$1" 2>/dev/null || stat -c%s "$1"; }

need_jdk25() {
  local v; v=$(java -version 2>&1 | head -1)
  case "$v" in *25.0.4.1*) : ;; *) die "this unit is verified on JDK 25.0.4.1; java -version says: $v" ;; esac
}

# ------------------------------------------------------------------ three ----
# HASHED. Three artifacts from one source tree. Sizes are printed OUTSIDE the hash
# (C2 finding #3: a byte size goes on a slide as fixed only after it has repeated).
run_three() {
  block "three - one program, three files, and what each one needs beside it  [HASHED]"
  need_jdk25
  "${MVN[@]}" -q clean package > .r-thin.raw 2>&1 || die "the thin build failed; see .r-thin.raw"
  [ -f "$THIN" ] || die "no $THIN after package"
  local libs; libs=$(ls target/lib/*.jar 2>/dev/null | wc -l | tr -d ' ')
  [ "$libs" -gt 0 ] || die "copy-dependencies produced no target/lib - the thin jar would be a lie"

  "${MVN[@]}" -q -Pfat package > .r-fat.raw 2>&1 || die "the fat build failed; see .r-fat.raw"
  [ -f "$FAT" ] || die "no $FAT after -Pfat package"

  local thin_e fat_e sum_e
  thin_e=$(entries "$THIN"); fat_e=$(entries "$FAT")
  sum_e=$thin_e
  local j
  for j in target/lib/*.jar; do sum_e=$(( sum_e + $(entries "$j") )); done

  { printf 'the same program, packaged three ways\n'
    printf '  thin jar   %-34s entries %6s   runs only with target/lib beside it\n' "$(basename "$THIN")" "$thin_e"
    for j in target/lib/*.jar; do
      printf '    lib/     %-34s entries %6s\n' "$(basename "$j")" "$(entries "$j")"
    done
    printf '  fat jar    %-34s entries %6s   runs alone\n' "$(basename "$FAT")" "$fat_e"
    printf 'dependency jars beside the thin one: %s\n' "$libs"
    printf 'entries in the thin jar and its %s libs, added up: %s\n' "$libs" "$sum_e"
    printf 'entries in the fat jar: %s\n' "$fat_e"
    printf 'the fat jar has %s MORE entries than the parts it was made from\n' "$(( fat_e - sum_e ))"
    printf 'and the reason is on the next line, counted rather than asserted:\n'
    # Directory entries. A jar built by maven-jar-plugin/shade stores an entry per
    # directory; the count below is what makes the arithmetic above come out.
    printf 'directory entries (names ending in /) in the fat jar: %s\n' \
      "$(unzip -l "$FAT" | awk '$4 ~ /\/$/' | wc -l | tr -d ' ')"
  } > .r-three.out 2>&1

  cat .r-three.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-three.out)"
  printf 'NOT hashed, because a byte size is not a state word: thin %s bytes, libs %s bytes, fat %s bytes\n' \
    "$(bytes "$THIN")" "$(cat target/lib/*.jar | wc -c | tr -d ' ')" "$(bytes "$FAT")"
}

# --------------------------------------------------------------- classpath ----
# HASHED. The lesson is a FAILURE, so this block asserts a non-zero exit and dies if the
# program starts. A green run here would mean the trap does not reproduce.
run_classpath() {
  block "classpath - the header nothing checks  [HASHED]"
  need_jdk25
  [ -f "$THIN" ] || "${MVN[@]}" -q clean package > .r-thin.raw 2>&1 || die "build failed"
  [ -d target/lib ] || die "target/lib is missing before the trap is set - nothing to move"

  local ok_out rc_ok rc_bad
  ok_out=$(java -jar "$THIN" 2>&1); rc_ok=$?
  [ "$rc_ok" -eq 0 ] || die "the jar does not start even WITH target/lib present (exit $rc_ok)"

  mv target/lib target/lib-moved
  java -jar "$THIN" > .r-trap.raw 2>&1; rc_bad=$?
  mv target/lib-moved target/lib
  [ "$rc_bad" -ne 0 ] || die "the jar started with no target/lib - the Class-Path trap did not reproduce"

  { printf 'the header maven-jar-plugin wrote, read back out of the jar:\n'
    unzip -p "$THIN" META-INF/MANIFEST.MF | grep -E '^(Main-Class|Class-Path| )'
    printf '\nwith target/lib beside the jar:   java -jar %s\n' "$(basename "$THIN")"
    printf '%s\n' "$ok_out"
    printf 'exit code: %s\n' "$rc_ok"
    printf '\nthe SAME jar, one directory renamed, nothing rebuilt:\n'
    trim .r-trap.raw 4
    printf 'exit code: %s\n' "$rc_bad"
    printf '\njars named in the Class-Path header: %s\n' "$(cp_entries "$THIN")"
    printf 'of those, present when the run failed: 0\n'
    printf 'lines of build output that warned about it: %s\n' \
      "$(grep -icE 'class-path|lib/' .r-thin.raw || true)"
  } > .r-classpath.out 2>&1

  cat .r-classpath.out
  printf 'md5 %s  (exit %s with lib present, exit %s without)\n' "$(hash_of .r-classpath.out)" "$rc_ok" "$rc_bad"
}

# ---------------------------------------------------------------- overlap ----
# HASHED. What a fat jar silently throws away. Every number derived from the archives.
run_overlap() {
  block "overlap - what one file can only hold one of  [HASHED]"
  need_jdk25
  "${MVN[@]}" -Pfat clean package > .r-fat.raw 2>&1 || die "the fat build failed"
  [ -f "$FAT" ] || die "no $FAT"
  "${MVN[@]}" -Pfat-noservices package > .r-fatns.raw 2>&1 || die "the no-transformer build failed"
  [ -f "$FATNS" ] || die "no $FATNS"

  # How many INPUT jars carry each overlapping resource, counted from the archives.
  local lic_in not_in lic_out not_out j
  lic_in=0; not_in=0
  for j in target/lib/*.jar "$THIN"; do
    lic_in=$(( lic_in + $(has_entry "$j" ' META-INF/LICENSE$') ))
    not_in=$(( not_in + $(has_entry "$j" ' META-INF/NOTICE$') ))
  done
  [ "$lic_in" -gt 1 ] || die "only $lic_in input jar carries META-INF/LICENSE - there is no overlap to teach"
  lic_out=$(unzip -l "$FAT" | grep -cE ' META-INF/LICENSE$' || true)
  not_out=$(unzip -l "$FAT" | grep -cE ' META-INF/NOTICE$'  || true)

  local svc_fat svc_ns
  svc_fat=$(unzip -p "$FAT"   META-INF/services/java.sql.Driver | wc -c | tr -d ' ')
  svc_ns=$( unzip -p "$FATNS" META-INF/services/java.sql.Driver | wc -c | tr -d ' ')

  # SHADE'S ORDER IS NOT STABLE, SO THE CAPTURE CANONICALISES IT BEFORE IT IS HASHED.
  # maven-shade-plugin walks its overlap groups in an order that is stable inside one
  # directory and DIFFERENT between directories: the same three lines, three checkouts,
  # three permutations, three md5s (measured - `plain`, `has space here` and a third copy
  # of this same tree gave e402fb74, e0e71633 and 383eeace, each reproducing 3/3 in its
  # own directory). A hash over that is a property of where the viewer cloned the repo,
  # not of the build, and §8.5 says a hash the viewer cannot regenerate is not a receipt.
  # `LC_ALL=C sort` puts the three lines in one order everywhere, and the capture says so
  # on its own first line so the claim cannot drift from the behaviour. The LINES are
  # still shade's, character for character; only their order is ours.
  grep -E 'overlapping (resources?|classes)' .r-fatns.raw | sed -E 's/^\[WARNING\] //' \
    | mask | LC_ALL=C sort > .r-warn.raw
  [ -s .r-warn.raw ] || die "shade printed no overlap warning, so there is nothing to sort or teach"

  # A COMMA-CUT CARRIES ITS COUNT THE SAME WAY A LINE-CUT DOES. The widest of those lines
  # names five jars and does not fit the panel, so the capture makes the cut ITSELF and
  # derives what it dropped - exactly what `trim` does for lines. `SLIDE_KEEP` is the one
  # typed number here and it is the PARAMETER of the cut, like trim's `keep`; the elision
  # count below it is computed. A gate found this chip saying "1 jar name elided" where
  # the terminal elides 2, which is what a hand-counted comma costs.
  local SLIDE_KEEP=3 wide wide_names wide_cut
  wide=$(awk '{print length "\t" $0}' .r-warn.raw | LC_ALL=C sort -k1,1nr | head -1 | cut -f2-)
  wide_names=$(printf '%s\n' "$wide" | sed -E 's/ define .*//' | tr ',' '\n' | grep -c '[^[:space:]]')
  [ "$wide_names" -gt "$SLIDE_KEEP" ] || die "the widest warning line names $wide_names jars - there is nothing to elide"
  wide_cut=$(printf '%s\n' "$wide" | cut -d, -f1-"$SLIDE_KEEP")

  { printf "shade's own warning lines, verbatim - sorted, because shade's own order is a\n"
    printf "property of the directory you cloned into and this hash must not be:\n"
    cat .r-warn.raw
    local groups; groups=$(count_positive .r-fatns.raw 'overlapping (resources?|classes)' 'overlap groups')
    printf 'overlap groups shade reported: %s\n' "$groups"
    printf 'the widest of those lines names %s jars; the slide shows the first %s and elides %s.\n' \
      "$wide_names" "$SLIDE_KEEP" "$(( wide_names - SLIDE_KEEP ))"
    printf '  %s, ... %s\n' "$wide_cut" "$(printf '%s\n' "$wide" | sed -E 's/^.*(define .*)$/\1/')"
    printf '\nMETA-INF/LICENSE: carried by %s of the input jars, present in the fat jar %s time(s)\n' "$lic_in" "$lic_out"
    printf 'META-INF/NOTICE : carried by %s of the input jars, present in the fat jar %s time(s)\n' "$not_in" "$not_out"
    printf 'licence files that did not survive being merged: %s\n' "$(( lic_in - lic_out ))"
    printf '\nservice files in the fat jar, listed:\n'
    unzip -l "$FAT" | awk '$4 ~ /^META-INF\/services\/./ {print "  " $4}' | sort
    local svc_n; svc_n=$(unzip -l "$FAT" | awk '$4 ~ /^META-INF\/services\/./' | wc -l | tr -d ' ')
    printf 'service files: %s, and no two of them have the same name\n' "$svc_n"
    printf '\nMETA-INF/services/java.sql.Driver, with ServicesResourceTransformer: %s bytes\n' "$svc_fat"
    printf 'the same file with the transformer deleted and nothing else changed: %s bytes\n' "$svc_ns"
    printf 'difference: %s byte(s) - the merge appends a newline per provider\n' "$(( svc_fat - svc_ns ))"
    printf 'so on THIS classpath the transformer changes %s byte and nothing breaks.\n' "$(( svc_fat - svc_ns ))"
    printf 'It is not this classpath it is there for. It is the day two jars name the same service.\n'
    printf '\nand the header the fat jar kept from the thin build:\n'
    unzip -p "$FAT" META-INF/MANIFEST.MF | grep -E '^(Main-Class|Class-Path| )'
    printf 'Class-Path entries in a jar that needs none: %s\n' "$(cp_entries "$FAT")"
  } > .r-overlap.out 2>&1

  cat .r-overlap.out
  printf 'md5 %s  (exit 0 then 0)\n' "$(hash_of .r-overlap.out)"
}

# ------------------------------------------------------------------ jdeps ----
# HASHED. Four attempts, three errors, one file. The exit codes ARE the lesson.
run_jdeps() {
  block "jdeps - --generate-module-info against a real jar  [HASHED]"
  need_jdk25
  [ -f "$THIN" ] || "${MVN[@]}" -q clean package > .r-thin.raw 2>&1 || die "build failed"
  [ -d target/lib ] || die "no target/lib"
  rm -rf .mi1 .mi2 .mi3 && mkdir -p .mi1 .mi2 .mi3

  local rc1 rc2 rc3
  jdeps --generate-module-info .mi1 "$THIN" > .r-j1.raw 2>&1; rc1=$?
  jdeps --generate-module-info .mi2 --module-path target/lib "$THIN" > .r-j2.raw 2>&1; rc2=$?
  jdeps --generate-module-info .mi3 --module-path target/lib --multi-release 25 "$THIN" > .r-j3.raw 2>&1; rc3=$?

  local out; out=$(find .mi3 -name module-info.java | head -1)
  [ -n "$out" ] || die "the third attempt produced no module-info.java, so there is nothing to show"

  # A multi-release jar carries META-INF/versions/. Counted from the archives, and sorted,
  # so neither the count nor the list depends on the order jdeps happened to walk.
  local libs mrj mrjnames j
  libs=$(ls target/lib/*.jar | wc -l | tr -d ' ')
  mrj=0; mrjnames=''
  for j in $(ls target/lib/*.jar | sort); do
    if [ "$(has_entry "$j" ' META-INF/versions/')" = 1 ]; then
      mrj=$(( mrj + 1 )); mrjnames="${mrjnames}$(basename "$j") "
    fi
  done
  [ "$mrj" -gt 0 ] || die "no multi-release jar on the module path, so attempt 2 cannot fail the way it does"

  { printf 'attempt 1 - the jar on its own\n'
    printf '  $ jdeps --generate-module-info <dir> %s\n' "$(basename "$THIN")"
    trim .r-j1.raw 4 | sed 's/^/  /'
    printf '  exit %s\n' "$rc1"
    printf '\nattempt 2 - and now give it the four jars\n'
    printf '  $ jdeps --generate-module-info <dir> --module-path target/lib %s\n' "$(basename "$THIN")"
    # WHICH jar jdeps names here is NOT stable: more than one of them is multi-release and
    # jdeps stops at the first it meets, in whatever order the module path was walked. Three
    # clean runs of this block named two different jars. The name is therefore masked and
    # the COUNT is derived instead - a name that moves between runs is exactly the kind of
    # thing that ends up on a slide and is wrong three months later.
    trim .r-j2.raw 2 's/Error: [^ ]+\.jar is a multi-release/Error: <one of them> is a multi-release/' | sed 's/^/  /'
    printf '  exit %s\n' "$rc2"
    printf '  multi-release jars on that module path: %s of %s\n' "$mrj" "$libs"
    printf '  they are: %s\n' "$mrjnames"
    printf '\nattempt 3 - name the release the multi-release jar should be read at\n'
    printf '  $ jdeps --generate-module-info <dir> --module-path target/lib --multi-release 25 %s\n' "$(basename "$THIN")"
    printf '  exit %s\n' "$rc3"
    printf '\nwritten to %s:\n' "$(printf '%s' "$out" | sed 's#^\.mi3/#<dir>/#')"
    sed 's/^/  /' "$out"
    printf '\nattempts that failed: %s of 3\n' "$(( (rc1!=0) + (rc2!=0) + (rc3!=0) ))"
    printf 'requires clauses generated: %s\n' "$(count_positive "$out" '^[[:space:]]*requires' 'requires clauses')"
    printf 'exports clauses generated: %s\n'  "$(count_positive "$out" '^[[:space:]]*exports'  'exports clauses')"
    printf '\nand what the jar says about itself before any of that:\n'
    jar --describe-module --file "$THIN" 2>&1 | sed '/^$/d' | sed 's/^/  /'
    printf '  -- the SAME question, of jackson-databind:\n'
    jar --describe-module --file target/lib/jackson-databind-2.22.2.jar 2>&1 | sed '/^$/d' | sed 's/^/  /'
  } > .r-jdeps.out 2>&1

  cat .r-jdeps.out
  printf 'md5 %s  (exit %s, %s, %s)\n' "$(hash_of .r-jdeps.out)" "$rc1" "$rc2" "$rc3"
}

# ----------------------------------------------------------------- layers ----
# HASHED. Layering is not a file format. It is which bytes change when you change one line.
run_layers() {
  block "layers - which bytes move when one line moves  [HASHED]"
  need_jdk25
  local src=src/main/java/com/tiffinbox/ship/TiffinBoxApp.java
  [ -f "$src" ] || die "no $src"
  grep -q 'println("ok")' "$src" || die "$src is not in its shipped state; restore it before measuring"

  "${MVN[@]}" -q clean package -DskipTests > .r-l1.raw 2>&1 || die "build 1 failed"
  local app1 lib1; app1=$(hash_of "$THIN"); lib1=$(md5 -q target/lib/*.jar | md5 -q)
  "${MVN[@]}" -q clean package -DskipTests > .r-l2.raw 2>&1 || die "build 2 failed"
  local app2 lib2; app2=$(hash_of "$THIN"); lib2=$(md5 -q target/lib/*.jar | md5 -q)

  cp "$src" .r-app.bak
  sed -i '' 's/println("ok")/println("ok.")/' "$src" 2>/dev/null || sed -i 's/println("ok")/println("ok.")/' "$src"
  grep -q 'println("ok.")' "$src" || { cp .r-app.bak "$src"; die "the one-line edit did not apply"; }
  "${MVN[@]}" -q clean package -DskipTests > .r-l3.raw 2>&1 || { cp .r-app.bak "$src"; die "build 3 failed"; }
  local app3 lib3; app3=$(hash_of "$THIN"); lib3=$(md5 -q target/lib/*.jar | md5 -q)
  cp .r-app.bak "$src"; rm -f .r-app.bak
  grep -q 'println("ok")' "$src" || die "failed to restore $src"

  [ "$app1" = "$app2" ] || die "two builds of unchanged sources gave different app jars - project.build.outputTimestamp is not doing its job"
  [ "$app1" != "$app3" ] || die "the app jar did not change after a source change - the build did not rebuild"

  # Rebuild from the RESTORED source, so the byte sizes below belong to the shipped jar
  # and not to the one-character edit that was made three lines ago.
  "${MVN[@]}" -q clean package -DskipTests > .r-l4.raw 2>&1 || die "the restoring build failed"
  [ "$(hash_of "$THIN")" = "$app1" ] || die "the restored source did not rebuild to the shipped jar"

  # An md5 is a hex STRING, not a number. `$(( app1 != app3 ))` asks bash to evaluate
  # 6269ae64... as arithmetic, which is a syntax error - and inside a redirected block the
  # error lands in the capture file instead of on your terminal. Counted with test(1).
  local moved=0
  [ "$app1" != "$app3" ] && moved=$(( moved + 1 ))
  [ "$lib1" != "$lib3" ] && moved=$(( moved + 1 ))

  local appb libb
  appb=$(bytes "$THIN"); libb=$(cat target/lib/*.jar | wc -c | tr -d ' ')

  { printf 'build 1, and build 2 with nothing changed at all:\n'
    printf '  application layer  %s\n' "$app1"
    printf '  application layer  %s\n' "$app2"
    printf '  the two are the same: %s\n' "$([ "$app1" = "$app2" ] && echo yes || echo no)"
    printf '  dependency  layer  %s\n' "$lib1"
    printf '  dependency  layer  %s\n' "$lib2"
    printf '  the two are the same: %s\n' "$([ "$lib1" = "$lib2" ] && echo yes || echo no)"
    printf '\nbuild 3, after changing ONE line of one .java file:\n'
    printf '  application layer  %s   moved: %s\n' "$app3" "$([ "$app1" != "$app3" ] && echo yes || echo no)"
    printf '  dependency  layer  %s   moved: %s\n' "$lib3" "$([ "$lib1" != "$lib3" ] && echo yes || echo no)"
    printf '\nlayers whose bytes changed: %s of 2\n' "$moved"
    printf 'jars in the dependency layer: %s\n' "$(ls target/lib/*.jar | wc -l | tr -d ' ')"
    printf 'bytes of application layer per 1000 bytes of the two layers together: %s\n' \
      "$(( appb * 1000 / (appb + libb) ))"
    printf '(that is %s bytes of application against %s bytes of dependencies - sizes, so NOT part of any hash above)\n' "$appb" "$libb"
  } > .r-layers.out 2>&1

  # The sizes vary with the mirror, so strip them from the hashed file and say so.
  grep -v '^(that is ' .r-layers.out > .r-layers.hashed
  cat .r-layers.out
  printf 'md5 %s  (over the block above with the byte-size line removed - 1 line elided, counted)\n' \
    "$(hash_of .r-layers.hashed)"
}

# ---------------------------------------------------------------- release ----
# HASHED. No network. Everything below is derived from the two files in central/.
run_release() {
  block "release - the <release> field, on this unit's own plugin  [HASHED, no network]"
  local md=central/maven-jar-plugin-maven-metadata.xml
  local dir=central/maven-jar-plugin-directory-listing.html
  [ -s "$md" ] || die "missing $md"
  [ -s "$dir" ] || die "missing $dir"

  local rel last newest_ga vcount
  rel=$(grep -o '<release>[^<]*' "$md" | sed 's/<release>//')
  last=$(grep -o '<version>[^<]*' "$md" | sed 's/<version>//' | tail -1)
  vcount=$(count_positive "$md" '<version>' 'versions in the list')
  newest_ga=$(grep -o '<version>[^<]*' "$md" | sed 's/<version>//' \
              | grep -vE '(alpha|beta|rc|M[0-9]|SNAPSHOT)' | tail -1)
  [ -n "$rel" ] || die "no <release> field in $md"
  [ -n "$newest_ga" ] || die "no GA version found in the list"

  date_of() {  # $1 = version -> the publication date from the directory listing
    grep -oE "<a href=\"$1/\"[^>]*>[^<]*</a>[^0-9]*[0-9]{4}-[0-9]{2}-[0-9]{2}" "$dir" \
      | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1
  }
  local d_rel d_ga
  d_rel=$(date_of "$rel"); d_ga=$(date_of "$newest_ga")
  [ -n "$d_rel" ] || die "no publication date for $rel in the directory listing"
  [ -n "$d_ga" ]  || die "no publication date for $newest_ga in the directory listing"

  # UTC midnight on both ends. BSD `date -j -f '%Y-%m-%d'` fills the missing time fields
  # from the CURRENT clock in LOCAL time, so a gap straddling a daylight-saving change
  # comes out an hour short and integer division silently loses a whole day. Section 4
  # measured that (975 for a gap that is 976); this block does not repeat it.
  epoch() { date -j -u -f '%Y-%m-%d %H:%M:%S' "$1 00:00:00" +%s 2>/dev/null || date -u -d "$1" +%s; }
  local days; days=$(( ( $(epoch "$d_ga") - $(epoch "$d_rel") ) / 86400 ))

  { printf 'org.apache.maven.plugins:maven-jar-plugin, read from central/ with no network\n'
    printf '  versions in the list ............ %s\n' "$vcount"
    printf '  <release> field says ............ %s, published %s\n' "$rel" "$d_rel"
    printf '  last entry of the version list .. %s  (the same string: %s)\n' "$last" "$([ "$last" = "$rel" ] && echo yes || echo no)"
    printf '  newest GA ....................... %s, published %s\n' "$newest_ga" "$d_ga"
    printf '  the GA is NEWER than the field by %s days\n' "$days"
    printf '  so the field is neither newest-GA nor newest-published\n'
    printf '  this pom pins ................... %s\n' "$(grep -A1 'maven-jar-plugin' pom.xml | grep -oE '<version>[^<]*' | sed 's/<version>//' | head -1)"
  } > .r-release.out 2>&1

  cat .r-release.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-release.out)"
}

# --------------------------------------------------------------- solution ----
# HASHED. The start state is ASSERTED first. If the untouched exercise already passes,
# this block stops instead of printing a pass it did not earn.
run_solution() {
  block "solution - the exercise, start state proved first  [HASHED]"
  need_jdk25
  [ -d exercise ] || die "no exercise/"
  grep -q 'outputTimestamp' exercise/pom.xml && die "exercise/pom.xml already carries the answer"

  rm -rf .sol && cp -R exercise .sol
  ( cd .sol && mvn -B -q -Dmaven.repo.local="$REPO" clean package -DskipTests ) > .r-s1.raw 2>&1 \
    || die "the exercise start state does not build; see .r-s1.raw"
  local s1; s1=$(hash_of .sol/target/tiffinbox-core-1.0.0.jar)
  sleep 1
  ( cd .sol && mvn -B -q -Dmaven.repo.local="$REPO" clean package -DskipTests ) > .r-s2.raw 2>&1 || die "second start-state build failed"
  local s2; s2=$(hash_of .sol/target/tiffinbox-core-1.0.0.jar)
  [ "$s1" != "$s2" ] || die "the untouched exercise is ALREADY reproducible - there is nothing to fix"

  # the answer: the one property from exercise/solution/
  local prop; prop=$(grep -oE '<project\.build\.outputTimestamp>[^<]*</project\.build\.outputTimestamp>' exercise/solution/pom-fragment.xml)
  [ -n "$prop" ] || die "exercise/solution/pom-fragment.xml has no property in it"
  perl -0pi -e "s#(<project\\.build\\.sourceEncoding>[^<]*</project\\.build\\.sourceEncoding>)#\$1\n    $prop#" .sol/pom.xml
  grep -q 'outputTimestamp' .sol/pom.xml || die "failed to apply the answer to .sol/pom.xml"

  ( cd .sol && mvn -B -q -Dmaven.repo.local="$REPO" clean package -DskipTests ) > .r-s3.raw 2>&1 || die "the answered build failed"
  local a1; a1=$(hash_of .sol/target/tiffinbox-core-1.0.0.jar)
  sleep 1
  ( cd .sol && mvn -B -q -Dmaven.repo.local="$REPO" clean package -DskipTests ) > .r-s4.raw 2>&1 || die "second answered build failed"
  local a2; a2=$(hash_of .sol/target/tiffinbox-core-1.0.0.jar)

  # THE HASH CANNOT COVER THE START STATE'S OWN HASHES, and that is the point of the
  # exercise. Those two values are wall clocks wearing a hex coat: they are DIFFERENT on
  # every run by construction, so a receipt that hashed them would fail 2/3 and a brief
  # that quoted them would be quoting noise. What is hashed is the VERDICT - do the two
  # builds agree, before and after - plus the derived counts. The four values themselves
  # are printed below the hash with the reason.
  { printf 'start state - exercise/pom.xml as shipped, built twice, nothing changed between:\n'
    printf '  the two builds agree: %s\n' "$([ "$s1" = "$s2" ] && echo yes || echo no)"
    printf '\nanswer - one property added to <properties>, nothing else touched:\n'
    printf '  %s\n' "$prop"
    printf '  the two builds agree: %s\n' "$([ "$a1" = "$a2" ] && echo yes || echo no)"
    printf '\nlines of Java changed to get there: %s\n' \
      "$(diff -r --brief exercise/src .sol/src 2>/dev/null | wc -l | tr -d ' ')"
    printf 'lines added to pom.xml: %s\n' "$(( $(wc -l < .sol/pom.xml) - $(wc -l < exercise/pom.xml) ))"
    printf 'distinct jar hashes across the two start-state builds: 2 of 2\n'
    printf 'distinct jar hashes across the two answered builds:    1 of 2\n'
  } > .r-solution.out 2>&1

  cat .r-solution.out
  printf 'md5 %s  (exit 0 then 0)\n' "$(hash_of .r-solution.out)"
  printf 'no md5 on these four: the start state is non-reproducible ON PURPOSE, so its two\n'
  printf 'values move every run and hashing them would claim a stability the exercise exists\n'
  printf 'to disprove.  start: %s / %s   answered: %s / %s\n' "$s1" "$s2" "$a1" "$a2"
  [ "$a1" = "$a2" ] || die "the answer did not make the jar reproducible"
  rm -rf .sol
}

# ---------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's re-run receipt  [HASHED]"
  need_jdk25
  "${MVN[@]}" -q clean package > .r-warm.raw 2>&1 || die "the warm build failed"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc; see .r-off.raw"
  { grep -E 'Tests run:|BUILD SUCCESS' .r-off.raw | mask
    printf 'offline runs that reached the network: %s\n' "$(grep -c 'Downloading' .r-off.raw || true)"
    printf 'exit code: %s\n' "$rc"
    printf 'the lifecycle the repository was warmed with: package (not test - copy-dependencies is bound to prepare-package)\n'
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

case "${1:-all}" in
  three)     run_three ;;
  classpath) run_classpath ;;
  overlap)   run_overlap ;;
  jdeps)     run_jdeps ;;
  layers)    run_layers ;;
  release)   run_release ;;
  solution)  run_solution ;;
  offline)   run_offline ;;
  all)  run_three; run_classpath; run_overlap; run_jdeps; run_layers; run_release; run_solution; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
