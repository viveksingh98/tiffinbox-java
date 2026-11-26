#!/bin/sh
# Course 9 unit 15's exercise servers: builds, under ../.harness/servers/ (ignored by the repository's c9-unit*/.harness/ rule, never tracked), the harness's copy of ../before (the same ONE
# pom line as the receipts' starter capture: spring-boot-starter-hateoas, managed) and the harness's classes twice - build A with the
# member route at /probe/people, build B with it moved to /probe/members (one edited string constant). Offline from MAVEN_REPO when set.
# Usage: sh build.sh
HERE=$(cd "$(dirname "$0")" && pwd -P); S="$HERE/../.harness/servers"
rm -rf "$S"; mkdir -p "$S/A" "$S/B" "$S/srcB"
rsync -a --exclude target --exclude secrets --exclude .m2-demo "$HERE/../before/" "$S/copy/" || exit 1
python3 -I - "$S/copy/tiffinbox-web/pom.xml" <<'PY' || exit 1
import sys
p = sys.argv[1]; t = open(p, encoding="utf-8").read()
anchor = "      <artifactId>spring-boot-starter-webmvc</artifactId>\n    </dependency>\n"
if t.count(anchor) != 1: sys.exit("build.sh: the pom's webmvc dependency was not found once")
add = ("    <!-- THE HARNESS'S COPY (Course 9 unit 15): Spring HATEOAS, managed by Boot 4.1.3 - this copy only, never before or c9-tiffinbox -->\n"
       "    <dependency>\n      <groupId>org.springframework.boot</groupId>\n      <artifactId>spring-boot-starter-hateoas</artifactId>\n    </dependency>\n")
open(p, "w", encoding="utf-8").write(t.replace(anchor, anchor + add))
PY
(cd "$S/copy" && mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package > "$S/build.log" 2>&1) || { echo "build.sh: the copy did not build ($S/build.log)"; exit 1; }
X="$S/copy/tiffinbox-web/target/extracted"
(cd "$S/copy" && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null) || exit 1
cp -R "$HERE/../harness/src/probe" "$S/srcB/"
python3 -I - "$S/srcB/probe/u15/U15Moved.java" <<'PY' || exit 1
import sys
p = sys.argv[1]; t = open(p, encoding="utf-8").read()
a = 'static final String ROUTE = "/probe/people/{name}";'
if t.count(a) != 1: sys.exit("build.sh: the route's constant was not found once")
open(p, "w", encoding="utf-8").write(t.replace(a, 'static final String ROUTE = "/probe/members/{name}";'))
PY
javac -nowarn -parameters -d "$S/A" -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" "$HERE"/../harness/src/probe/u15/*.java || exit 1
javac -nowarn -parameters -d "$S/B" -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" "$S"/srcB/probe/u15/*.java || exit 1
echo "built: the harness's copy (mvn -o -DskipTests clean package, exit 0) · server A (the member route at /probe/people) · server B (moved to /probe/members)"
