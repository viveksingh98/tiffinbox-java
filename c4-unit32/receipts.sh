#!/bin/bash
# Unit 32's receipts: the capstone (../c4-tiffinbox) built, then asked what it is made of - once whole, and
# three more times with one of its hooks taken out. Three runs each, hashed; every row the finale says is asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
# JUL's header line is locale-dependent; the mask expects en-US, so every JVM here is pinned to it.
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
(cd ../c4-tiffinbox && mvn -q -Dmaven.repo.local="$M2" -DskipTests package) || die "the capstone did not build"
CPA="../c4-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls ../c4-tiffinbox/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$CPA" -d .harness harness/contrast/OneBeanMethod.java harness/com/tiffinbox/finale/*.java
# Drops JUL headers, the server's INFO lines (except the routes line, which the finale shows) and the
# WARNING that repeats a refused start - and COUNTS every line it drops.
quiet() { awk '/^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { ts++; next }
               /^INFO: routes mapped:/ { print; next } /^INFO: / { info++; next } /^WARNING: / { warn++; next } { print }
               END { printf "… %d JUL header line(s), %d other INFO line(s), %d WARNING line(s) elided …\n", ts, info, warn }'; }
# Three runs, hashed; a drift stops the receipts. Then compared with receipts.md5 (the README's table).
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-11s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
# findLoadedClass is not public: row 0 needs the one --add-opens below, and nothing else does.
mech() { java $JOPTS --add-opens java.base/java.lang=ALL-UNNAMED -cp ".harness:$CPA" com.tiffinbox.finale.Mechanisms 18451 2>&1 | quiet; }
cap mechanisms mech
takeout() { for m in configuration-class common-annotation autowired-annotation; do
              java $JOPTS -cp ".harness:$CPA" com.tiffinbox.finale.TakeOneOut $m 18452 2>&1 | quiet; done; }
cap takeout takeout

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x mechanisms 'found in com.tiffinbox - loaded by the JVM: 0 of 6$'
x mechanisms 'after the container built them - loaded by the JVM: 6 of 6$'
echo "  the scan found six classes without loading one (0 of 6); building them loaded all six"
x mechanisms '^   6 of yours: \[customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer\]$'
x mechanisms '^   handed in: \[tiffinBoxApp\] - found by the scan: 5$'
echo "  definitions: 6 of yours - 1 handed in, 5 found by the scan"
x mechanisms '\(BeanFactoryPostProcessor\): \[ConfigurationClassPostProcessor, EventListenerMethodProcessor\]$'
x mechanisms '\(BeanPostProcessor\): \[.*CommonAnnotationBeanPostProcessor.*AutowiredAnnotationBeanPostProcessor.*\]$'
x takeout '^without ConfigurationClassPostProcessor: the context started - yours \[tiffinBoxApp\] - sources \[systemProperties, systemEnvironment\]$'
x takeout '^without CommonAnnotationBeanPostProcessor: the context started - .* - start\(\) ran\? false - orders cooked 0$'
x takeout '^without AutowiredAnnotationBeanPostProcessor: the context refused to start - .*NoSuchMethodException: com.tiffinbox.web.TiffinBoxServer.<init>\(\)$'
echo "  each hook, taken out: no scan and no file / start() never ran / no constructor could be chosen"
x mechanisms '@Profile is itself @Conditional\(ProfileCondition\)$'
x mechanisms 'in the order they are asked: \[systemProperties, systemEnvironment, class path resource \[tiffinbox.properties\]\]$'
echo "  @Profile is a @Conditional; property sources: system properties, environment variables, then the file"
x mechanisms 'proxies among your objects: 0 - every one is the class you wrote$'
x mechanisms 'your configuration class: @Bean methods 0 - the object.s class: com.tiffinbox.web.TiffinBoxApp$'
x mechanisms "its recipe's class after the row-2 hook: contrast.OneBeanMethod[$][$]SpringCGLIB[$][$]0$"
x mechanisms 'AbstractAutoProxyCreator - a BeanPostProcessor\? true$'
echo "  proxies: 0 in the capstone; a @Bean method is what gets a configuration class subclassed; the proxy maker is a BeanPostProcessor"
x mechanisms '^INFO: routes mapped:  \[GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown\]$'
echo "  the capstone's router still finds its routes by scanning methods: 5 routes"
if [ -f ../c4-unit20/.r-switches-on.out ]; then
  grep -q 'internalAutoProxyCreator' ../c4-unit20/.r-switches-on.out && echo "  the aspect section's capture (c4-unit20) still shows the one bean @EnableAspectJAutoProxy adds" || die "c4-unit20's capture lost its line"
else echo "  (run ../c4-unit20/receipts.sh to regenerate the aspect section's capture this finale quotes)"; fi
