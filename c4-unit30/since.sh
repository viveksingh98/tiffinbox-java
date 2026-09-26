#!/bin/sh
# Since when? Count the entries under org/springframework/resilience/ in the last 6.2 jar and in this course's 7.0.9.
set -e
cd "$(dirname "$0")"
for v in 6.2.12 7.0.9; do
  mvn -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:get -Dartifact="org.springframework:spring-context:$v" -Dtransitive=false
  n=$(unzip -l ".m2-demo/org/springframework/spring-context/$v/spring-context-$v.jar" | grep -c 'org/springframework/resilience/' || true)
  echo "  spring-context $v: $n entries under org/springframework/resilience/"
done
