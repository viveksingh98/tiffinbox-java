#!/bin/zsh
# receipts.sh [id]  — re-runs the exact pipelines this unit's README quotes and prints their md5.
# Every block puts tiffinbox-core back to `api(libs.h2)` when it is done, so the working tree is
# the same before and after. Every hash in README.md comes from here and from nothing else.
set -u
cd "${0:A:h}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PWD/.gradle-home}"
want="${1:-all}"
sel() { [[ "$want" == "all" || "$want" == "$1" ]] }
API()  { sed -i '' 's/^    implementation(libs.h2)$/    api(libs.h2)/' tiffinbox-core/build.gradle.kts }
IMPL() { sed -i '' 's/^    api(libs.h2)$/    implementation(libs.h2)/' tiffinbox-core/build.gradle.kts }

# The one duration regex for the section — Gradle prints `in 493ms`, `in 12s`, `in 1.5s`,
# `in 1m 2s` and `in 1h 2m 3s`, and a regex that only catches the first two lets a wall-clock
# number into a hashed capture on any machine slow enough to cross a minute.
DUR='s/ in ([0-9]+h )?([0-9]+m )?[0-9]+(\.[0-9]+)?(ms|s)$//'

# PATHMASK strips this checkout's own directory off javac's absolute paths. It used to be
# anchored to `/Users/`, which masks nothing on Linux, in CI, or in any clone outside a macOS
# home — three absolute paths then stayed in the hashed bytes and the receipt could not be
# reproduced by anyone but its author. §8.5: a hash over output the viewer cannot regenerate is
# not a receipt. Anchoring on the unit directory works wherever the repository is cloned.
PATHMASK='s|^( *).*/c3-unit09/|\1|'

if sel flip; then
  API; ./gradlew --console=plain -q clean >/dev/null 2>&1
  {
    echo '$ grep "libs.h2" tiffinbox-core/build.gradle.kts'
    grep -o 'api(libs.h2)' tiffinbox-core/build.gradle.kts
    echo '$ ./gradlew :tiffinbox-web:compileJava | grep -E "^> Task :tiffinbox-web|^BUILD"'
    ./gradlew --console=plain :tiffinbox-web:compileJava 2>&1 \
      | grep -E '^> Task :tiffinbox-web|^BUILD' | sed -E "$DUR"
    IMPL; ./gradlew --console=plain -q clean >/dev/null 2>&1
    echo
    echo '$ grep "libs.h2" tiffinbox-core/build.gradle.kts'
    grep -o 'implementation(libs.h2)' tiffinbox-core/build.gradle.kts
    # The grep below is now printed on the slide's panel head. It selects Gradle's own
    # `* What went wrong:` re-print of the compiler output — the indented copy, two spaces then a
    # slash — and NOT javac's unindented block, which this command also prints and prints FIRST.
    # The two blocks carry the same three errors in a different order; the slide used to show the
    # re-print while the panel head promised the bare command, so the viewer's screen disagreed
    # with the slide about which error came last.
    echo '$ ./gradlew :tiffinbox-web:compileJava | grep -E "^> Task :tiffinbox-web|^  /.*error:|^    symbol:|^  [0-9]+ errors?$|^BUILD"'
    ./gradlew --console=plain :tiffinbox-web:compileJava 2>&1 \
      | grep -E '^> Task :tiffinbox-web|^  /.*error:|^    symbol:|^  [0-9]+ errors?$|^BUILD' \
      | sed -E "$PATHMASK" | sed -E "$DUR"
  } > /tmp/r09a.txt
  API
  printf '%-12s %s\n' flip "$(md5 < /tmp/r09a.txt)"
fi

if sel classpaths; then
  # T — print the head of one configuration's dependency report, then a COUNTED elision for the
  # jackson subtree underneath it.
  #
  # The count used to be the literal string "7 lines elided", printed unconditionally, outside the
  # awk, never measured — and the subtree is 8 lines, in all four of the blocks this function
  # produces. A number a script prints whatever the build did is not a count; it cannot be wrong
  # on one run and right on the next, which means it is never evidence of anything. Both halves
  # below now come out of the same `full`, so the marker moves when the dependency graph does.
  T() { local full=$(./gradlew --console=plain -q :tiffinbox-web:dependencies --configuration $1 2>&1)
        local body=$(print -r -- "$full" | awk '/^.--- com.fasterxml/{p=1} p&&/^$/{p=0} p')
        print -r -- "$full" | awk '/^(compile|runtime)Classpath - /{p=1} p&&/^.--- com.fasterxml/{p=0} p'
        printf '     ... the jackson subtree, %d lines elided ...\n' "$(print -r -- "$body" | grep -c .)" }
  API
  {
    echo '$ ./gradlew :tiffinbox-web:dependencies --configuration <name> | awk "/^(compile|runtime)Classpath - /{p=1} p&&/^.--- com.fasterxml/{p=0} p"'
    echo '=== tiffinbox-core/build.gradle.kts :  api(libs.h2)'
    T compileClasspath; T runtimeClasspath
    IMPL
    echo
    echo '=== tiffinbox-core/build.gradle.kts :  implementation(libs.h2)'
    T compileClasspath; T runtimeClasspath
  } > /tmp/r09b.txt
  API
  printf '%-12s %s\n' classpaths "$(md5 < /tmp/r09b.txt)"
fi

if sel catalog; then
  {
    # The `grep -v './exercise'` that used to sit here is gone. It was not on the slide, and it
    # turned a four-hit grep into a two-hit grep under a chip claiming "two version strings in the
    # whole project". `exercise/gradle/libs.versions.toml` is a byte-identical copy of the catalog
    # and ships in this same tree, so it is a real hit. The unit's beat is "not a promise — a
    # grep"; filtering the grep until it agrees with the promise is the one thing that beat cannot
    # survive. `conflict/` stays excluded because that exclusion IS on the slide.
    echo '$ grep -rn "2.5.250\|2.22.2" --include="*.kts" --include="*.toml" . | grep -v conflict'
    grep -rn '2\.5\.250\|2\.22\.2' --include='*.kts' --include='*.toml' . 2>/dev/null \
      | grep -v './conflict' | sed 's|^\./||'
    echo
    echo '$ grep -n "libs\." tiffinbox-*/build.gradle.kts'
    grep -n 'libs\.' tiffinbox-*/build.gradle.kts
  } > /tmp/r09c.txt
  printf '%-12s %s\n' catalog "$(md5 < /tmp/r09c.txt)"
fi

if sel conflict; then
  ( cd conflict
    {
      echo '$ mvn -B dependency:tree | grep "jackson-core:jar"'
      mvn -B -Dmaven.repo.local="$PWD/.m2-demo" dependency:tree 2>&1 | grep 'jackson-core:jar'
      # The slide used to print this as `| grep "jackson-core:2"`, which returns THREE lines here:
      # two of them show 2.22.2 with no arrow and are exactly the confusion the slide is trying to
      # prevent. The anchored grep below — the one that actually produced the capture — keeps the
      # top-level line, which is the one carrying `2.13.5 -> 2.22.2`. It is now on the slide.
      echo '$ ../gradlew dependencies --configuration runtimeClasspath | grep -E "^.--- com.fasterxml.jackson.core:jackson-core"'
      ../gradlew --console=plain -q dependencies --configuration runtimeClasspath 2>&1 \
        | grep -E '^.--- com.fasterxml.jackson.core:jackson-core'
    } > /tmp/r09d.txt )
  printf '%-12s %s\n' conflict "$(md5 < /tmp/r09d.txt)"
fi

if sel health; then
  API
  printf '%-12s %s\n' health "$(./gradlew --console=plain -q health 2>&1 | md5)"
fi
