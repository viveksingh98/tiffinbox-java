# Exercise — a converter, and the sources that make it a bean

**Your turn:** the README's run answers veg with a four hundred. Add the harness converter to its sources, ask again, and count the customers.

TiffinBox's `GET /customers` takes its meal type as a request parameter, a `MealType`, and Spring MVC's data binder turns the text
into one with Spring's own converter for an enum: by the constant's exact name. `?mealType=VEG` lists Ravi and Sunil; `?mealType=veg`
is a 400. The course's harness has a converter of its own, `probe.web.MealTypeConverter` (`harness/probe/web/MealTypeConverter.java`,
outside TiffinBox's code): a `Converter<String, MealType>` that ignores case. A class on the class path is not yet a bean — TiffinBox's
own scan reads `com.tiffinbox` alone — and Boot adds to Spring MVC's conversion service only the converters that are beans. One option
makes a class a bean: `--spring.main.sources`, a list of classes the application is built from, beside its own.

Run everything from `c6-unit13/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the validation lesson froze —
to `.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you
alone, never printed — build the jar offline against this unit's `.m2-demo` and extract it (the class-path layout: TiffinBox's jar,
and every jar it needs in `lib/`), then compile the harness's converter against it (`javac -parameters`). Its last line runs in a
subshell (the parentheses), so your shell stays in `c6-unit13/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19429`, the converter's class on its class path (`../hc`), waits until readiness answers 200, asks for the customers whose
meal type is `veg` (the answer saved to `../got.json`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read
from the copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed — another JDK's `java`, say — ends the line with
its own exit code, never with a count), and prints the status, how many customers the answer lists, and their names (`none` when it
lists none). The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no
GraalVM and no Docker are needed: its first build fills `.m2-demo`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
javac -parameters -d .harness/mine/hc -cp ".harness/mine/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/MealTypeConverter.java
(cd .harness/mine/anchor && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19429 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19429/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19429/customers?mealType=veg'); ../../../harness/shutdown.sh 19429 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"name":"[^"]*"' ../got.json | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && echo "GET /customers?mealType=veg: $s · customers: $n · names: ${f:-none}")
```

As shipped, it prints `GET /customers?mealType=veg: 400 · customers: 0 · names: none`: the converter's class is on the class path, but
nothing made it a bean, so Spring MVC's conversion service never heard of it and Spring's own converter asked for `VEG`. Give the last
line's run the one option that adds the converter's class to the application's sources, and run it again from the same shell.

**Done** when you can print

```
GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil
```

— the two vegetarian customers, found by a word TiffinBox's own rule refused: the converter, a bean now, turned `veg` into `VEG`
before TiffinBox's method ran. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly
as written: `solution/SOLUTION.md`.
