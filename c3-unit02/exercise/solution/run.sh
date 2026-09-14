#!/bin/bash
# The flag is -am : "also make" the modules this one depends on.
# Run from c3-unit02/exercise/solution/ ; it steps up to the reactor root itself.
set -e
# JAVA_HOME: **yours** if you already exported one, the pinned Homebrew path only if
# you did not. Either way it has to be a JDK 25 -- this reactor compiles `--release 25`
# and its class files are version 69 -- and if it is not, say so instead of building
# against a path that happens not to exist on your machine.
JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@25}"
if [ ! -x "$JAVA_HOME/bin/java" ]; then
  echo "run.sh: JAVA_HOME does not name a JDK: $JAVA_HOME" >&2
  echo "  export JAVA_HOME=/path/to/a/jdk-25   (on the author's Mac: /opt/homebrew/opt/openjdk@25)" >&2
  exit 2
fi
JV="$("$JAVA_HOME/bin/java" -version 2>&1 | head -1)"
JMAJOR="$(printf '%s' "$JV" | sed -n 's/.*"\([0-9][0-9]*\).*/\1/p')"
if [ "${JMAJOR:-0}" != "25" ]; then
  echo "run.sh needs JDK 25, and JAVA_HOME gives: $JV" >&2
  echo "  export JAVA_HOME=/path/to/a/jdk-25   (on the author's Mac: /opt/homebrew/opt/openjdk@25)" >&2
  exit 2
fi
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
cd "$(dirname "$0")/../.."
mvn -B clean package -pl tiffinbox-kitchen -am -Dmaven.repo.local="$PWD/.m2-demo"
