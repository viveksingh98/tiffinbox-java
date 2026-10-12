# two.py DIR: turns DIR - a copy of the previous tree, TiffinBox on its own server - into the two-server copy Course 6's first
# lessons measure: Spring MVC's starter added to tiffinbox-web/pom.xml, and the Boot plugin's two Jackson 3 excludes removed
# (the Compose module's stays). Nothing else: no alias in application.yaml, so Tomcat gets Boot's defaults - every interface,
# and the port only a --server.port= gives it. The course's harness, never TiffinBox's.
import sys
p = sys.argv[1] + "/tiffinbox-web/pom.xml"; s = open(p).read()
dep = """    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-webmvc</artifactId>
    </dependency>
  </dependencies>"""
assert s.count("  </dependencies>") == 1 and "spring-boot-starter-webmvc" not in s
s = s.replace("  </dependencies>", dep)
for a in ("jackson-databind", "jackson-core"):
    x = """            <exclude>
              <groupId>tools.jackson.core</groupId>
              <artifactId>%s</artifactId>
            </exclude>
""" % a
    assert s.count(x) == 1, a
    s = s.replace(x, "")
open(p, "w").write(s)
