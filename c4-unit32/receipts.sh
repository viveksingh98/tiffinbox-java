#!/bin/bash
# Unit 32's receipts: the capstone (../c4-tiffinbox) built, started once by the harness, and asked what it is
# made of. Three runs, hashed; every row the finale names is asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
die() { echo "  *** $* ***"; exit 1; }
(cd ../c4-tiffinbox && mvn -q -Dmaven.repo.local="$M2" -DskipTests package) || die "the capstone did not build"
CPA="../c4-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls ../c4-tiffinbox/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$CPA" -d .harness harness/com/tiffinbox/finale/Mechanisms.java
# Drops JUL headers and the server's own INFO lines - and counts them.
quiet() { awk '/^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { ts++; next } /^INFO: / { info++; next } { print }
               END { printf "… %d JUL header line(s), %d INFO line(s) elided …\n", ts, info }'; }
for i in 1 2 3; do java -cp ".harness:$CPA" com.tiffinbox.finale.Mechanisms 18451 2>&1 | quiet > ".r-mechanisms.$i"; done
h=$(md5 -q .r-mechanisms.1); [ "$h" = "$(md5 -q .r-mechanisms.2)" ] && [ "$h" = "$(md5 -q .r-mechanisms.3)" ] || die "mechanisms drifts"
mv .r-mechanisms.1 .r-mechanisms.out; rm -f .r-mechanisms.2 .r-mechanisms.3
printf '  mechanisms  md5 %s  3/3\n\n' "$h"
M=.r-mechanisms.out
grep -qE '^   [0-9]+ of yours: \[' $M && echo "  definitions: $(grep -oE '^   [0-9]+ of yours' $M | sed 's/^ *//')" || die "no definitions row"
grep -q 'BeanFactoryPostProcessor): \[.*ConfigurationClassPostProcessor' $M && echo "  a hook BEFORE any object: ConfigurationClassPostProcessor (reads @Configuration, @ComponentScan, @PropertySource)" || die "no BFPP row"
grep -q 'CommonAnnotationBeanPostProcessor' $M && grep -q 'AutowiredAnnotationBeanPostProcessor' $M && echo "  hooks AROUND every object include @PostConstruct's and @Value/injection's processors" || die "no BPP row"
grep -q '@Conditional(ProfileCondition)' $M && echo "  @Profile is a @Conditional" || die "no condition row"
grep -q 'property sources, in the order they are asked: \[systemProperties, systemEnvironment, class path resource \[tiffinbox.properties\]\]' $M && echo "  property sources: system properties, environment, then the file" || die "no sources row"
grep -q 'proxies among your objects: 0 - every one is the class you wrote' $M && echo "  proxies in the capstone: 0" || die "the proxy row changed"
