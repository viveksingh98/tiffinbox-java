#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block EXCEPT `native`
#   ./receipts.sh aot        run one block
#   ./receipts.sh native     the two real native builds - minutes long, needs GRAALVM_HOME
#
# READ THIS FIRST. IT IS THE HONEST VERSION AND IT DECIDES THE WHOLE UNIT.
#
#   This unit is about ahead-of-time compilation, and a GraalVM native image is its most
#   famous form. **This unit builds one, and then builds it wrong on purpose.**
#
#   The `native` block is the spine and it is not part of a bare `./receipts.sh` run, for
#   two reasons that are both about honesty rather than convenience:
#
#     1. IT NEEDS A GRAALVM JDK, AND IT DOES NOT GUESS WHERE. `GRAALVM_HOME` first, then
#        `JAVA_HOME` when that contains a `bin/native-image`, and otherwise a SKIP that
#        names the variable to set. No path to anybody's Downloads folder is written down
#        here. A viewer without GraalVM gets an explanation, never a failure, and never a
#        hash for a build that did not happen.
#     2. IT TAKES MINUTES, NOT SECONDS. Two full native builds, so that the second one can
#        be the same project with its two reachability files deleted. `./receipts.sh` with
#        no arguments stays a thing you can run while you watch it.
#
#           export GRAALVM_HOME=/path/to/a/graalvm-jdk
#           ./receipts.sh native
#
#   WHAT THAT BLOCK MEASURES, AND IT IS THE WHOLE UNIT. The project as it ships builds a
#   binary that answers both of its keys, exit 0. Delete
#   `src/main/resources/META-INF/native-image/` - two json files, no Java touched - and the
#   build is still BUILD SUCCESS, still exit 0, and the binary it produced is broken:
#   `ClassNotFoundException` on the formatter, exit 1, on both keys. **A green build that
#   produced a broken artifact.** The metadata this unit has always shipped and never
#   consumed is proved load-bearing by deleting it.
#
#   And the three beats that need no GraalVM at all still run on a plain JDK 25, because
#   they are the reason the binary behaves that way:
#
#     - THE CLOSED WORLD IS MEASURABLE WITHOUT A COMPILER. jdeps reports zero references
#       from the entry point to either formatter, because the only place their names exist
#       is a properties file. That is exactly what a closed-world compiler cannot see.
#     - THE AOT PATH IS REAL ON THIS JDK, as a COUNT. `-XX:AOTMode=record` / `create` and a
#       cache that 1985 of 1991 classes come out of. JEP 483 and JEP 515, in the JDK you
#       have - and it FALLS BACK: the class the training run never saw is loaded from the
#       jar and the program works. A native image has no jar to fall back to, which the
#       `native` block now demonstrates rather than asserts.
#     - JLINK IS THE GENTLE CLOSED WORLD. Two images, five modules against one, same jar,
#       exit 0 against NoClassDefFoundError. It tells you at start-up; a native image
#       decided at build time and has nothing left to tell you with.
#
#   WHAT IS NOT HERE, AND WILL NOT BE: no throughput claim, no start-up-time claim, and no
#   binary-vs-jar size comparison. The native build's wall clock is not a number on any
#   slide either - a state word and a count instead (contract 2a/2b/2d). The binary's byte
#   size is printed OUTSIDE the hash with its reason, like every other size in this file.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

# A viewer's own JAVA_HOME is captured BEFORE this script overwrites it, because
# graalvm_home() below offers it as a fallback and the overwrite made that fallback
# unreachable: the script set JAVA_HOME to the plain JDK on line 60, so by the time any
# block ran, "JAVA_HOME containing bin/native-image" could never be true and a viewer who
# had pointed JAVA_HOME at a GraalVM still got the skip — while this file, the README and
# the deck all said that path worked. Documenting a route the code cannot take is the same
# defect this unit is about, so the route is real now.
VIEWER_JAVA_HOME="${JAVA_HOME:-}"
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
# jlink and jmod read $JAVA_HOME/jmods, which the Homebrew symlink does not expose.
REALHOME=/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home

UNIT="$PWD"
REPO="$PWD/.m2-demo"
MVN=(mvn -B -ntp -Dmaven.repo.local="$REPO")
JAR=target/tiffinbox-core-1.0.0.jar
CP="target/tiffinbox-core-1.0.0.jar:target/lib/h2-2.5.250.jar"
MAIN=com.tiffinbox.aot.Startup

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }
hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
nohash() { printf 'no md5: %s\n' "$1"; }

# ORDER MATTERS HERE, and getting it wrong cost this unit a 3/3.
#
# A class-loader URL is PERCENT-ENCODED, so a path containing a space arrives as
# `file:/.../clean%20copy/c3-unit27/target/...` and an "$PWD" substitution never matches it.
# The generic `.*/c3-unit27/` rule then swallowed the `file:` prefix too - so the same run
# produced `file:<project>/target/x.jar` on one path and `<project>/target/x.jar` on another,
# and the block hashed to two different values. The file: URL is normalised FIRST, by a rule
# that does not care what is in the middle of it.
mask() { sed -E -e 's#file:[^ ]*/(tiffinbox-core-1\.0\.0\.jar)#file:<project>/target/\1#g' \
                -e 's#[^ ]*/u27ab\.[A-Za-z0-9]+/proj/#<copy>/#g' \
                -e "s#${PWD}/#<project>/#g" -e 's#.*/c3-unit27/#<project>/#g' \
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
# A DIE BEHIND A PIPE IS NOT A GUARD, and this block is where that was caught.
#
# Every panel below is built inside `{ … } > .r-<id>.out 2>&1`, and the elided captures in it
# are printed as `trim <file> <n> | sed 's/^/  /'`. The left-hand side of a pipeline runs in a
# SUBSHELL: `trim`'s `die` exits THAT shell, the pipeline's status is sed's 0, `set -o pipefail`
# is never consulted because nobody tests the pipeline at all - and the RECEIPT FAILED line,
# being on stderr, lands INSIDE the capture through the `2>&1`. The block then cats the file
# and prints an md5 over it. Measured, in this unit: with `.r-trim.raw` emptied, `jlink` fired
# its own "would be a lie" guard and still printed `md5 07ebe29235285bf2e819ab491dc7e2f6
# (exit 0 full, exit 1 trimmed)`, and ./receipts.sh exited 0.
#
# So the condition `trim` and `of_total` guard is asserted HERE instead: in the current shell,
# outside every pipeline and outside that redirect, where `die` is both fatal and visible on
# the terminal. The pipelines themselves are left exactly as they were, so no hash moves.
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
bytes() { [ -f "$1" ] || die "no such file: $1"; stat -f%z "$1" 2>/dev/null || stat -c%s "$1"; }

need_jdk25() {
  local v; v=$(java -version 2>&1 | head -1)
  case "$v" in *25.0.4.1*) : ;; *) die "this unit is verified on JDK 25.0.4.1; java -version says: $v" ;; esac
}
build_once() {
  [ -f "$JAR" ] && [ -f target/lib/h2-2.5.250.jar ] && return 0
  "${MVN[@]}" -q clean package > .r-pkg.raw 2>&1 || die "mvn package failed; see .r-pkg.raw"
  [ -f "$JAR" ] || die "no $JAR after package"
}

# ------------------------------------------------------------ closedworld ----
# HASHED. The thing a closed-world compiler cannot see, measured with the JDK's own tool.
run_closedworld() {
  block "closedworld - what jdeps can see, and the one line it cannot  [HASHED]"
  need_jdk25; build_once

  jdeps --multi-release 25 -v --class-path 'target/lib/*' "$JAR" > .r-jdeps.raw 2>&1 \
    || die "jdeps failed; see .r-jdeps.raw"
  local from_startup to_plain to_ledger names_in_props mods
  from_startup=$(count_positive .r-jdeps.raw '^ *com\.tiffinbox\.aot\.Startup +->' 'edges out of Startup')
  to_plain=$(grep -cE '^ *com\.tiffinbox\.aot\.Startup +-> +com\.tiffinbox\.aot\.PlainFormatter' .r-jdeps.raw || true)
  to_ledger=$(grep -cE '^ *com\.tiffinbox\.aot\.Startup +-> +com\.tiffinbox\.aot\.LedgerFormatter' .r-jdeps.raw || true)
  names_in_props=$(count_positive src/main/resources/formatters.properties '^[a-z]+=com\.tiffinbox\.aot\.' 'class names in formatters.properties')
  mods=$(jdeps --multi-release 25 --print-module-deps --ignore-missing-deps "$JAR" 2>/dev/null)
  [ -n "$mods" ] || die "jdeps --print-module-deps printed nothing"

  # The class names must NOT appear anywhere in Java source outside the properties file.
  local src_mentions
  src_mentions=$(grep -rlE 'PlainFormatter|LedgerFormatter' src/main/java --include='*.java' \
                 | grep -vE '(PlainFormatter|LedgerFormatter)\.java$' | wc -l | tr -d ' ')
  [ "$src_mentions" -eq 0 ] || die "$src_mentions source file(s) name a formatter class; the demonstration is not honest"

  { printf 'the two class names, and everywhere they exist:\n'
    grep -E '^[a-z]+=' src/main/resources/formatters.properties | sed 's/^/  formatters.properties:  /'
    printf '  Java source files that name either class (other than the classes themselves): %s\n' "$src_mentions"
    printf '  class names in the properties file: %s\n' "$names_in_props"
    printf '\nwhat jdeps sees leaving the entry point:\n'
    grep -E '^ *com\.tiffinbox\.aot\.Startup +->' .r-jdeps.raw | sed -E 's/ +tiffinbox-core-1\.0\.0\.jar$//' \
      | sed -E 's/^ */  /' | head -6
    # THE ELISION IS COUNTED AND ITS CONTENT IS DERIVED, not described. An earlier draft of
    # this line read "all of them into java.base" without ever checking, which is the exact
    # defect four debate gates in this course have caught.
    printf '  ... %s more edge(s) elided: %s into java.base, %s elsewhere\n' \
      "$(( from_startup - 6 ))" \
      "$(grep -E '^ *com\.tiffinbox\.aot\.Startup +->' .r-jdeps.raw | tail -n +7 | grep -c ' java\.base$' || true)" \
      "$(grep -E '^ *com\.tiffinbox\.aot\.Startup +->' .r-jdeps.raw | tail -n +7 | grep -vc ' java\.base$' || true)"
    printf '\nedges out of Startup ............................ %s\n' "$from_startup"
    printf 'of those, into PlainFormatter ................... %s\n' "$to_plain"
    printf 'of those, into LedgerFormatter .................. %s\n' "$to_ledger"
    printf '\njdeps --print-module-deps over the whole jar .... %s\n' "$mods"
    printf '  (that answer includes java.sql because the LEDGER formatter bytecode is IN the\n'
    printf '   jar - jdeps reads the archive, not the reachable graph. A compiler that starts\n'
    printf '   at main and follows references would not get there at all.)\n'
    printf '\nThat is the closed world, in one number: zero. Nothing in the code points at\n'
    printf 'either implementation. Every service loader, every container, every annotation-\n'
    printf 'driven router in Java has this shape - including the one in this project.\n'
  } > .r-closedworld.out 2>&1

  cat .r-closedworld.out
  printf 'md5 %s  (exit 0)\n' "$(hash_of .r-closedworld.out)"
}

# -------------------------------------------------------------------- aot ----
# HASHED. The AOT path, on this JDK, as a COUNT rather than a duration (contract 2a/2d).
run_aot() {
  block "aot - the JDK 25 AOT cache, counted  [HASHED]"
  need_jdk25; build_once
  rm -f .aot.conf .aot.cache

  # 0. It refuses an exploded directory. That is a fact about packaging, in a unit about it.
  local rc_dir
  java -XX:AOTMode=record -XX:AOTConfiguration=.aot.dir.conf -cp target/classes "$MAIN" plain > .r-aotdir.raw 2>&1; rc_dir=$?
  local dir_err; dir_err=$(grep -m1 'non-empty directory' .r-aotdir.raw || true)
  [ -n "$dir_err" ] || die "the AOT recorder accepted an exploded directory; re-measure before this goes on a slide"
  rm -f .aot.dir.conf

  # 1. training, on the PLAIN path only.
  local rc_rec rc_cre
  java -XX:AOTMode=record -XX:AOTConfiguration=.aot.conf -cp "$CP" "$MAIN" plain > .r-rec.raw 2>&1; rc_rec=$?
  [ "$rc_rec" -eq 0 ] || die "the training run exited $rc_rec"
  [ -s .aot.conf ] || die "no AOT configuration was written"
  java -XX:AOTMode=create -XX:AOTConfiguration=.aot.conf -XX:AOTCache=.aot.cache -cp "$CP" > .r-cre.raw 2>&1; rc_cre=$?
  [ "$rc_cre" -eq 0 ] || die "cache creation exited $rc_cre"
  [ -s .aot.cache ] || die "no AOT cache was written"

  # 2/3/4. three runs: JIT, AOT-plain, AOT-ledger.
  local jit_cached jit_total aot_total aot_cached led_cached rc_jit rc_aot rc_led
  java -Xshare:off -Xlog:class+load=info -cp "$CP" "$MAIN" plain > .r-jit.raw 2>&1; rc_jit=$?
  java -XX:AOTCache=.aot.cache -Xlog:class+load=info -cp "$CP" "$MAIN" plain  > .r-aotp.raw 2>&1; rc_aot=$?
  java -XX:AOTCache=.aot.cache -Xlog:class+load=info -cp "$CP" "$MAIN" ledger > .r-aotl.raw 2>&1; rc_led=$?
  [ "$rc_jit" -eq 0 ] && [ "$rc_aot" -eq 0 ] && [ "$rc_led" -eq 0 ] \
    || die "one of the three runs failed: jit=$rc_jit aot=$rc_aot ledger=$rc_led"

  jit_cached=$(grep -c 'shared objects file' .r-jit.raw || true)
  jit_total=$(count_positive .r-jit.raw '\[class,load\]' 'classes loaded on the JIT path')
  aot_cached=$(count_positive .r-aotp.raw 'shared objects file' 'classes from the cache')
  aot_total=$(count_positive .r-aotp.raw '\[class,load\]' 'classes loaded on the AOT path')
  led_cached=$(count_positive .r-aotl.raw 'shared objects file' 'classes from the cache, ledger run')
  [ "$jit_cached" -eq 0 ] || die "the -Xshare:off run loaded $jit_cached classes from a cache, which it must not"

  local plain_src led_src
  plain_src=$(grep -m1 'com.tiffinbox.aot.PlainFormatter' .r-aotl.raw | sed -E 's/.*source: //' | mask)
  led_src=$(grep -m1 'com.tiffinbox.aot.LedgerFormatter' .r-aotl.raw | sed -E 's/.*source: //' | mask)
  [ -n "$plain_src" ] && [ -n "$led_src" ] || die "could not read where the two formatters were loaded from"

  { printf 'step 0 - the recorder refuses an exploded directory:\n'
    printf '  $ java -XX:AOTMode=record ... -cp target/classes %s plain\n' "$MAIN"
    printf '  %s\n' "$(printf '%s' "$dir_err" | mask)"
    printf '  So an AOT cache is a thing you make from a JAR. This is a packaging unit answer\n'
    printf '  arriving one unit late.\n'
    printf '\nstep 1 - a TRAINING run, on the plain path only, then the cache:\n'
    printf '  $ java -XX:AOTMode=record   -XX:AOTConfiguration=<conf> -cp <jars> %s plain\n' "$MAIN"
    printf '  $ java -XX:AOTMode=create   -XX:AOTConfiguration=<conf> -XX:AOTCache=<cache> -cp <jars>\n'
    printf '  exit %s, then exit %s\n' "$rc_rec" "$rc_cre"
    printf '\nstep 2 - the JIT path, cache switched off:\n'
    printf '  classes loaded ................. %s\n' "$jit_total"
    printf '  of those, out of a cache ....... %s\n' "$jit_cached"
    printf '\nstep 3 - the AOT path, same program, same arguments:\n'
    printf '  classes loaded ................. %s\n' "$aot_total"
    printf '  of those, out of the cache ..... %s\n' "$aot_cached"
    printf '  loaded from somewhere else ..... %s\n' "$(( aot_total - aot_cached ))"
    printf '\nstep 4 - the SAME cache, running the path the training run never touched:\n'
    printf '  PlainFormatter  loaded from ... %s\n' "$plain_src"
    printf '  LedgerFormatter loaded from ... %s\n' "$led_src"
    printf '  exit %s, and the program printed its answer\n' "$rc_led"
    grep -E '^(formatter key|month total|ok)' .r-aotl.raw | sed 's/^/    /'
    printf '\nAND THAT IS THE WHOLE LESSON. The class the training run never saw is not in the\n'
    printf 'cache. The JVM loaded it from the jar instead and the program worked. An AOT cache\n'
    printf 'is an OPTIMISATION over a program that is still complete. A native image is not:\n'
    printf 'there is no jar beside it to fall back to, and a class that is not in the binary\n'
    printf 'is a ClassNotFoundException at run time.\n'
    printf '\n(PlainFormatter comes out of the cache even on the ledger run: an AOT cache loads\n'
    printf ' what it archived, whether or not this run asks for it.)\n'
  } > .r-aot.out 2>&1

  cat .r-aot.out
  printf 'md5 %s  (exit %s / %s / %s / %s)\n' "$(hash_of .r-aot.out)" "$rc_rec" "$rc_cre" "$rc_aot" "$rc_led"
  # THE SAME DEFECT AS THE PIPELINES, IN A COMMAND SUBSTITUTION: `nohash "… $(bytes X) …"` runs
  # `bytes` in a subshell, so its `die` killed only that subshell and the line printed with the
  # number simply MISSING. Measured: with both files removed this printed
  # `AOT configuration , AOT cache , jar 18844.` and exited 0. The three sizes are read first,
  # in the current shell, and a `bytes` that dies now stops the script.
  local sz_conf sz_cache sz_jar
  sz_conf=$(bytes .aot.conf)   || exit 1
  sz_cache=$(bytes .aot.cache) || exit 1
  sz_jar=$(bytes "$JAR")       || exit 1
  nohash "the three sizes below are bytes, and a byte size goes on a slide only after it has repeated (C2 finding #3). AOT configuration $sz_conf, AOT cache $sz_cache, jar $sz_jar."
  rm -f .aot.conf .aot.cache
}

# ------------------------------------------------------------------ jlink ----
# HASHED. A closed world you CAN build here, so the shape is not taken on trust.
run_jlink() {
  block "jlink - a runtime with only what you asked for  [HASHED]"
  need_jdk25; build_once
  [ -d "$REALHOME/jmods" ] || die "no jmods at $REALHOME/jmods - jlink needs the real JDK home, not the Homebrew symlink"
  rm -rf .img-full .img-trim

  "$REALHOME/bin/jlink" --module-path "$REALHOME/jmods" --add-modules java.base,java.sql \
      --output .img-full --no-header-files --no-man-pages --compress=zip-6 > .r-jl1.raw 2>&1 \
      || die "jlink (full) failed; see .r-jl1.raw"
  "$REALHOME/bin/jlink" --module-path "$REALHOME/jmods" --add-modules java.base \
      --output .img-trim --no-header-files --no-man-pages --compress=zip-6 > .r-jl2.raw 2>&1 \
      || die "jlink (trimmed) failed; see .r-jl2.raw"

  local mods_full mods_trim rc_full rc_trim
  mods_full=$(.img-full/bin/java --list-modules | wc -l | tr -d ' ')
  mods_trim=$(.img-trim/bin/java --list-modules | wc -l | tr -d ' ')
  local mods_jdk; mods_jdk=$(java --list-modules | wc -l | tr -d ' ')
  [ "$mods_full" -gt "$mods_trim" ] || die "the two images have the same module count, so there is nothing to compare"

  .img-full/bin/java -cp "$CP" "$MAIN" ledger > .r-full.raw 2>&1; rc_full=$?
  .img-trim/bin/java -cp "$CP" "$MAIN" ledger > .r-trim.raw 2>&1; rc_trim=$?
  [ "$rc_full" -eq 0 ] || die "the full image could not run the program (exit $rc_full)"
  [ "$rc_trim" -ne 0 ] || die "the trimmed image ran the program; the closed-world cost did not reproduce"
  # …and the capture the panel elides, checked before the panel is built rather than inside a
  # pipeline that cannot report it. See have_capture above.
  have_capture .r-trim.raw

  { printf 'two runtimes, from the same JDK, built in one command each:\n'
    printf '  $ jlink --add-modules java.base,java.sql --output <img>\n'
    printf '  $ jlink --add-modules java.base          --output <img>\n'
    printf '\nmodules in this JDK ................. %s\n' "$mods_jdk"
    printf 'modules in the full image ........... %s   %s\n' "$mods_full" \
      "$(.img-full/bin/java --list-modules | sed 's/@.*//' | tr '\n' ' ')"
    printf 'modules in the trimmed image ........ %s   %s\n' "$mods_trim" \
      "$(.img-trim/bin/java --list-modules | sed 's/@.*//' | tr '\n' ' ')"
    printf '  (java.sql drags three more in with it - you do not choose those one by one)\n'
    printf '\nthe same program, the same jar, in the full image:\n'
    grep -E '^(formatter key|column type|customers|month total|ok)' .r-full.raw | sed 's/^/  /'
    printf '  exit %s\n' "$rc_full"
    printf '\nin the trimmed one:\n'
    trim .r-trim.raw 3 | sed 's/^/  /'
    printf '  exit %s\n' "$rc_trim"
    printf '\nNothing was recompiled between those two runs. The program is identical; the\n'
    printf 'world it runs in is not. That is what "closed world" costs, and jlink is the\n'
    printf 'gentle version - it tells you at start-up. A native image decides at BUILD time\n'
    printf 'and cannot tell you anything at all.\n'
  } > .r-jlink.out 2>&1

  cat .r-jlink.out
  printf 'md5 %s  (exit %s full, exit %s trimmed)\n' "$(hash_of .r-jlink.out)" "$rc_full" "$rc_trim"
  nohash "image sizes vary with the compression level and the JDK build: full $(du -sk .img-full | awk '{print $1}') KB, trimmed $(du -sk .img-trim | awk '{print $1}') KB, this JDK $(du -sk "$REALHOME" | awk '{print $1}') KB."
  rm -rf .img-full .img-trim
}

# ---------------------------------------------------------------- graalvm ----
# HASHED, and it runs anywhere. What the native profile PINS, all of it read out of files
# that ship with this unit - so this block hashes the same on a machine with GraalVM and on
# a machine without one. The old version of this block hashed THIS Mac's Xcode-licence state
# (exit 69 from cc) and the state changed under it, which is exactly the failure mode a
# receipt is supposed to prevent. Machine state belongs in `native`, which says when it
# cannot run; a pin belongs here, where it cannot move without a file moving.
run_graalvm() {
  block "graalvm - what the native profile pins  [HASHED]"

  local plugin_pinned plugin_latest plugin_pub graal_tag graal_date asset asset_bytes
  local goal phase image nargs args
  plugin_pinned=$(grep -A2 'native-maven-plugin' pom.xml | grep -oE '<version>[^<]*' | sed 's/<version>//' | head -1)
  plugin_latest=$(grep -o '<version>[^<]*' central/native-maven-plugin-maven-metadata.xml | sed 's/<version>//' | tail -1)
  plugin_pub=$(grep -oE "<a href=\"$plugin_latest/\"[^>]*>[^<]*</a>[^0-9]*[0-9]{4}-[0-9]{2}-[0-9]{2}" \
               central/native-maven-plugin-directory-listing.html | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1)
  [ -n "$plugin_pinned" ] || die "no native-maven-plugin version in pom.xml"
  [ -n "$plugin_latest" ] || die "no version list in central/native-maven-plugin-maven-metadata.xml"
  [ -n "$plugin_pub" ]    || die "no publication date for $plugin_latest in the directory listing"

  # The profile's SHAPE, derived from the pom rather than described. A viewer who edits the
  # profile moves these three lines and therefore moves the hash.
  # SCOPED TO THE NATIVE PROFILE'S OWN EXECUTION. A bare grep for the first <goal> in this
  # pom answers `copy-dependencies` - maven-dependency-plugin's, four plugins earlier - and
  # the first run of this block printed exactly that. The execution's id is the anchor.
  local nx; nx=$(sed -n '/<id>build-native<\/id>/,/<\/execution>/p' pom.xml)
  goal=$(printf '%s' "$nx" | grep -oE '<goal>[^<]*' | sed 's/<goal>//' | head -1)
  phase=$(printf '%s' "$nx" | grep -oE '<phase>[^<]*' | sed 's/<phase>//' | head -1)
  image=$(grep -oE '<imageName>[^<]*' pom.xml | sed 's/<imageName>//' | head -1)
  args=$(grep -oE '<buildArg>[^<]*' pom.xml | sed 's/<buildArg>//' | tr '\n' ' ' | sed 's/ $//')
  nargs=$(grep -c '<buildArg>' pom.xml | tr -d ' ')
  [ -n "$goal" ] && [ -n "$phase" ] && [ -n "$image" ] && [ "$nargs" -gt 0 ] \
    || die "could not read the native profile's goal/phase/imageName/buildArgs out of pom.xml"

  graal_tag=$(python3 -c "import json;print(json.load(open('central/graalvm-ce-builds-latest.json'))['tag_name'])")
  graal_date=$(python3 -c "import json;print(json.load(open('central/graalvm-ce-builds-latest.json'))['published_at'][:10])")
  read -r asset asset_bytes <<EOF
$(python3 -c "
import json
d=json.load(open('central/graalvm-ce-builds-latest.json'))
for a in d['assets']:
    if 'macos-aarch64' in a['name'] and a['name'].endswith('.tar.gz'):
        print(a['name'], a['size']); break
")
EOF
  [ -n "$asset_bytes" ] || die "no macos-aarch64 asset in the GraalVM release json"

  { printf 'the native profile and what runs it - every line read out of a file in this unit:\n'
    printf '  native-maven-plugin pinned in pom.xml ... %s\n' "$plugin_pinned"
    printf '  newest in its version list .............. %s, published %s\n' "$plugin_latest" "$plugin_pub"
    printf '  the goal it binds ....................... %s, at the %s phase\n' "$goal" "$phase"
    printf '  the image it names ...................... %s\n' "$image"
    printf '  build arguments ......................... %s   %s\n' "$nargs" "$args"
    printf '  GraalVM CE release ...................... %s, published %s\n' "$graal_tag" "$graal_date"
    printf '  the macOS arm64 asset ................... %s\n' "$asset"
    printf '  its size, in bytes ...................... %s\n' "$asset_bytes"
    printf '\nEvery line above is a property of this REPOSITORY, not of the machine reading it,\n'
    printf 'so this block hashes the same for a viewer with GraalVM and a viewer without one.\n'
    printf 'What the machine can do is ./receipts.sh native - and that block builds a real\n'
    printf 'binary, takes minutes rather than seconds, and is therefore not part of a bare\n'
    printf './receipts.sh run. It says so itself when you ask for it.\n'
  } > .r-graalvm.out 2>&1

  cat .r-graalvm.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-graalvm.out)"
}

# ----------------------------------------------------------------- native ----
# HASHED, MINUTES LONG, AND NOT PART OF `all`. The A/B this unit now turns on: the project
# as it ships builds a binary that works, and the same project with its two reachability
# files deleted builds a binary that is GREEN and BROKEN.
#
# WHERE THE GRAALVM COMES FROM, and it is not hardcoded. GRAALVM_HOME first, then JAVA_HOME
# if it happens to contain a native-image, and otherwise a SKIP that names the variable to
# set - the same shape c3-unit10's `drift` block uses for OLD_GRADLE. A viewer without
# GraalVM gets an explanation, never a failure and never a fabricated hash.
graalvm_home() {
  if [ -n "${GRAALVM_HOME:-}" ] && [ -x "$GRAALVM_HOME/bin/native-image" ]; then
    printf '%s\tGRAALVM_HOME' "$GRAALVM_HOME"; return 0
  fi
  # VIEWER_JAVA_HOME, not JAVA_HOME: line 60 has already overwritten the latter with the
  # plain JDK this unit's other blocks need, so testing it here could never succeed.
  if [ -n "${VIEWER_JAVA_HOME:-}" ] && [ -x "$VIEWER_JAVA_HOME/bin/native-image" ]; then
    printf '%s\tJAVA_HOME' "$VIEWER_JAVA_HOME"; return 0
  fi
  return 1
}

run_native() {
  local gh_line gh src
  gh_line=$(graalvm_home) || gh_line=""
  if [ -z "$gh_line" ]; then
    printf '\nnative       skipped - this block builds a REAL native image and needs a GraalVM JDK.\n'
    printf '             Set GRAALVM_HOME to one and re-run:\n'
    printf '               export GRAALVM_HOME=/path/to/a/graalvm-jdk\n'
    printf '               ./receipts.sh native\n'
    printf '             JAVA_HOME is used instead when it contains bin/native-image. Nothing\n'
    printf '             is guessed and no hash is printed for a build that did not happen.\n'
    return 0
  fi
  gh=${gh_line%%$'\t'*}; src=${gh_line##*$'\t'}

  block "native - the binary, and the same binary without its reachability metadata  [HASHED]"

  local ni_ver
  ni_ver=$("$gh/bin/native-image" --version 2>&1 | head -1)
  [ -n "$ni_ver" ] || die "$gh/bin/native-image printed no version"

  # ---- step 1: the project exactly as it ships.
  local rc_a rc_ap rc_al
  ( export JAVA_HOME="$gh" GRAALVM_HOME="$gh" PATH="$gh/bin:$PATH"
    mvn -B -ntp -Pnative "-Dmaven.repo.local=$PWD/.m2-demo" clean package ) > .r-nat-a.raw 2>&1; rc_a=$?
  [ "$rc_a" -eq 0 ] || die "the shipped project's native build exited $rc_a; see .r-nat-a.raw"
  [ -x target/tiffinbox ] || die "no target/tiffinbox after a BUILD SUCCESS"
  ./target/tiffinbox plain  > .r-nat-ap.raw 2>&1; rc_ap=$?
  ./target/tiffinbox ledger > .r-nat-al.raw 2>&1; rc_al=$?
  [ "$rc_ap" -eq 0 ] && [ "$rc_al" -eq 0 ] \
    || die "the shipped binary failed (plain=$rc_ap ledger=$rc_al); re-measure before anything goes on a slide"
  local bytes_a; bytes_a=$(bytes target/tiffinbox)

  # ---- step 2: the same project, minus the two files, built in a THROW-AWAY COPY so the
  # shipped json files are never deleted even if this run is interrupted.
  local cp_dir; cp_dir=$(mktemp -d "${TMPDIR:-/tmp}/u27ab.XXXXXX") || die "could not make a scratch copy"
  # shellcheck disable=SC2064
  trap "rm -rf '$cp_dir'" EXIT INT TERM
  local meta=src/main/resources/META-INF/native-image
  local removed; removed=$(find "$meta" -name '*.json' -type f | wc -l | tr -d ' ')
  [ "$removed" -eq 2 ] || die "expected 2 reachability json files under $meta, found $removed"
  local names; names=$(find "$meta" -name '*.json' -type f -exec basename {} \; | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')
  mkdir -p "$cp_dir/proj"
  cp pom.xml "$cp_dir/proj/"
  cp -R src "$cp_dir/proj/"
  rm -rf "$cp_dir/proj/$meta"

  local rc_b rc_bp rc_bl
  ( cd "$cp_dir/proj" && export JAVA_HOME="$gh" GRAALVM_HOME="$gh" PATH="$gh/bin:$PATH"
    mvn -B -ntp -Pnative "-Dmaven.repo.local=$UNIT/.m2-demo" clean package ) > .r-nat-b.raw 2>&1; rc_b=$?
  [ "$rc_b" -eq 0 ] || die "the no-metadata native build exited $rc_b, and the whole point is that it SUCCEEDS; see .r-nat-b.raw"
  [ -x "$cp_dir/proj/target/tiffinbox" ] || die "no binary from the no-metadata build"

  # THE GUARD, and it cost this block its first run. maven-resources-plugin does not delete
  # stale resources, so `mvn package` WITHOUT `clean` leaves the previous run's copy of
  # reflect-config.json in target/classes, packages it into the jar, and the deletion becomes
  # invisible: the "broken" binary works, 51,018,376 bytes and all. Both builds above are
  # `clean package`, and this counts what actually reached the jar rather than trusting it.
  local in_jar
  in_jar=$(unzip -l "$cp_dir/proj/target/tiffinbox-core-1.0.0.jar" 2>/dev/null | grep -c 'native-image/.*\.json' || true)
  [ "$in_jar" -eq 0 ] || die "$in_jar reachability file(s) still inside the no-metadata jar - the A/B is a false negative"

  "$cp_dir/proj/target/tiffinbox" plain  > .r-nat-bp.raw 2>&1; rc_bp=$?
  "$cp_dir/proj/target/tiffinbox" ledger > .r-nat-bl.raw 2>&1; rc_bl=$?
  [ "$rc_bp" -ne 0 ] && [ "$rc_bl" -ne 0 ] \
    || die "the no-metadata binary ran (plain=$rc_bp ledger=$rc_bl); the closed-world cost did not reproduce"
  local bytes_b; bytes_b=$(bytes "$cp_dir/proj/target/tiffinbox")

  # ---- every count below is DERIVED from the two build logs.
  stages() { grep -cE '^\[[0-9]+/[0-9]+\] ' "$1" || true; }
  # the total native-image ANNOUNCES in its own [x/N] labels, so "8 of 8" is two derived
  # numbers rather than one number printed twice.
  stage_total() { grep -m1 -oE '^\[[0-9]+/[0-9]+\]' "$1" | grep -oE '/[0-9]+' | tr -d '/'; }
  green() { grep -c '^\[INFO\] BUILD SUCCESS' "$1" || true; }
  reach()  { grep -m1 -E '[0-9,]+ types,.*found reachable' "$1" | grep -oE '^[ ]*[0-9,]+' | tr -d ' ,'; }
  refl()   { grep -m1 -E '[0-9,]+ types,.*registered for reflection' "$1" | grep -oE '^[ ]*[0-9,]+' | tr -d ' ,'; }
  local st_a st_b re_a re_b rf_a rf_b tot_a tot_b gr_a gr_b
  st_a=$(stages .r-nat-a.raw); st_b=$(stages .r-nat-b.raw)
  tot_a=$(stage_total .r-nat-a.raw); tot_b=$(stage_total .r-nat-b.raw)
  gr_a=$(green .r-nat-a.raw); gr_b=$(green .r-nat-b.raw)
  [ "$st_a" = "$tot_a" ] && [ "$st_b" = "$tot_b" ] \
    || die "native-image announced $tot_a/$tot_b stages and printed $st_a/$st_b; the 'N of N' line would be a lie"
  [ "$gr_a" -eq 1 ] && [ "$gr_b" -eq 1 ] \
    || die "expected exactly one BUILD SUCCESS per log, got $gr_a and $gr_b"
  re_a=$(reach  .r-nat-a.raw); re_b=$(reach  .r-nat-b.raw)
  rf_a=$(refl   .r-nat-a.raw); rf_b=$(refl   .r-nat-b.raw)
  for v in "$st_a" "$st_b" "$re_a" "$re_b" "$rf_a" "$rf_b"; do
    [ -n "$v" ] && [ "$v" -gt 0 ] || die "a derived native-image count came out empty or zero; see .r-nat-a.raw / .r-nat-b.raw"
  done
  [ "$st_a" -eq "$st_b" ] || die "the two builds printed $st_a and $st_b stages; they are supposed to be the same eight"
  [ "$rf_b" -lt "$rf_a" ] || die "deleting the metadata did not reduce the reflection count ($rf_a -> $rf_b)"

  # THE FAILURE RECEIPT (contract 2e as amended for Course 4, and the same logic here):
  # exit code, exception TYPE, first line of the MESSAGE. That trio is the same on every
  # machine; the capture around it is not - it carries a JDK-internal frame list whose depth
  # is an implementation detail. So the trio is what gets hashed, and every frame not shown
  # is counted from wc(1) rather than waved at.
  receipt_type() { grep -m1 -oE 'Exception in thread "main" [a-zA-Z0-9_.$]+' "$1" | sed -E 's/.*main" //'; }
  receipt_msg()  { grep -m1 -E 'Exception in thread "main" ' "$1" | sed -E 's/.*Exception: //'; }
  local ty_p ty_l msg_p msg_l fr_p fr_l
  ty_p=$(receipt_type .r-nat-bp.raw); ty_l=$(receipt_type .r-nat-bl.raw)
  msg_p=$(receipt_msg .r-nat-bp.raw); msg_l=$(receipt_msg .r-nat-bl.raw)
  [ -n "$ty_p" ] && [ -n "$ty_l" ] && [ -n "$msg_p" ] && [ -n "$msg_l" ] \
    || die "could not extract a failure receipt from the no-metadata runs"
  [ "$ty_p" = "$ty_l" ] || die "the two failures are different types ($ty_p / $ty_l); the receipt would be two receipts"
  fr_p=$(grep -c '^	at ' .r-nat-bp.raw || true)
  fr_l=$(grep -c '^	at ' .r-nat-bl.raw || true)
  [ "$fr_p" -gt 0 ] || die "no stack frames in the plain failure, so any elision count would be a lie"

  # TWO of the eight frames are kept, and they are the two that explain the failure rather
  # than decorate it: Substrate VM's OWN Class.forName - a native image does not use the
  # JDK's, it consults a registry built at image-build time, and that registry is what the
  # deleted json files were filling in - and the line in this project that called it. The
  # remaining six are three java.base Class.forName overloads, one more ClassForNameSupport
  # frame and a generated LambdaForm holder whose name carries a per-build suffix; none of
  # them is the lesson and the last one would not even hash twice. GraalVM's own line number
  # is masked because it moves with the GraalVM version; Startup.java:43 is NOT masked,
  # because it is this project's line and slide one shows it.
  fail_panel() {  # $1 = capture, $2 = frame count from wc
    grep -m1 '^formatter key' "$1" | sed 's/^/    /'
    grep -m1 'Exception in thread' "$1" | sed 's/^/    /' | mask
    grep -m1 'ClassForNameSupport\.forName' "$1" \
      | sed -E 's#^\t*at [a-z.]*/##; s#(ClassForNameSupport\.java):[0-9]+#\1:<line>#' | sed 's/^/      at /'
    grep -m1 'com\.tiffinbox\.aot\.Startup\.formatterNamed' "$1" \
      | sed -E 's#^\t*at ##' | sed 's/^/      at /'
    printf '    ... %s of the %s frames elided\n' "$(( $2 - 2 ))" "$2"
  }

  { printf 'step 1 - the project exactly as it ships:\n'
    printf '  $ export GRAALVM_HOME=<a GraalVM JDK> ; export JAVA_HOME="$GRAALVM_HOME"\n'
    printf '  $ mvn -B -Pnative -Dmaven.repo.local="$PWD/.m2-demo" clean package\n'
    printf '  native-image stages it printed ....... %s of the %s it announces\n' "$st_a" "$tot_a"
    printf '  BUILD SUCCESS lines in the log ....... %s\n' "$gr_a"
    printf '  mvn exit code ........................ %s\n' "$rc_a"
    printf '  types found reachable ................ %s\n' "$re_a"
    printf '  types registered for reflection ...... %s\n' "$rf_a"
    printf '  $ ./target/tiffinbox plain\n'
    sed 's/^/    /' .r-nat-ap.raw | mask
    printf '    exit %s\n' "$rc_ap"
    printf '  $ ./target/tiffinbox ledger\n'
    sed 's/^/    /' .r-nat-al.raw | mask
    printf '    exit %s\n' "$rc_al"
    printf '\nstep 2 - the SAME project with the two reachability files deleted, nothing else\n'
    printf 'changed, built in a throw-away copy so the shipped files are never touched:\n'
    printf '  files removed ........................ %s   %s\n' "$removed" "$names"
    printf '  reachability files inside its jar .... %s   <- the guard: `package` without `clean`\n' "$in_jar"
    printf '                                             leaves a stale copy in target/classes,\n'
    printf '                                             packages it, and the deletion becomes\n'
    printf '                                             invisible. Both builds here are clean.\n'
    printf '  native-image stages it printed ....... %s of the %s it announces\n' "$st_b" "$tot_b"
    printf '  BUILD SUCCESS lines in the log ....... %s   <- THE BUILD IS GREEN\n' "$gr_b"
    printf '  mvn exit code ........................ %s\n' "$rc_b"
    printf '  types found reachable ................ %s   (%s fewer than step 1)\n' "$re_b" "$(( re_a - re_b ))"
    printf '  types registered for reflection ...... %s   (%s fewer than step 1)\n' "$rf_b" "$(( rf_a - rf_b ))"
    printf '  $ ./target/tiffinbox plain\n'
    fail_panel .r-nat-bp.raw "$fr_p"
    printf '    exit %s\n' "$rc_bp"
    printf '  $ ./target/tiffinbox ledger\n'
    fail_panel .r-nat-bl.raw "$fr_l"
    printf '    exit %s\n' "$rc_bl"
    printf '\nTHE FAILURE RECEIPT - the three parts of a failure that do not move between runs\n'
    printf 'or between machines, which is why this is the trio that gets hashed and the raw\n'
    printf 'capture around it does not:\n'
    printf '  exit code .......................... %s\n' "$rc_bp"
    printf '  exception type ..................... %s\n' "$ty_p"
    printf '  first line of the message (plain) .. %s\n' "$msg_p"
    printf '  first line of the message (ledger) . %s\n' "$msg_l"
    printf '  frames each failure printed ........ %s and %s, from wc - 2 shown above, %s elided\n' \
      "$fr_p" "$fr_l" "$(( fr_p - 2 ))"
    printf '\nA GREEN BUILD THAT PRODUCED A BROKEN ARTIFACT. Nothing failed at build time. The\n'
    printf 'two class names live only in a properties file, the closed-world compiler could\n'
    printf 'not see them, and the two json files are the only reason it ever could. Delete\n'
    printf 'them and the reflection count falls by %s types - and the program that used to\n' "$(( rf_a - rf_b ))"
    printf 'print its answer now names the class it cannot find.\n'
    printf '\nAND THE TWO COSTS ARE NOT THE SAME KIND OF THING. The build printed %s stages and\n' "$st_a"
    printf 'you wait through every one of them, twice over to get this A/B - which is why this\n'
    printf 'block is not part of a bare ./receipts.sh run. The failure cost no build at all: it\n'
    printf 'is in the artifact the green build already produced, and it arrives on the first\n'
    printf 'run. No wall-clock number for either appears here or on any slide (contract 2a).\n'
  } > .r-native.out 2>&1

  cat .r-native.out
  printf 'md5 %s  (exit %s build / %s %s runs, then exit %s build / %s %s runs)\n' \
    "$(hash_of .r-native.out)" "$rc_a" "$rc_ap" "$rc_al" "$rc_b" "$rc_bp" "$rc_bl"
  # NO HARDCODED HISTORY HERE. An earlier draft of this line listed the three sizes three runs
  # had given; a fourth run gave a size that was not in the list. A script cannot know its own
  # past, so it states the rule and this run's two numbers, and README.md records the spread.
  nohash "two byte sizes, printed outside the hash because a size goes on a slide only after it has repeated, and this one does not - README.md records the spread measured across runs (C2 finding #3). As shipped $bytes_a bytes, without the metadata $bytes_b. Built by: $ni_ver, resolved from \$$src."
  rm -rf "$cp_dir"; trap - EXIT INT TERM
}

# ----------------------------------------------------------- nativeconfig ----
# HASHED. The repair, shipped as the real files, checked as real files.
run_nativeconfig() {
  block "nativeconfig - the metadata that makes reflection survive a closed world  [HASHED]"
  local base=src/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-core
  local rc=$base/reflect-config.json res=$base/resource-config.json
  [ -s "$rc" ] || die "no $rc"
  [ -s "$res" ] || die "no $res"
  python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$rc"  || die "reflect-config.json is not valid JSON"
  python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$res" || die "resource-config.json is not valid JSON"

  local entries declared covered
  entries=$(python3 -c "import json;print(len(json.load(open('$rc'))))")
  declared=$(grep -cE '^[a-z]+=com\.tiffinbox\.aot\.' src/main/resources/formatters.properties || true)
  covered=$(python3 -c "
import json
names={e['name'] for e in json.load(open('$rc'))}
want={l.split('=',1)[1].strip() for l in open('src/main/resources/formatters.properties') if l.startswith(('plain=','ledger='))}
print(len(want & names))
")
  [ "$covered" -eq "$declared" ] || die "reflect-config.json covers $covered of $declared formatter classes"

  { printf 'the two files a closed-world build needs, shipped at the path it looks in:\n'
    printf '  %s\n' "META-INF/native-image/com.tiffinbox/tiffinbox-core/reflect-config.json"
    printf '  %s\n' "META-INF/native-image/com.tiffinbox/tiffinbox-core/resource-config.json"
    printf '\nreflect-config.json:\n'
    sed 's/^/  /' "$rc"
    printf '\nentries in reflect-config.json ..................... %s\n' "$entries"
    printf 'formatter classes named in formatters.properties ... %s\n' "$declared"
    printf 'of those, covered by reflect-config.json ........... %s\n' "$covered"
    printf 'valid JSON (parsed, not eyeballed) ................. both files\n'
    printf '\nresource-config.json:\n'
    sed 's/^/  /' "$res"
    printf '\nThat second file is the half people forget. formatters.properties is a RESOURCE,\n'
    printf 'and a closed-world build does not carry resources it cannot see being read either.\n'
    printf 'A binary with the classes and without the properties file fails one line earlier,\n'
    printf 'on the getResourceAsStream, and the message is about a null stream rather than a\n'
    printf 'missing class - so it looks like a different bug entirely.\n'
    printf '\nNeither file changes a normal build: ./receipts.sh offline runs mvn -o test with\n'
    printf 'both of them on the classpath, and the JVM ignores them.\n'
  } > .r-nativeconfig.out 2>&1

  cat .r-nativeconfig.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-nativeconfig.out)"
}

# --------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise, start state proved first  [HASHED]"
  need_jdk25; build_once
  [ -f exercise/solution/reflect-config.json ] || die "no answer at exercise/solution/reflect-config.json"
  [ -f exercise/start/reflect-config.json ] || die "no start state at exercise/start/reflect-config.json"

  local before after want
  want=$(python3 -c "
print(len({l.split('=',1)[1].strip() for l in open('src/main/resources/formatters.properties') if l.startswith(('plain=','ledger='))}))")
  cover() { python3 -c "
import json,sys
names={e['name'] for e in json.load(open(sys.argv[1]))}
want={l.split('=',1)[1].strip() for l in open('src/main/resources/formatters.properties') if l.startswith(('plain=','ledger='))}
print(len(want & names))" "$1"; }
  before=$(cover exercise/start/reflect-config.json)
  after=$(cover exercise/solution/reflect-config.json)
  [ "$before" -lt "$want" ] || die "the start state already covers every formatter - there is nothing to fix"

  # And the same question asked of the JVM, which is the only one that counts: with the
  # start state's coverage, which classes would a closed-world build have?
  { printf 'start state - exercise/start/reflect-config.json\n'
    sed 's/^/  /' exercise/start/reflect-config.json
    printf '  formatter classes named in formatters.properties ... %s\n' "$want"
    printf '  of those, covered .................................. %s\n' "$before"
    printf '  so a closed-world build from this metadata is missing %s of them, and the\n' "$(( want - before ))"
    printf '  failure is Class.forName -> ClassNotFoundException, at run time, in production.\n'
    printf '\nanswer - exercise/solution/reflect-config.json\n'
    printf '  of %s formatter classes, covered .................... %s\n' "$want" "$after"
    printf '  entries added ...................................... %s\n' \
      "$(( $(python3 -c "import json;print(len(json.load(open('exercise/solution/reflect-config.json'))))") - $(python3 -c "import json;print(len(json.load(open('exercise/start/reflect-config.json'))))") ))"
    printf '  lines of Java changed .............................. 0\n'
    printf '\nand the check that would have caught it without a GraalVM JDK at all:\n'
    printf '  every value in formatters.properties, compared against the names in the json.\n'
    printf '  That is eight lines of Python, it runs in CI, and it costs no minutes.\n'
  } > .r-solution.out 2>&1

  cat .r-solution.out
  # The trailer is printed AFTER the hash is taken over .r-solution.out, so its wording is not
  # part of fe2edae3...; it said "this machine cannot run the build that consumes it", which was
  # true until 2026-09-16 and is not any more. ./receipts.sh native IS that build.
  printf 'md5 %s  (no build - the answer is data; ./receipts.sh native is the build that consumes it, and it costs minutes)\n' \
    "$(hash_of .r-solution.out)"
  [ "$after" -eq "$want" ] || die "the answer covers $after of $want formatter classes"
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
    printf 'the native profile is NOT part of this run, and is not part of any default build\n'
  } > .r-offline.out 2>&1
  cat .r-offline.out
  printf 'md5 %s  (exit %s)\n' "$(hash_of .r-offline.out)" "$rc"
}

case "${1:-all}" in
  closedworld)  run_closedworld ;;
  aot)          run_aot ;;
  jlink)        run_jlink ;;
  graalvm)      run_graalvm ;;
  native)       run_native ;;
  nativeconfig) run_nativeconfig ;;
  solution)     run_solution ;;
  offline)      run_offline ;;
  # `native` is NOT in `all`: it needs a GraalVM JDK and it takes minutes. Ask for it.
  all) run_closedworld; run_aot; run_jlink; run_graalvm; run_nativeconfig; run_solution; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
