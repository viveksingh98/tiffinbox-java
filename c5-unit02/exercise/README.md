# Exercise — whose H2?

`../../c5-tiffinbox/pom.xml` sets `<h2.version>2.5.250</h2.version>` and, in its own `<dependencyManagement>`, gives H2
the version `${h2.version}`. Boot's parent manages H2 too.

**Delete one line — the `<h2.version>` property — and nothing else.** Before you build, predict: does the build fail on an
undefined `${h2.version}`, or does it pick a version? Then:

```
rsync -a --exclude target ../../c5-tiffinbox/ my-tiffinbox/
# delete the <h2.version> line from my-tiffinbox/pom.xml
(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests clean package)
ls my-tiffinbox/tiffinbox-web/target/lib | grep h2
java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18433 &
../../c4-unit31/curlset.sh 18433 | grep ' -> ' | md5 -q
```

Done means: you can name the H2 version you got, say where it came from, and say whether the seven answers changed.
Solution in `solution/`.
