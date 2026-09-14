#!/bin/bash
# Reactor selectors, proved by the Reactor Summary — not by BUILD SUCCESS.
# Run from c3-unit02/ .  The quotes around -Dmaven.repo.local are NOT optional.
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
for sel in "" "-pl tiffinbox-core" "-pl tiffinbox-kitchen" "-pl tiffinbox-kitchen -am" \
           "-pl tiffinbox-core -amd" "-pl tiffinbox-web -amd"; do
  out=$(mvn -B clean package $sel -Dmaven.repo.local="$PWD/.m2-demo" 2>&1); rc=$?
  n=$(printf '%s\n' "$out" | sed -n '/Reactor Summary/,/^\[INFO\] ---/p' | grep -cE 'SUCCESS \[|FAILURE \[|SKIPPED')
  printf '%-28s  modules=%s  exit=%s  %s\n' "${sel:-<no selector>}" "$n" "$rc" \
         "$(printf '%s\n' "$out" | grep -oE 'BUILD (SUCCESS|FAILURE)' | tail -1)"
done
