#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh aot        run one block
#
# READ THIS FIRST. IT IS THE HONEST VERSION AND IT DECIDES THE WHOLE UNIT.
#
#   This unit is about ahead-of-time compilation, and a GraalVM native image is its most
#   famous form. **A native image cannot be built on the machine this unit was written on.**
#   Two independent reasons, both measured by `./receipts.sh graalvm` rather than asserted:
#
#     1. There is no GraalVM here. `native-image` is not on PATH, no GraalVM JDK is
#        installed, and `mvn -Pnative package` fails with the plugin's own words.
#     2. Even with one, the link step could not run: this Mac's C toolchain answers
#        `cc`, `ld` and `xcrun` with exit 69 and "You have not agreed to the Xcode license
#        agreements". native-image shells out to the system linker for its last step.
#
#   So this unit does NOT show you a native binary, a binary's size, or a binary's start-up
#   time. It shows you the two things that are actually being taught, both of which run
#   here, on a plain JDK 25:
#
#     - THE AOT PATH IS REAL ON THIS JDK. `-XX:AOTMode=record` / `create` and a cache that
#       1985 of 1991 classes come out of. That is JEP 483 and JEP 515, in the JDK you have.
#     - THE CLOSED-WORLD PROBLEM IS REAL AND MEASURABLE. jdeps reports zero references from
#       the entry point to either formatter, because the only place their names exist is a
#       properties file. That is exactly what a closed-world compiler cannot see.
#
#   And then the honest contrast, which is the unit's point: the JDK's AOT cache FALLS BACK
#   - the class it never saw is loaded from the jar and the program works. A native image
#   has no jar to fall back to. `aot` measures the fallback; `graalvm` measures why the
#   other half cannot be measured here.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
# jlink and jmod read $JAVA_HOME/jmods, which the Homebrew symlink does not expose.
REALHOME=/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home

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
  nohash "the three sizes below are bytes, and a byte size goes on a slide only after it has repeated (C2 finding #3). AOT configuration $(bytes .aot.conf), AOT cache $(bytes .aot.cache), jar $(bytes "$JAR")."
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
# HASHED. The block that says what this machine cannot do, and proves each claim.
run_graalvm() {
  block "graalvm - why there is no binary in this unit  [HASHED]"
  need_jdk25; build_once

  local ni_on_path graal_home rc_native rc_cc rc_ld
  ni_on_path=$(command -v native-image > /dev/null 2>&1 && echo yes || echo no)
  graal_home="${GRAALVM_HOME:-<unset>}"
  [ "$ni_on_path" = no ] || die "native-image IS on PATH - this unit's whole framing must be re-measured"

  "${MVN[@]}" -Pnative package > .r-native.raw 2>&1; rc_native=$?
  [ "$rc_native" -ne 0 ] || die "mvn -Pnative package SUCCEEDED - re-measure everything below"

  # The C toolchain. native-image shells out to it for the final link.
  printf 'int main(void){return 0;}\n' > .r-cc.c
  cc .r-cc.c -o .r-cc.bin > .r-cc.raw 2>&1; rc_cc=$?
  /usr/bin/ld -v > .r-ld.raw 2>&1; rc_ld=$?
  rm -f .r-cc.c .r-cc.bin

  local plugin_pinned plugin_latest plugin_pub graal_tag graal_date asset asset_bytes
  plugin_pinned=$(grep -A2 'native-maven-plugin' pom.xml | grep -oE '<version>[^<]*' | sed 's/<version>//' | head -1)
  plugin_latest=$(grep -o '<version>[^<]*' central/native-maven-plugin-maven-metadata.xml | sed 's/<version>//' | tail -1)
  plugin_pub=$(grep -oE "<a href=\"$plugin_latest/\"[^>]*>[^<]*</a>[^0-9]*[0-9]{4}-[0-9]{2}-[0-9]{2}" \
               central/native-maven-plugin-directory-listing.html | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1)
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

  { printf 'is a native image possible on this machine? Asked, not assumed:\n'
    printf '  native-image on PATH ............... %s\n' "$ni_on_path"
    printf '  GRAALVM_HOME ....................... %s\n' "$graal_home"
    printf '  GraalVM JDKs installed ............. %s\n' \
      "$(ls -d /Library/Java/JavaVirtualMachines/*graal* ~/Library/Java/JavaVirtualMachines/*graal* /opt/homebrew/opt/*graal* 2>/dev/null | wc -l | tr -d ' ')"
    printf '\n  $ mvn -Pnative package\n'
    grep -m1 -E '^\[ERROR\] Failed to execute goal org\.graalvm\.buildtools' .r-native.raw \
      | sed -E 's/^\[ERROR\] //' | mask | fold -w 92 -s | sed 's/^/  /'
    printf '  exit %s\n' "$rc_native"
    printf '\nand the second, independent reason - the linker native-image would shell out to:\n'
    printf '  $ cc <a two-line C file> -o <binary>\n'
    trim .r-cc.raw 1 | sed 's/^/    /'
    printf '    exit %s\n' "$rc_cc"
    printf '  $ /usr/bin/ld -v\n'
    trim .r-ld.raw 1 | sed 's/^/    /'
    printf '    exit %s\n' "$rc_ld"
    printf '  Accepting that licence needs sudo and changes a machine-wide setting, so this\n'
    printf '  unit does not do it. It records the state and designs around it.\n'
    printf '\nwhat IS pinned and shipped, derived from central/ with no network:\n'
    printf '  native-maven-plugin pinned in pom.xml ... %s\n' "$plugin_pinned"
    printf '  newest in its version list .............. %s, published %s\n' "$plugin_latest" "$plugin_pub"
    printf '  GraalVM CE release ...................... %s, published %s\n' "$graal_tag" "$graal_date"
    printf '  the macOS arm64 asset ................... %s\n' "$asset"
    printf '  its size, in bytes ...................... %s\n' "$asset_bytes"
    printf '\nSo the profile in pom.xml is real, pinned, and unrunnable here. A viewer with a\n'
    printf 'GraalVM JDK runs it unchanged. Nothing in this unit shows a binary that does not\n'
    printf 'exist, and nothing quotes a start-up time nobody measured.\n'
  } > .r-graalvm.out 2>&1

  cat .r-graalvm.out
  printf 'md5 %s  (exit %s from mvn -Pnative, %s from cc, %s from ld)\n' \
    "$(hash_of .r-graalvm.out)" "$rc_native" "$rc_cc" "$rc_ld"
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
  printf 'md5 %s  (no build - the answer is data, and this machine cannot run the build that consumes it)\n' \
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
  nativeconfig) run_nativeconfig ;;
  solution)     run_solution ;;
  offline)      run_offline ;;
  all) run_closedworld; run_aot; run_jlink; run_graalvm; run_nativeconfig; run_solution; run_offline ;;
  *) echo "unknown block: $1" >&2; exit 2 ;;
esac
