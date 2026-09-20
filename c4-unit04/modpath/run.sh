#!/bin/sh
# c4-unit04/modpath/run.sh — the same component scan, inside a NAMED MODULE.
#
# This is the probe behind the module slide of this unit. It compiles five sources into the module
# `tiffinbox.scan`, then runs it three times and compares the three captures, because one run is
# not a receipt.
#
# WHAT src/module-info.java CARRIES, AND WHAT IT DELIBERATELY DOES NOT
#   It carries `exports`. It carries no `opens`, and that absence is half the lesson:
#   scanning needs `exports`, generating a CGLIB subclass needs `opens`. The scan below succeeds
#   with `exports` alone. `ModConfig` declares no @Bean methods, so the container never enhances
#   it and never reflects into this package — which is exactly why no `opens` line is needed here.
#   Adding one would make the other half of the slide false, so it is not added.
#   The failing half (a @Configuration class WITH @Bean methods, in a module that exports and does
#   not open) is a separate probe and is NOT in this folder — the slide says so on its panel head.
#
# THE JARS GO ON THE MODULE PATH, NOT THE CLASS PATH
#   Spring Framework 7 ships automatic modules, which is the only reason `requires spring.context`
#   resolves at all. One `$CP` serves as both, which is why the java line reads "out:$CP".
#
# Verified on JDK 25.0.4.1, Spring Framework 7.0.9, macOS 27.0, 8-core / 16 GB Apple silicon.
set -u

cd "$(dirname "$0")" || exit 2

if [ -z "${JAVA_HOME:-}" ]; then
  echo "run.sh: JAVA_HOME is not set, and this probe is pinned to JDK 25. Run:" >&2
  echo '  export JAVA_HOME=/opt/homebrew/opt/openjdk@25' >&2
  echo '  export PATH="$JAVA_HOME/bin:$PATH"' >&2
  echo "  (a bare java on the machine this was measured on is 23.0.1 — it cannot load these classes)" >&2
  exit 2
fi

if [ ! -f ../.cp ]; then
  echo "run.sh: ../.cp is missing. It is the resolved runtime classpath, and it is machine-local" >&2
  echo "by construction, so it is not in the clone. Write it with the two lines from ../README.md," >&2
  echo "run in c4-unit04/ :" >&2
  echo '  mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package' >&2
  echo '  mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime' >&2
  exit 2
fi

CP="$(cat ../.cp)"

# `.cp` is a file full of absolute paths into a local repository that this project's own teardown
# deletes, so a present `.cp` is not the same thing as a resolved one. Check, and say which.
FIRST_JAR="${CP%%:*}"
if [ ! -f "$FIRST_JAR" ]; then
  echo "run.sh: ../.cp exists, but the first jar it names is not on this disk:" >&2
  echo "  $FIRST_JAR" >&2
  echo "That file is machine-local by construction. Re-write it from c4-unit04/ :" >&2
  echo '  mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime' >&2
  exit 2
fi

JAVAC="$JAVA_HOME/bin/javac"
JAVA="$JAVA_HOME/bin/java"

hash_of() {
  if command -v md5 >/dev/null 2>&1; then md5 -q "$1"; else md5sum "$1" | cut -d' ' -f1; fi
}

# src/ holds no spaces, so the unquoted expansion below is safe; "$CP" is quoted because this
# tree's own absolute path does contain one.
SOURCES=$(find src -name '*.java' | sort)
echo "$("$JAVA" -version 2>&1 | head -1)"
echo "javac --module-path \"\$CP\" -d out   ($(printf '%s\n' "$SOURCES" | wc -l | tr -d ' ') sources, module tiffinbox.scan)"

rm -rf out
# shellcheck disable=SC2086
"$JAVAC" --module-path "$CP" -d out $SOURCES || { echo "run.sh: javac failed" >&2; exit 1; }

i=1
while [ "$i" -le 3 ]; do
  "$JAVA" --module-path "out:$CP" -m tiffinbox.scan/com.tiffinbox.scan.ModConfig > ".r-mod$i.out" 2>&1
  echo "$?" > ".r-mod$i.exit"
  echo "run $i  exit $(cat ".r-mod$i.exit")  md5 $(hash_of ".r-mod$i.out")  $(wc -l < ".r-mod$i.out" | tr -d ' ') output lines"
  i=$((i + 1))
done

# A hash nobody compared is not evidence, so compare, and die rather than print a confident line.
rc=0
cmp -s .r-mod1.out .r-mod2.out && cmp -s .r-mod2.out .r-mod3.out || { echo "3 of 3 byte-identical: NO"; rc=1; }
[ "$(cat .r-mod1.exit)$(cat .r-mod2.exit)$(cat .r-mod3.exit)" = "000" ] || { echo "all three exit 0: NO"; rc=1; }
if [ "$rc" -eq 0 ]; then
  echo "3 of 3 byte-identical: yes, all exit 0"
  echo "run from: $(pwd)"
  echo "--- .r-mod1.out, complete ---"
  cat .r-mod1.out
else
  echo "run from: $(pwd)"
  echo "The probe did not reproduce. The three captures and their exit codes are in .r-mod*.out/.exit." >&2
fi
exit "$rc"
