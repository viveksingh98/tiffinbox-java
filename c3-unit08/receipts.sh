#!/bin/zsh
# receipts.sh [id]  — re-runs the exact pipelines this unit's README quotes and prints their md5.
# Every hash in README.md comes from here and from nothing else. Each block resets its own state
# first, so any of them can be run on its own, in any order.
#
#   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
#   export PATH="$JAVA_HOME/bin:$PATH"
#   ./receipts.sh
set -u
cd "${0:A:h}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PWD/.gradle-home}"
M=src/main/menu/menu.txt
RESET() { printf 'Grilled Chicken|NON_VEG\nSteamed Rice|VEG\nGarden Salad|VEGAN\n' > $M }
want="${1:-all}"
sel() { [[ "$want" == "all" || "$want" == "$1" ]] }
H() { md5 }

# THREE is the grep every `./gradlew build` panel in this unit is filtered by, and it is now
# printed on every one of those panel heads. It keeps the three tasks the unit is about.
THREE='^> Task :(generateMenu|compileJava|jar)'

# B — run one build; print the three task lines the panel shows, the `actionable` summary, and a
# COUNTED elision for the `> Task` lines the grep dropped.
#
# The count is measured from the same run that produced the three lines above it: it is
# (all `> Task` lines) minus (the ones kept). It was a chip reading "nothing elided" over a
# capture where nine of twelve task lines had been cut by a grep that appeared on no slide.
# A number a script prints unconditionally is not a count. This one changes when the build does.
B() { local full=$(./gradlew --console=plain build 2>&1)
      local all=$(print -r -- "$full" | grep -cE '^> Task ')
      local kept=$(print -r -- "$full" | grep -cE "$THREE")
      print -r -- "$full" | grep -E "$THREE|actionable"
      printf '     ... %d of %d task lines elided by the grep above ...\n' "$(( all - kept ))" "$all" }

if sel three-states; then
  RESET; rm -rf "$GRADLE_USER_HOME/caches/build-cache-1"
  ./gradlew --console=plain -q clean >/dev/null 2>&1
  {
    echo '$ ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"   # nothing built yet'
    B
    echo '$ ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"   # straight away, again'
    B
    echo '$ ./gradlew clean && ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"   # outputs deleted, inputs unchanged'
    ./gradlew --console=plain -q clean >/dev/null 2>&1
    B
  } > /tmp/r08a.txt
  printf '%-16s %s\n' three-states "$(H < /tmp/r08a.txt)"
fi

if sel caching-why; then
  RESET
  ./gradlew --console=plain -q clean >/dev/null 2>&1
  printf '%-16s %s\n' caching-why \
    "$(./gradlew --console=plain build --info 2>&1 | grep -A1 -E '^Caching disabled for task' | grep -v '^--$' | H)"
fi

if sel skip-reasons; then
  RESET
  ./gradlew --console=plain --no-build-cache -q clean >/dev/null 2>&1
  ./gradlew --console=plain --no-build-cache -q build >/dev/null 2>&1
  printf '%-16s %s\n' skip-reasons \
    "$(./gradlew --console=plain --no-build-cache build --info 2>&1 | grep -E '^Skipping task' | H)"
fi

if sel change-reasons; then
  RESET
  ./gradlew --console=plain --no-build-cache -q clean >/dev/null 2>&1
  ./gradlew --console=plain --no-build-cache -q build >/dev/null 2>&1
  printf 'Lentil Soup|VEGAN\n' >> $M
  printf '%-16s %s\n' change-reasons \
    "$(./gradlew --console=plain --no-build-cache build --info 2>&1 \
       | grep -E 'is not up-to-date because:|  Input property' | sed -E "s|file .*c3-unit08/|file |" | H)"
  RESET
fi

if sel break; then
  ( cd breaks/undeclared-input
    B=src/main/menu/menu.txt
    printf 'Grilled Chicken|NON_VEG\nSteamed Rice|VEG\nGarden Salad|VEGAN\n' > $B
    ../../gradlew --console=plain -q clean >/dev/null 2>&1
    # same counted-elision rule as the main tree's B(), against ../../gradlew
    BB() { local full=$(../../gradlew --console=plain build 2>&1)
           local all=$(print -r -- "$full" | grep -cE '^> Task ')
           local kept=$(print -r -- "$full" | grep -cE "$THREE")
           print -r -- "$full" | grep -E "$THREE|actionable"
           printf '     ... %d of %d task lines elided by the grep above ...\n' "$(( all - kept ))" "$all" }
    {
      echo '$ ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
      BB
      echo '$ java -cp build/classes/java/main com.tiffinbox.MenuCatalog'
      java -cp build/classes/java/main com.tiffinbox.MenuCatalog
      echo '$ echo "Lentil Soup|VEGAN" >> src/main/menu/menu.txt ; wc -l < src/main/menu/menu.txt'
      printf 'Lentil Soup|VEGAN\n' >> $B
      wc -l < $B
      echo '$ ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"'
      BB
      echo '$ java -cp build/classes/java/main com.tiffinbox.MenuCatalog'
      java -cp build/classes/java/main com.tiffinbox.MenuCatalog
    } > /tmp/r08b.txt
    printf 'Grilled Chicken|NON_VEG\nSteamed Rice|VEG\nGarden Salad|VEGAN\n' > $B )
  printf '%-16s %s\n' break "$(H < /tmp/r08b.txt)"
fi

if sel fixed; then
  RESET
  ./gradlew --console=plain --no-build-cache -q clean >/dev/null 2>&1
  ./gradlew --console=plain --no-build-cache -q build >/dev/null 2>&1
  printf 'Lentil Soup|VEGAN\n' >> $M
  # --no-build-cache variant of B(), same counted elision
  BN() { local full=$(./gradlew --console=plain --no-build-cache build 2>&1)
         local all=$(print -r -- "$full" | grep -cE '^> Task ')
         local kept=$(print -r -- "$full" | grep -cE "$THREE")
         print -r -- "$full" | grep -E "$THREE|actionable"
         printf '     ... %d of %d task lines elided by the grep above ...\n' "$(( all - kept ))" "$all" }
  {
    echo '$ ./gradlew build | grep -E "^> Task :(generateMenu|compileJava|jar)|actionable"    # the same edit, on the task that declares its input'
    BN
    echo '$ java -cp build/classes/java/main com.tiffinbox.MenuCatalog'
    java -cp build/classes/java/main com.tiffinbox.MenuCatalog
  } > /tmp/r08c.txt
  RESET
  ./gradlew --console=plain --no-build-cache -q build >/dev/null 2>&1
  printf '%-16s %s\n' fixed "$(H < /tmp/r08c.txt)"
fi
