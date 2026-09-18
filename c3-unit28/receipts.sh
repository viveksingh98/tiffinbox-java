#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh ship       run one block
#
# THIS IS THE COURSE FINALE, AND IT HAS ONE RULE OF ITS OWN.
#
#   Every count this unit puts on a slide is RE-READ on the day it is cut, never remembered.
#   The unit count, the section count, the section names and the course's position on the
#   roadmap all come out of ~/Desktop/PromptVidya-Automation/java3_series.py, which is the
#   single source of those facts, and `counts` reads them there. A finale that types its own
#   unit count is the failure mode of every roadmap video on the internet.
#
#   And the finale does not SAY the course worked. It runs the chain: jar, run, AOT cache,
#   runtime image, run again. `ship` is that chain, end to end, in one block.
#
#   `gaps` ticks off the four holes the last course's finale confessed - each against a file
#   that exists in this repository, counted, not claimed. `wiring` is the one gap this course
#   leaves, counted in the same way.
#
#   THE CHAIN STOPS AT THE RUNTIME IMAGE, AND THAT IS A CHOICE RATHER THAN A LIMIT.
#   `ship` runs on a stock JDK 25 and nothing else, so anybody who can run this repository can
#   reproduce all seven of its exit codes. A native image needs a second JDK, takes minutes and
#   is not reproducible for a viewer without one - so it lives in the closed-world unit, which
#   builds one, breaks it on purpose, and skips cleanly when no GraalVM is present. An earlier
#   cut of this script said this machine COULD NOT build one. That was measured and true when
#   it was written; it stopped being true, and a finale that keeps a stale excuse in its own
#   output is the exact failure this block exists to prevent.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
REALHOME=/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home

REPO="$PWD/.m2-demo"
MVN=(mvn -B -ntp -Dmaven.repo.local="$REPO")
JAR=target/tiffinbox-core-1.0.0.jar
CP="target/tiffinbox-core-1.0.0.jar:target/lib/h2-2.5.250.jar"
MAIN=com.tiffinbox.wiring.Wiring
DELIV="$(cd "$PWD/.." && pwd)"   # normalised: a literal ".." in this path makes every
                                 # -path '*/c3-unit*/...' pattern below match the WHOLE repo,
                                 # because find's * matches "/" - the prefix ".../c3-unit28/.."
                                 # already satisfies "c3-unit" and the trailing * swallows the
                                 # rest. That counted unit33, unit35 and capstone from the two
                                 # earlier courses as Course 3 units. Measured: 21 instead of 18.
SERIES="$HOME/Desktop/PromptVidya-Automation/java3_series.py"

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
nohash() { printf 'no md5: %s\n' "$1"; }

mask() { sed -E -e "s#${PWD}/#<project>/#g" -e 's#.*/c3-unit28/#<project>/#g' \
                -e 's#/Users/[^/]*/#<home>/#g' \
                -e 's/^\[[0-9]+\.[0-9]+s\]/[<t>]/' \
                -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//'; }


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
# A DIE BEHIND A PIPE IS NOT A GUARD.
#
# The `ship` panel is built inside `{ … } > .r-ship.out 2>&1` and elides its two runs as
# `trim <file> 1 | sed 's/^/       /'`. The left-hand side of a pipeline runs in a SUBSHELL:
# `trim`'s `die` exits THAT shell, the pipeline's status is sed's 0, nobody tests the pipeline
# so `set -o pipefail` never comes into it - and the RECEIPT FAILED line goes to stderr, which
# the `2>&1` puts INSIDE the capture being hashed. Measured here: with both captures emptied,
# `ship` fired both of its "would be a lie" guards and still printed
# `md5 ff2b6b7b142eaf9769643dce130b62da  (exit 0 / 0 / 0 / 0 / 0 / 0 / 0)`, and the script
# exited 0. This is the same tautology the `steps that exited 0` line was removed for.
#
# So the condition is asserted HERE: current shell, no pipeline, no redirect, where `die` is
# fatal and visible. The pipelines are untouched, so the panel's bytes cannot move.
have_capture() {  # $@ = the captures a panel is about to elide
  local f
  for f in "$@"; do
    [ -s "$f" ] || die "trim: $f is missing or empty, so any elision count over it would be a lie"
  done
}

count_in() {
  [ -s "$1" ] || die "$3: $1 is missing or empty, so any count over it would be a lie"
  grep -cE "$2" "$1" || true
}
count_positive() {
  local n; n=$(count_in "$1" "$2" "$3")
  [ "$n" -gt 0 ] || die "$3: counted 0, and 0 cannot be right here"
  printf '%s' "$n"
}
# A count over a DIRECTORY listing, which cannot be zero by accident either.
dir_count() {  # $1 = a description, then a find expression
  local what="$1"; shift
  local n; n=$(find "$@" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -gt 0 ] || die "$what: counted 0 paths, and 0 cannot be right here"
  printf '%s' "$n"
}
bytes() { [ -f "$1" ] || die "no such file: $1"; stat -f%z "$1" 2>/dev/null || stat -c%s "$1"; }

need_jdk25() {
  local v; v=$(java -version 2>&1 | head -1)
  case "$v" in *25.0.4.1*) : ;; *) die "this unit is verified on JDK 25.0.4.1; java -version says: $v" ;; esac
}
build_once() {
  [ -f "$JAR" ] && [ -f target/lib/h2-2.5.250.jar ] && return 0
  "${MVN[@]}" -q clean package > .r-pkg.raw 2>&1 || die "mvn package failed; see .r-pkg.raw"
}

# ----------------------------------------------------------------- counts ----
# HASHED. Every number this unit is allowed to say, read from its source on the day.
run_counts() {
  block "counts - read from java3_series.py, never remembered  [HASHED]"
  [ -s "$SERIES" ] || die "cannot read $SERIES - this unit is forbidden to type its own counts"

  python3 - "$SERIES" > .r-counts.out 2>&1 <<'PY' || die "reading the series module failed"
import importlib.util, sys, pathlib
spec = importlib.util.spec_from_file_location("java3_series", sys.argv[1])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

titles, sections, section_of = m.TITLES, m.SECTIONS, m.SECTION_OF
print("read from java3_series.py, on the day, by importing it:")
print(f"  units in this course ............... {len(titles)}")
print(f"  sections in this course ............ {len(sections)}")
per = {s: sum(1 for u in section_of.values() if u == s) for s in sorted(sections)}
for s in sorted(sections):
    first = min(u for u, v in section_of.items() if v == s)
    last  = max(u for u, v in section_of.items() if v == s)
    print(f"    {s}. {sections[s]:<32} {first}-{last}  ({per[s]} units)")
print(f"  units accounted for by the five sections: {sum(per.values())}")
assert sum(per.values()) == len(titles), "a unit is in no section"
print(f"  the last unit is ................... {max(titles)} {titles[max(titles)]!r}")
print(f"  the playlist is ................... {m.PLAYLIST_NAME!r}")
print(f"  the channel is .................... {m.CHANNEL_NAME!r}")
print(f"  the code repository is ............ {m.GITHUB}")
print()
print("and the three things this unit is allowed to say out loud about the numbers:")
print(f"  '{len(titles)} units, across {len(sections)} sections' - both derived above")
print("  the course's position on the track is read from the roadmap, not from here")
PY
  cat .r-counts.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-counts.out)"
}

# ------------------------------------------------------------------- gaps ----
# HASHED. The four holes the last course confessed, ticked off against files that exist.
run_gaps() {
  block "gaps - the four holes, closed, and each against a file  [HASHED]"
  [ -d "$DELIV" ] || die "cannot see the deliverables directory"

  # GENERATED OUTPUT IS NOT SHIPPED, AND A LEDGER THAT COUNTS IT MOVES WHEN YOU BUILD.
  # These -path patterns were narrowed once already, to stop find's `*` swallowing a slash
  # and dragging two earlier courses in (21 where the answer is 18). They had a second hole
  # nobody looked for: nothing excluded build output. Measured - run c3-unit27/receipts.sh,
  # which is exactly what this course tells the viewer to do, and
  # c3-unit27/target/classes/META-INF/native-image/.../reflect-config.json appears at depth 8
  # and 'reachability metadata files shipped' goes 2 -> 3, taking this block's md5 with it.
  # It is a COPY of a source file, and .gitignore:4 (`target/`) says the repository does not
  # ship it. The same hole inflates the logback count the moment units 19-21 are built.
  # So every count here runs through NOTGEN, and the word "shipped" in a caption means it.
  local NOTGEN=( -not -path '*/target/*' -not -path '*/build/*' -not -path '*/out/*'
                 -not -path '*/.gradle/*' -not -path '*/.m2-demo/*' )

  local tests units workflow native logging modules receipts consumers
  units=$(dir_count 'course 3 unit directories' "$DELIV" -maxdepth 1 -type d -name 'c3-unit*')
  tests=$(dir_count 'unit directories carrying a test tree' "$DELIV" -maxdepth 3 -type d -path '*/c3-unit[0-9][0-9]/src/test' "${NOTGEN[@]}")
  receipts=$(dir_count 'receipts.sh files' "$DELIV" -maxdepth 2 -name 'receipts.sh' -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}")
  workflow=$(dir_count 'workflow files' "$DELIV" -maxdepth 3 -name 'build.yml' -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}")
  # -maxdepth 12, not 8: the ONE reachability descriptor this project really ships sits at
  # c3-unit27/src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core/ - nine
  # levels down, so `-maxdepth 8` excluded the real file and included the generated copy.
  # Narrow a pattern until the number is pretty and this is the number you get.
  native=$(dir_count 'reachability metadata files' "$DELIV" -maxdepth 12 -name 'reflect-config.json' -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}")
  # AND THE HALF THAT WAS MISSING WHEN THIS BLOCK WAS FIRST WRITTEN. Hole 4's artifact was
  # three descriptors that NOTHING IN THIS REPOSITORY READ - so the row carried a sentence
  # saying no native binary had been built here, and the slide called it half an answer.
  # That is no longer true: a GraalVM is available and the closed-world unit's `native`
  # profile builds the image, deletes the descriptors and builds again. So the thing that
  # was prose is now a count, derived the same way as every other row - the shipped poms
  # that declare that profile. It is a `find` with a `grep` behind it because a build
  # profile is a fact inside a file rather than a filename; no build runs here, and the
  # GraalVM path is neither read nor written down. `dir_count` cannot express it, so the
  # zero guard is stated here instead: if nothing consumes them, the sentence above the
  # ledger is wrong and the block must stop rather than print it.
  consumers=$(find "$DELIV" -maxdepth 2 -name 'pom.xml' -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}" \
                -exec grep -l '<id>native</id>' {} + 2>/dev/null | wc -l | tr -d ' ')
  [ "$consumers" -gt 0 ] || die "no shipped pom declares a profile that consumes the reachability metadata"
  logging=$(dir_count 'logback configurations' "$DELIV" -maxdepth 6 -name 'logback.xml' -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}")
  modules=$(dir_count 'modules in the long-lived project' "$DELIV/c3-tiffinbox" -maxdepth 2 -name 'pom.xml' "${NOTGEN[@]}")

  # THE FOUR HOLES ARE THE LAST COURSE'S WORDS, IN THE LAST COURSE'S ORDER, AND THEY ARE
  # NOT NEGOTIABLE. Read them off 44-whats-next-slides.html slide 3, left column - the four
  # `gapcard` headings. An earlier cut of this block listed "a logger with no backend" as
  # hole 3 and dropped "one hand-wired main" entirely. That line is real, but it is in the
  # RIGHT-hand column of that slide (Course 3's answer) and in its amber deferrals row
  # ("four things this course left out ON PURPOSE") - a choice the last course declared,
  # not a hole it confessed. Swapping them is what let this block tick 4 of 4, because the
  # hole it dropped is the one the next block proves is still open.
  local -a HOLE=( 'no tests - and the build says so'
                  'one hand-wired main'
                  'one pom.xml, and nothing but you runs it'
                  'a bundle only YOUR machine will run' )

  # THE LEDGER IS DERIVED FROM THOSE ROWS, NOT TYPED UNDER THEM. `named` is the length of
  # the list above, so it cannot drift from what is printed. `closed` adds one per hole
  # that the counts above actually close; hole 2 contributes a literal 0 because no file in
  # this repository closes it - and that is the finding, not an omission.
  # What would close hole 2 is a file that declares the startup order instead of a method
  # that performs it - a container spec or a DI descriptor. This counts those, so the "0"
  # under hole 2 is a measurement that MOVES the day one is added, not a rhetorical zero.
  # `dir_count` dies on 0 by design, so this one count goes through find directly: here a
  # zero is the answer, and the caller says what it means.
  local order_files
  order_files=$(find "$DELIV" -maxdepth 4 -path '*/c3-unit[0-9][0-9]/*' "${NOTGEN[@]}" \
                  \( -name 'Dockerfile' -o -name 'compose.yaml' -o -name 'docker-compose.yml' \
                     -o -name 'beans.xml' -o -name 'applicationContext*.xml' \) 2>/dev/null | wc -l | tr -d ' ')

  # AND IT DOES NOT MOVE WHEN A HEDGE DOES. Hole 4's term is `native>0` and always was:
  # the ledger asks whether a hole has a file behind it, not whether anything downstream
  # had got round to reading that file. So the day the descriptors stopped being unread,
  # `closed` stayed 3 and `handed` stayed 1 - the row above says so in the same output,
  # rather than leaving a reader to wonder why a better fact bought no better number.
  local named=${#HOLE[@]}
  local closed=$(( (tests>0 && receipts>0) + (order_files>0) + (modules>1 && workflow>0) + (native>0) ))
  local handed=$(( named - closed ))

  { printf 'the last course finale named four holes in the capstone. Each one, against a file:\n\n'
    printf '  1  "%s"\n' "${HOLE[0]}"
    printf '     unit directories in this course ................ %s\n' "$units"
    printf '     of those, carrying a src/test tree ............. %s\n' "$tests"
    printf '     units shipping a receipts.sh that runs them .... %s\n' "$receipts"
    printf '\n  2  "%s"\n' "${HOLE[1]}"
    printf '     files that write that startup order down ....... %s   <- the one still open\n' "$order_files"
    printf '\n  3  "%s"\n' "${HOLE[2]}"
    printf '     pom.xml files in the long-lived project ........ %s   (a parent and its modules)\n' "$modules"
    printf '     workflow files shipped ......................... %s\n' "$workflow"
    printf '\n  4  "%s"\n' "${HOLE[3]}"
    printf '     reachability metadata files shipped ............ %s\n' "$native"
    printf '     build profiles here that consume them .......... %s   <- the other half\n' "$consumers"
    printf "     that profile's unit deletes them and builds again: the build stays green, and\n"
    printf '     the binary stops. The ledger counts files behind a hole, so it does not move.\n'
    printf '\n  and one it DEFERRED on purpose rather than confessed - "a backend behind\n'
    printf '  System.Logger". Not a hole; a choice it declared. Paid anyway:\n'
    printf '     logback configurations shipped ................. %s\n' "$logging"
    printf '\nholes the last course named .......... %s\n' "$named"
    printf 'holes with an artifact behind them ... %s\n' "$closed"
    printf 'holes handed to the next course ...... %s   (hole 2 - see the next block)\n' "$handed"
  } > .r-gaps.out 2>&1

  cat .r-gaps.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-gaps.out)"
  printf 'and that md5 is a SNAPSHOT, not a constant. Every count above is a find(1) over this\n'
  printf 'repository as it stands right now, so it moves the moment a unit is added, renamed or\n'
  printf 'removed. It reproduces 3/3 inside one session and it is SUPPOSED to move afterwards.\n'
  printf 'Re-run it on the day you cut the video. That is the same rule as `counts`, applied to\n'
  printf 'the artifacts instead of to the unit list.\n'
}

# ----------------------------------------------------------------- wiring ----
# HASHED. The one gap this course leaves, counted rather than described.
run_wiring() {
  block "wiring - the lines nobody can delete  [HASHED]"
  need_jdk25; build_once
  local src=src/main/java/com/tiffinbox/wiring/Wiring.java
  [ -s "$src" ] || die "no $src"

  # Count the BODY of startEverything(), comments and blanks removed, so the number is
  # about wiring and not about javadoc.
  local body ctors params order_rules
  body=$(awk '/public static String startEverything/,/^    }$/' "$src" \
         | grep -vE '^\s*(//|/\*|\*)' | grep -vE '^\s*$' | wc -l | tr -d ' ')
  [ "$body" -gt 0 ] || die "could not read the body of startEverything()"
  ctors=$(awk '/public static String startEverything/,/^    }$/' "$src" | grep -cE ' = new [A-Z]' || true)
  [ "$ctors" -gt 0 ] || die "counted 0 constructor calls in the wiring, which cannot be right"
  params=$(grep -cE '^    public static final ' "$src" || true)

  local rc_run out
  out=$(java -cp "$CP" "$MAIN" 2>&1); rc_run=$?
  [ "$rc_run" -eq 0 ] || die "the wired application did not start (exit $rc_run)"

  "${MVN[@]}" -o test > .r-wtest.raw 2>&1 || "${MVN[@]}" test > .r-wtest.raw 2>&1 || die "the wiring tests failed"
  local tests; tests=$(grep -E '^\[INFO\] Tests run:' .r-wtest.raw | tail -1 | sed 's/^\[INFO\] //')

  { printf 'the application, started by hand:\n'
    printf '%s\n' "$out" | sed 's/^/  /'
    printf '  exit %s\n' "$rc_run"
    printf '\nand what starting it costs, counted out of the source:\n'
    printf '  lines in startEverything(), comments and blanks removed ... %s\n' "$body"
    printf '  objects constructed with new .............................. %s\n' "$ctors"
    printf '  configuration values held as constants beside them ........ %s\n' "$params"
    printf '  places that order is written down ......................... 0\n'
    printf '  things that check it ...................................... 0\n'
    printf '\nand here is what "0 things check it" means, as a test:\n'
    grep -E '^[[:space:]]+void [a-zA-Z]+\(' src/test/java/com/tiffinbox/WiringOrderTest.java \
      | sed -E -e 's/^[[:space:]]+void /  - /' -e 's/\(\).*$//'
    printf '  %s\n' "$tests"
    printf '\nEvery line of that file is correct. It is readable, it is tested, and it is the\n'
    printf 'last thing in this project a person has to keep in their head. Move two lines and\n'
    printf 'it still compiles. That is the problem a container solves, and it is the only one\n'
    printf 'this course leaves open.\n'
  } > .r-wiring.out 2>&1

  cat .r-wiring.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-wiring.out)" "$rc_run"
}

# ------------------------------------------------------------------- ship ----
# HASHED. Not a claim that the course worked. The chain, run.
run_ship() {
  block "ship - jar, run, AOT cache, runtime image, run again  [HASHED]"
  need_jdk25
  rm -rf .img .aot.conf .aot.cache

  local rc_pkg rc_jar rc_rec rc_cre rc_aot rc_jlink rc_img
  "${MVN[@]}" clean package > .r-ship1.raw 2>&1; rc_pkg=$?
  [ "$rc_pkg" -eq 0 ] || die "mvn package exited $rc_pkg"
  [ -f "$JAR" ] || die "no $JAR"
  local tests; tests=$(grep -E '^\[INFO\] Tests run:' .r-ship1.raw | tail -1 | sed 's/^\[INFO\] //')
  local libs; libs=$(ls target/lib/*.jar 2>/dev/null | wc -l | tr -d ' ')
  [ "$libs" -gt 0 ] || die "no dependency layer"

  java -jar "$JAR" > .r-ship2.raw 2>&1; rc_jar=$?
  [ "$rc_jar" -eq 0 ] || die "the jar does not run (exit $rc_jar)"

  java -XX:AOTMode=record -XX:AOTConfiguration=.aot.conf -cp "$CP" "$MAIN" > .r-ship3.raw 2>&1; rc_rec=$?
  java -XX:AOTMode=create -XX:AOTConfiguration=.aot.conf -XX:AOTCache=.aot.cache -cp "$CP" > .r-ship4.raw 2>&1; rc_cre=$?
  [ "$rc_rec" -eq 0 ] && [ "$rc_cre" -eq 0 ] || die "the AOT chain failed: record=$rc_rec create=$rc_cre"
  java -XX:AOTCache=.aot.cache -Xlog:class+load=info -cp "$CP" "$MAIN" > .r-ship5.raw 2>&1; rc_aot=$?
  [ "$rc_aot" -eq 0 ] || die "the AOT run failed"
  local cached total
  cached=$(count_positive .r-ship5.raw 'shared objects file' 'classes out of the AOT cache')
  total=$(count_positive .r-ship5.raw '\[class,load\]' 'classes loaded')

  # jlink's status is CAPTURED, not assumed. Five of the six steps below read their exit
  # code out of a variable and the sixth used to print a literal `0` into a printf - in the
  # unit whose whole thesis is that a count on a slide is derived and not typed. `|| die`
  # proves the step did not fail; it does not put a measured number on the screen.
  "$REALHOME/bin/jlink" --module-path "$REALHOME/jmods" --add-modules java.base,java.sql \
      --output .img --no-header-files --no-man-pages --compress=zip-6 > .r-ship6.raw 2>&1; rc_jlink=$?
  [ "$rc_jlink" -eq 0 ] || die "jlink exited $rc_jlink"
  .img/bin/java -cp "$CP" "$MAIN" > .r-ship7.raw 2>&1; rc_img=$?
  [ "$rc_img" -eq 0 ] || die "the program does not run in the jlink image (exit $rc_img)"

  local mods; mods=$(.img/bin/java --list-modules | wc -l | tr -d ' ')
  local jdkmods; jdkmods=$(java --list-modules | wc -l | tr -d ' ')

  # THE THREE NUMBERS UNDER THE CHAIN ARE DERIVED FROM THE CHAIN, NOT FROM THE PROSE.
  # RC holds one entry per command actually run, STEP says which numbered step it belongs
  # to, so `steps` and `commands` cannot disagree with the panel above them - and the old
  # `steps that exited 0` line, which summed six booleans every one of which was already
  # `|| die`-guarded, could only ever print 6. That is a tautology, not a measurement; this
  # counts the exit codes that were captured, and every one of them is on the panel.
  local -a RC=( "$rc_pkg" "$rc_jar" "$rc_rec" "$rc_cre" "$rc_aot" "$rc_jlink" "$rc_img" )
  local -a STEP=( 1 2 3 3 4 5 6 )
  local steps zeros=0 r
  steps=$(printf '%s\n' "${STEP[@]}" | sort -u | wc -l | tr -d ' ')
  for r in "${RC[@]}"; do [ "$r" -eq 0 ] && zeros=$(( zeros + 1 )); done
  # …and the two captures the panel elides, checked before the panel is built rather than
  # inside a pipeline that cannot report it. See have_capture above.
  have_capture .r-ship2.raw .r-ship7.raw

  { printf 'the chain, run end to end, on this machine, today:\n\n'
    printf '  1  mvn package                                    exit %s   %s\n' "$rc_pkg" "$tests"
    printf '       application jar + %s dependency jar(s) beside it\n' "$libs"
    printf '  2  java -jar <the jar>                            exit %s\n' "$rc_jar"
    trim .r-ship2.raw 1 | sed 's/^/       /'
    printf '  3  java -XX:AOTMode=record  ...                   exit %s\n' "$rc_rec"
    printf '     java -XX:AOTMode=create  ...                   exit %s\n' "$rc_cre"
    printf '  4  java -XX:AOTCache=<cache> ...                  exit %s\n' "$rc_aot"
    printf '       classes loaded %s, of those out of the cache %s\n' "$total" "$cached"
    printf '  5  jlink --add-modules java.base,java.sql         exit %s\n' "$rc_jlink"
    printf '       %s of this JDK %s modules\n' "$mods" "$jdkmods"
    printf '  6  <the image>/bin/java ...                       exit %s\n' "$rc_img"
    trim .r-ship7.raw 1 | sed 's/^/       /'
    printf '\nsteps in the chain .................. %s\n' "$steps"
    printf 'commands those steps ran ............ %s   (step 3 is two)\n' "${#RC[@]}"
    printf 'exit codes captured ................. %s\n' "${#RC[@]}"
    printf 'commands that exited 0 .............. %s\n' "$zeros"
    printf 'the two runs printed the same answer: %s\n' \
      "$([ "$(head -1 .r-ship2.raw)" = "$(head -1 .r-ship7.raw)" ] && echo yes || echo no)"
    printf '\nAnd the step that is NOT in this chain, left out on purpose: a native binary. It\n'
    printf 'needs a second JDK this chain does not, and the unit that owns it builds one.\n'
  } > .r-ship.out 2>&1

  cat .r-ship.out
  # ALL SEVEN, in the order they ran. The old form printed five and silently dropped
  # `create`'s and jlink's - a receipt line that under-reports what it measured.
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-ship.out)" \
    "$(printf '%s / ' "${RC[@]}" | sed 's| / $||')"
  # THE SAME DEFECT IN A COMMAND SUBSTITUTION: `$(bytes X)` inside this string ran in a
  # subshell, so a `die` killed only that subshell and the line printed with the number
  # MISSING - measured: `AOT cache  bytes`, and exit 0. Read first, in the current shell.
  local sz_jar sz_cache
  sz_jar=$(bytes "$JAR")       || exit 1
  sz_cache=$(bytes .aot.cache) || exit 1
  nohash "sizes, which move: jar $sz_jar bytes, AOT cache $sz_cache bytes, runtime image $(du -sk .img | awk '{print $1}') KB."
  rm -rf .img .aot.conf .aot.cache
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
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

case "${1:-all}" in
  counts)  run_counts ;;
  gaps)    run_gaps ;;
  wiring)  run_wiring ;;
  ship)    run_ship ;;
  offline) run_offline ;;
  all) run_counts; run_gaps; run_wiring; run_ship; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
