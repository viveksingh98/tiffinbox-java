#!/bin/zsh
# receipts.sh [id]  — re-runs the exact pipelines this unit's README quotes and prints their md5.
# With no argument it runs all of them. Every hash in README.md comes from here and from nothing else.
#
#   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
#   export PATH="$JAVA_HOME/bin:$PATH"
#   ./receipts.sh
#
# Each pipeline is run once here; the hashes in the README were taken over three runs each.
#
# TWO RULES THIS FILE OBEYS, AND THEY ARE THE POINT:
#   1. A block that needs an artifact BUILDS it first, or fails loudly. It never hashes an
#      error message. `jar-entries` compares two jars; on a clean clone neither exists, and a
#      bare `diff` of two missing files prints `cannot find or open` and still returns a
#      perfectly confident md5. A receipt that cannot fail is not a receipt.
#   2. A block that pins a cache state RESETS that state itself, so its hash is the same on the
#      viewer's first run as on the author's fourth. `gradle-jar` deletes build/ first, because
#      `clean` prints `UP-TO-DATE` when there is nothing to clean — which is exactly what a
#      first-time viewer sees, and what the slide therefore shows.
set -u
cd "${0:A:h}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PWD/.gradle-home}"
want="${1:-all}"

# The one duration regex for the whole section. Gradle prints `in 493ms`, `in 12s`, `in 1.5s`,
# `in 1m 2s` and `in 1h 2m 3s`; a first build on a cold dependency cache routinely reaches the
# minute forms, and a regex that only catches the first two lets a duration into a hashed capture.
DUR='s/ in ([0-9]+h )?([0-9]+m )?[0-9]+(\.[0-9]+)?(ms|s)$//'

run() { [[ "$want" == "all" || "$want" == "$1" ]] || return 0
        printf '%-18s %s\n' "$1" "$(eval "$2" 2>&1 | md5)" }

# need_jars — both build trees must exist before anything may compare them.
# Online on a cold cache (contract §1a tier 1: resolution only); silent and instant once warm.
need_jars() {
  [[ -f target/tiffinbox-core-1.0.0.jar ]] || \
    mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q clean package >/dev/null 2>&1 || \
    { echo "jar-entries  FAILED - mvn package could not build target/; not hashing an error" >&2; return 1 }
  [[ -f build/libs/tiffinbox-core-1.0.0.jar ]] || \
    ./gradlew --console=plain -q jar >/dev/null 2>&1 || \
    { echo "jar-entries  FAILED - ./gradlew jar could not build build/libs/; not hashing an error" >&2; return 1 }
  [[ -f target/tiffinbox-core-1.0.0.jar && -f build/libs/tiffinbox-core-1.0.0.jar ]]
}

run maven-goals   'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package | grep -E "^.INFO. --- "'
# rm -rf build first: this is the viewer's FIRST `clean jar`, so `clean` has nothing to delete and
# says UP-TO-DATE. Deterministic 3/3 either way; without the reset the hash changes after run one.
run gradle-jar    'rm -rf build; ./gradlew --console=plain clean jar | grep -E "^> Task|^BUILD|actionable" | sed -E "$DUR"'
run dryrun-jar    './gradlew --console=plain -m jar | grep "^:"'
run dryrun-build  './gradlew --console=plain -m build | grep "^:"'
run bad-task      './gradlew --console=plain jarr 2>&1 | sed -n "/What went wrong/,/^> Run gradlew/p"'
run gradle-ver    './gradlew --version | grep -E "^Gradle|^Launcher JVM|^Daemon JVM|^OS"'
run wrapper-props 'grep -E "distributionUrl|distributionSha256Sum" gradle/wrapper/gradle-wrapper.properties'
run jar-entries   'need_jars && diff <(unzip -Z1 target/tiffinbox-core-1.0.0.jar | sort) <(unzip -Z1 build/libs/tiffinbox-core-1.0.0.jar | sort)'
run task-count    './gradlew --console=plain -q tasks | grep -cE "^[a-zA-Z]+ - "'
run java-versions '( unset JAVA_HOME; PATH=/usr/bin:/bin java -version 2>&1 | head -1 ); java -version 2>&1 | head -1'
# The slide-6 "honest limit" panel. It used to be on a slide with no block behind it at all, and
# five of the capture's twenty-one lines were printed adjacent when they are not adjacent. The
# grep below is the one printed on the panel head, so the panel is the output of a pipeline the
# viewer can run, not a hand-assembled excerpt.
run no-jdk        '( unset JAVA_HOME; PATH=/usr/bin:/bin ./gradlew --console=plain clean jar 2>&1 ) | grep -E "^> Task|^> Java|^    error:|^BUILD" | sed -E "$DUR"'
