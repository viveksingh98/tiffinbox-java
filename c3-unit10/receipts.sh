#!/bin/zsh
# receipts.sh [id]  — re-runs the exact pipelines this unit's README quotes and prints their md5.
# Every hash in README.md comes from here and from nothing else.
#
#   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
#   export PATH="$JAVA_HOME/bin:$PATH"
#   ./receipts.sh
#
# Two blocks need something extra and say so:
#   drift   needs a SECOND Gradle distribution:  OLD_GRADLE=/path/to/gradle-8.5/bin/gradle ./receipts.sh drift
#   shapin  downloads a distribution into a throw-away Gradle home (it is the download that is checked)
set -u
cd "${0:A:h}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PWD/.gradle-home}"
want="${1:-all}"
sel() { [[ "$want" == "all" || "$want" == "$1" ]] }
M() { mvn -o -B -Dmaven.repo.local="$PWD/.m2-demo" "$@" }
G() { ./gradlew --console=plain --offline --no-build-cache "$@" }

# The one duration regex for the section: `in 493ms`, `in 12s`, `in 1.5s`, `in 1m 2s`, `in 1h 2m 3s`.
DUR='s/ in ([0-9]+h )?([0-9]+m )?[0-9]+(\.[0-9]+)?(ms|s)$//'

# ─────────────────────────────────────────────────────────────────────────────────────────────
# WARM — the guard every measuring block in this file now runs first, and the reason it exists.
#
# Every Maven call here is `mvn -o` and every Gradle call is `--offline`, against a `.m2-demo`
# and a Gradle cache that a clean clone does not contain. So on the viewer's machine both builds
# failed, `grep -c` returned 0 for "no match" and swallowed the failure, and `counts` printed six
# confident zeros and an md5 over a build that never ran. `samejars` was worse: it printed
# "(same five jars, same names)" and "(no differences - 0 of 0 class files identical)" over two
# failed `ls` and a `zipinfo: cannot find or open`. Those are receipts that cannot fail, which
# makes them not receipts at all.
#
# WARM does one online build with each tool if the outputs are missing (contract §1a tier 1,
# resolution only), and RETURNS NON-ZERO, loudly, if either cannot be made to work. Once warm it
# is silent and instant, and the offline measurements underneath it then mean what they say.
WARM() {
  [[ -f tiffinbox-web/target/tiffinbox-web-1.0.0.jar ]] || {
    mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q clean package >/dev/null 2>&1 || {
      echo "$1: WARM-UP FAILED — mvn clean package could not build target/." >&2
      echo "$1: refusing to print counts for a build that did not run." >&2
      return 1 } }
  [[ -f tiffinbox-web/build/libs/tiffinbox-web-1.0.0.jar ]] || {
    ./gradlew --console=plain -q build >/dev/null 2>&1 || {
      echo "$1: WARM-UP FAILED — ./gradlew build could not build build/libs/." >&2
      echo "$1: refusing to print counts for a build that did not run." >&2
      return 1 } }
  return 0
}

# CNT — a counted grep that refuses to answer when the command it counted failed.
# `grep -c` prints 0 both for "ran and matched nothing" and for "never ran", which is how six
# zeros got onto a slide. This separates the two.
CNT() { local out; out=$(eval "$1" 2>&1)
        if [[ $? -ne 0 ]]; then printf 'FAILED (the build exited non-zero — this is not a count)\n'
        else print -r -- "$out" | grep -cE "$2"; fi }

if sel counts; then
 if WARM counts; then
  {
    echo '--- MAVEN ---'
    echo '$ mvn -o -B clean package | grep -c "^\[INFO\] --- "          # goal lines'
    CNT 'M clean package' '^\[INFO\] --- '
    echo '$ mvn -o -B package       | grep -c "^\[INFO\] --- "          # nothing changed'
    CNT 'M package' '^\[INFO\] --- '
    echo '$ mvn -o -B package       | grep -c "Nothing to compile"      # goals that said so'
    CNT 'M package' 'Nothing to compile'
    echo
    echo '--- GRADLE ---'
    echo '$ ./gradlew --offline clean build | grep -c "^> Task "        # task lines'
    CNT 'G clean build' '^> Task '
    G clean build 2>&1 | grep -E 'actionable'
    echo '$ ./gradlew --offline build       | grep -c "^> Task "        # nothing changed'
    CNT 'G build' '^> Task '
    G build 2>&1 | grep -E 'actionable'
    echo '$ ./gradlew --offline build       | grep -c "UP-TO-DATE"      # tasks that said so'
    CNT 'G build' 'UP-TO-DATE'
  } > /tmp/r10a.txt
  printf '%-12s %s\n' counts "$(md5 < /tmp/r10a.txt)"
 fi
fi

if sel states; then
 if WARM states; then
  # `states` used to measure whatever the previous block happened to leave behind: straight after
  # `counts` it returned the slide's hash, and after a `clean` it could not. It now puts the tree
  # into the one state it is describing — a completed build, nothing changed — before measuring.
  G build >/dev/null 2>&1
  printf '%-12s %s\n' states \
    "$(G build 2>&1 | grep -oE 'UP-TO-DATE|NO-SOURCE|FROM-CACHE' | sort | uniq -c | md5)"
 fi
fi

if sel stat; then
 if WARM stat; then
  # Slide 2 row 3 is one of this unit's two UNIQUEs — "Maven is genuinely incremental here", proved
  # with timestamps rather than with the log. It had no block: the numbers were measured by hand at
  # authoring time and the viewer had nothing to re-run. This block re-runs it.
  #
  # It prints the COMPARISON, never the raw mtimes: an epoch second is this machine on this morning
  # (§2a), while "unchanged" is the fact the slide is actually claiming, and it is hashable.
  J=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  S() { stat -f %m "$1" }
  {
    echo '$ mvn -o -B package   # nothing changed since the last build'
    jar0=$(S $J); md0=$(md5 -q $J)
    cls0=$(for c in tiffinbox-web/target/classes/**/*.class(N); do S $c; done)
    lib0=$(for l in tiffinbox-web/target/lib/*.jar(N); do S $l; done)
    nc=$(M package 2>&1 | grep -c 'Nothing to compile')
    jar1=$(S $J); md1=$(md5 -q $J)
    cls1=$(for c in tiffinbox-web/target/classes/**/*.class(N); do S $c; done)
    lib1=$(for l in tiffinbox-web/target/lib/*.jar(N); do S $l; done)
    printf 'jar mtime        : %s\n' "$([[ $jar0 == $jar1 ]] && echo unchanged || echo CHANGED)"
    printf 'jar md5          : %s\n' "$([[ $md0  == $md1  ]] && echo unchanged || echo CHANGED)"
    printf 'class mtimes     : %s (%d files)\n' "$([[ $cls0 == $cls1 ]] && echo unchanged || echo CHANGED)" "$(print -r -- "$cls0" | grep -c .)"
    printf 'target/lib mtimes: %s (%d jars)\n'  "$([[ $lib0 == $lib1 ]] && echo unchanged || echo CHANGED)" "$(print -r -- "$lib0" | grep -c .)"
    printf 'goals that said "Nothing to compile": %d\n' "$nc"
  } > /tmp/r10g.txt
  printf '%-12s %s\n' stat "$(md5 < /tmp/r10g.txt)"
 fi
fi

if sel conflines; then
  {
    echo '$ wc -l pom.xml tiffinbox-*/pom.xml'
    wc -l pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml
    echo
    echo '$ wc -l settings.gradle.kts build.gradle.kts gradle/libs.versions.toml tiffinbox-*/build.gradle.kts'
    wc -l settings.gradle.kts build.gradle.kts gradle/libs.versions.toml tiffinbox-core/build.gradle.kts tiffinbox-web/build.gradle.kts
    echo
    # ONE RULE, BOTH COLUMNS: strip each language's comments, then count the non-blank lines.
    #
    # The Maven side used to carry a fourth alternative the Gradle side did not — `^\s+[A-Za-z]`,
    # "any indented line starting with a letter". On the three POMs that deleted 11 lines, six of
    # them real XML: the `xmlns:xsi=` and `xsi:schemaLocation=` attribute continuations of each
    # `<project>` element, under a row headed "comments and blanks removed". They are neither.
    # Applied to the Gradle files the same rule would have deleted 10 of the surviving 43 —
    # `options.release = 25`, `implementation(project(":tiffinbox-core"))`, `manifest {` and seven
    # more, every one of them code. So it was not a comment-stripper written twice; it was one
    # rule for one column and a different rule for the other, and §9 requires identical rows.
    # Stripping XML comments properly (they span lines; a line-wise grep cannot see their
    # interiors) gives maven 155 against gradle 43. The gap the row is about — XML closes every
    # element it opens — is untouched; only the deciding number changes, and it changes upward.
    echo '# same files with comments stripped and blank lines removed:'
    echo -n 'maven  : '; cat pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml | perl -0pe 's/<!--.*?-->//gs' | grep -c '\S'
    echo -n 'gradle : '; cat settings.gradle.kts build.gradle.kts gradle/libs.versions.toml tiffinbox-*/build.gradle.kts | grep -vE '^\s*$|^\s*//|^\s*#' | grep -c .
  } > /tmp/r10b.txt
  printf '%-12s %s\n' conflines "$(md5 < /tmp/r10b.txt)"
fi

if sel samejars; then
 if WARM samejars; then
  C() { for e in $(unzip -Z1 "$1" | grep '\.class$' | sort); do printf '%s  %s\n' "$(unzip -p "$1" $e | md5 -q)" "$e"; done }
  # CH — the ONE number slide 1 and slide 6 quote as the unit's headline:
  # the md5 of the md5s of every `.class` member, in sorted order. It was computed by hand at
  # authoring time and appeared in no block of this script, while `samejars` hashed a diff
  # TRANSCRIPT and produced d9259d97…, a value quoted in no script, deck, brief or README.
  # Slide 6's chip promises "a receipts.sh with 9 blocks, so you regenerate every hash on these
  # slides". It now emits both: the transcript hash AND the class hash the slides actually name.
  CH() { for e in $(unzip -Z1 "$1" | grep '\.class$' | sort); do unzip -p "$1" $e | md5 -q; done | md5 }
  MJ=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  GJ=tiffinbox-web/build/libs/tiffinbox-web-1.0.0.jar
  {
    echo '$ ls tiffinbox-web/target/lib   vs   tiffinbox-web/build/libs/lib'
    diff <(ls tiffinbox-web/target/lib) <(ls tiffinbox-web/build/libs/lib) && echo '  (same five jars, same names)'
    echo '$ diff <(classmd5 maven-jar) <(classmd5 gradle-jar)'
    diff <(C $MJ) <(C $GJ) && echo "  (no differences - $(C $MJ | wc -l | tr -d ' ') of $(C $GJ | wc -l | tr -d ' ') class files identical)"
    echo '$ diff <(unzip -Z1 maven-jar | sort) <(unzip -Z1 gradle-jar | sort)'
    diff <(unzip -Z1 $MJ | sort) <(unzip -Z1 $GJ | sort)
  } > /tmp/r10c.txt
  printf '%-12s %s\n' samejars "$(md5 < /tmp/r10c.txt)"
  printf '%-12s %s  (maven jar)\n'  samejars-cls "$(CH $MJ)"
  printf '%-12s %s  (gradle jar)\n' samejars-cls "$(CH $GJ)"
 fi
fi

if sel wrappers; then
  {
    echo '$ ls gradlew gradle/wrapper/ mvnw .mvn/wrapper/'
    ls gradlew gradle/wrapper/ mvnw .mvn/wrapper/
    echo
    echo '$ grep -E "distributionUrl|Sha256" gradle/wrapper/gradle-wrapper.properties'
    grep -E 'distributionUrl|Sha256' gradle/wrapper/gradle-wrapper.properties
    echo '$ grep distributionUrl .mvn/wrapper/maven-wrapper.properties'
    grep distributionUrl .mvn/wrapper/maven-wrapper.properties
    echo
    echo '$ shasum -a 256 gradle/wrapper/gradle-wrapper.jar'
    shasum -a 256 gradle/wrapper/gradle-wrapper.jar
  } > /tmp/r10d.txt
  printf '%-12s %s\n' wrappers "$(md5 < /tmp/r10d.txt)"
fi

if sel mvnw; then
  # The slide shows three edited lines — the commit hash dropped from line 1, the Maven home
  # path masked on line 2, the vendor and runtime dropped from line 3 — under a caption reading
  # "the Maven home path masked and the mask shown". There was no mask in the receipt: it hashed
  # the raw three lines, absolute path included, so the number depended on where the repository
  # had been cloned. The author got c0324667…, RED got 201f5c2d…, this pass got 9d34dca3…: three
  # machines, three hashes, for a capture the slide presents as reproducible. The mask below is
  # the one printed on the slide, so the hash is now over exactly the bytes on screen.
  printf '%-12s %s\n' mvnw "$(MAVEN_USER_HOME="$PWD/.m2-demo" ./mvnw -v 2>&1 | head -3 \
    | sed -E 's|^(Maven home: ).*(/\.m2-demo/.*)$|\1<your project>\2|' \
    | sed -E 's/^(Apache Maven [0-9.]+).*/\1/; s/^(Java version: [0-9.]+).*/\1/' | md5)"
fi

if sel probe; then
 if WARM probe; then
  ( cd tiffinbox-web
    P() { : > /tmp/probe.out
          java -Djava.util.logging.config.file=logging.properties -jar "$1" > /tmp/probe.out 2>&1 &
          local pid=$!
          for i in $(seq 1 120); do grep -q "TiffinBox listening" /tmp/probe.out && break; sleep 0.25; done
          cat /tmp/probe.out
          curl -s http://127.0.0.1:18425/customers; echo
          curl -s http://127.0.0.1:18425/dashboard; echo
          curl -s http://127.0.0.1:18425/kitchen; echo
          curl -s http://127.0.0.1:18425/revenue; echo
          curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18425/pauses
          curl -s -w ' %{http_code}\n' http://127.0.0.1:18425/shutdown
          curl -s -X POST http://127.0.0.1:18425/shutdown; echo
          wait $pid 2>/dev/null }
    printf '%-12s %s   (maven jar)\n'  probe "$(P target/tiffinbox-web-1.0.0.jar | md5)"
    printf '%-12s %s   (gradle jar)\n' probe "$(P build/libs/tiffinbox-web-1.0.0.jar | md5)" )
 fi
fi

if sel drift; then
  if [[ -z "${OLD_GRADLE:-}" ]]; then
    echo "drift        skipped - set OLD_GRADLE=/path/to/an/older/gradle/bin/gradle"
  else
    OH="$PWD/.gh-old"
    {
      echo '$ gradle --version | grep ^Gradle        # the gradle that is on this machine'"'"'s PATH'
      GRADLE_USER_HOME="$OH" "$OLD_GRADLE" -q --version 2>/dev/null | grep '^Gradle'
      echo '$ gradle build                           # ...so this is what the project gets'
      GRADLE_USER_HOME="$OH" "$OLD_GRADLE" --console=plain build 2>&1 | sed -n '/What went wrong/,/^\* Try/p' | grep -v '^\* Try'
      GRADLE_USER_HOME="$OH" "$OLD_GRADLE" --stop >/dev/null 2>&1
      echo '... 4 JDK-25 native-access WARNING lines elided ...'
      echo
      echo '$ ./gradlew --version | grep ^Gradle     # the gradle the PROJECT names'
      ./gradlew --console=plain -q --version | grep '^Gradle'
      echo '$ ./gradlew build'
      ./gradlew --console=plain --offline build 2>&1 | grep -E '^BUILD|actionable' | sed -E "$DUR"
    } > /tmp/r10e.txt
    printf '%-12s %s\n' drift "$(md5 < /tmp/r10e.txt)"
  fi
fi

if sel stacktrace; then
  # ─────────────────────────────────────────────────────────────────────────────────────────────
  # The `--stacktrace` panel on slide 5. It had NO block here at all — the only capture in the
  # section with no receipt and no hash — while slide 6's chip promises every hash is regenerable.
  # It was also labelled "verbatim" and declared "... 8 frames elided ...", spliced between two
  # frames that are sixteen apart.
  #
  # AND THE COUNT MOVES WITH THE DAEMON. Measured this pass, same machine, same Gradle 8.5:
  #     virgin .gh-old          283 frames, Kotlin-DSL frame at 19  → interior 15, tail 264
  #     after `gradle --stop`   273 frames, Kotlin-DSL frame at  9  → interior  5, tail 264
  #     warm daemon             272 frames, Kotlin-DSL frame at  8  → interior  4, tail 264
  # So "15 frames elided" is no more a fact than "8" was: it is true of exactly one cache state.
  # This block therefore PINS the state — daemon stopped, Gradle home deleted — the way slide 3
  # pins its timing conditions, and then MEASURES both cuts from the run that produced the lines
  # above them. Deterministic 3/3 under that condition, and the condition is named on the slide.
  if [[ -z "${OLD_GRADLE:-}" ]]; then
    echo "stacktrace   skipped - set OLD_GRADLE=/path/to/an/older/gradle/bin/gradle"
  else
    OH="$PWD/.gh-old"
    GRADLE_USER_HOME="$OH" "$OLD_GRADLE" --stop >/dev/null 2>&1
    rm -rf "$OH"
    raw=$(GRADLE_USER_HOME="$OH" "$OLD_GRADLE" --console=plain --stacktrace build 2>&1)
    GRADLE_USER_HOME="$OH" "$OLD_GRADLE" --stop >/dev/null 2>&1
    # the contiguous frame block under the exception, and the index of the Gradle-Kotlin-DSL frame
    frames=$(print -r -- "$raw" | awk '/^java\.lang\.IllegalArgumentException: /{f=1;next} f&&/^\tat /{print} f&&!/^\tat /{exit}')
    total=$(print -r -- "$frames" | grep -c .)
    idx=$(print -r -- "$frames" | grep -n 'KotlinCompiler\.kt:429' | head -1 | cut -d: -f1)
    {
      echo '$ gradle --stacktrace build      # frames 1-3, then the Gradle frame that called them'
      print -r -- "$raw" | grep -m1 '^java\.lang\.IllegalArgumentException: '
      print -r -- "$frames" | head -3
      printf '\t... %d frames elided (Kotlin'"'"'s jrt filesystem and module finder) ...\n' "$(( idx - 4 ))"
      print -r -- "$frames" | sed -n "${idx}p"
      printf '\t... %d frames elided (Gradle'"'"'s script compilation and build-operation stack) ...\n' "$(( total - idx ))"
      printf '# measured this run: %d frames in the block, the Gradle frame at %d\n' "$total" "$idx"
    } > /tmp/r10f.txt
    printf '%-12s %s\n' stacktrace "$(md5 < /tmp/r10f.txt)"
  fi
fi

if sel shapin; then
  # The distribution checksum is verified when the zip is DOWNLOADED, so this needs a Gradle home
  # that has never held 9.7.1. It downloads ~130 MB into .gh-fresh and deletes it again.
  cp gradle/wrapper/gradle-wrapper.properties /tmp/gwp.bak
  # This block edits a checked-in file in place and puts it back afterwards. A Ctrl-C, or a failed
  # 130 MB download, used to leave the viewer's wrapper pinned to a checksum that is deliberately
  # wrong, with no warning and no way to guess why every later build refuses. The trap restores it
  # on any exit path.
  trap 'cp /tmp/gwp.bak gradle/wrapper/gradle-wrapper.properties 2>/dev/null; rm -rf .gh-fresh' INT TERM EXIT
  sed -i '' 's/^distributionSha256Sum=acd/distributionSha256Sum=bcd/' gradle/wrapper/gradle-wrapper.properties
  rm -rf .gh-fresh
  out=$(GRADLE_USER_HOME="$PWD/.gh-fresh" ./gradlew --console=plain -q --version 2>&1 \
        | grep -vE '^\s+at org\.gradle|%$' \
        | sed -E 's|^Download Location: .*|Download Location: <your Gradle home>/wrapper/dists/gradle-9.7.1-bin/…/gradle-9.7.1-bin.zip|')
  trap - INT TERM EXIT
  cp /tmp/gwp.bak gradle/wrapper/gradle-wrapper.properties
  rm -rf .gh-fresh
  printf '%-12s %s\n' shapin "$(print -r -- "$out" | md5)"
fi
