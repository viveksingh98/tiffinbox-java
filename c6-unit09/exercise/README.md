# Exercise — snake-case keys, and the word Jackson knows

**Your turn:** the README's run should write snake-case keys but never starts. Read the last cause, fix the value, name the changed keys.

Since this lesson Boot's JSON mapper — `jacksonJsonMapper`, the object Spring MVC reads and writes TiffinBox's JSON with — is set by
`spring.jackson.*` keys, and one of them names how a Java property becomes a JSON key: `spring.jackson.property-naming-strategy`.
Its value is handed to Jackson as the name of one of the constants of Jackson's `PropertyNamingStrategies` class, word for word
(Boot's own description of the key, in its metadata). With the right word, `mealsPerDay` is written `meals_per_day` — snake case:
lower-case words joined by underscores. With a word Jackson has no constant for, the mapper is never built, and TiffinBox never
starts: no failure analysis from Boot, only a stack trace, whose last cause names the word it was given.

Run everything from `c6-unit09/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable
by you alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit09/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19389` with a naming strategy given as an option, waits until readiness answers 200 or the JVM has stopped, asks for
one customer, Ravi (the answer saved to `../ravi.json`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read
from the copy's own file — if nothing listens, it is answered by nobody), waits for that JVM to exit (`wait $!`, its exit code), and
prints the exit code, the log's last `Caused by:` line (`none` when it has none) and the keys of Ravi's answer (`none` when there
was no answer). The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the
script checks both before its first build; without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this
exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/after && rm -f ../ravi.json && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19389 --spring.jackson.property-naming-strategy=snake_case > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19389/actuator/health/readiness)" = 200 ] && break; kill -0 $! 2> /dev/null || break; sleep 0.25; done; curl -s -o ../ravi.json http://127.0.0.1:19389/customers/Ravi; ../../../harness/shutdown.sh 19389 secrets/tiffinbox/shutdown-token > /dev/null; wait $!; e=$?; k=$(grep -o '"[A-Za-z_]*":' ../ravi.json 2> /dev/null | tr -d '":' | paste -sd' ' -); c=$(grep '^Caused by: ' ../run.log | tail -1 | sed 's/^Caused by: //'); echo "exit $e · its last cause: ${c:-none} · Ravi's keys: ${k:-none}")
```

As shipped, it prints `exit 1 · its last cause: java.lang.IllegalStateException: Constant named 'snake_case' not found · Ravi's keys: none`:
the word reached Jackson exactly as typed, Jackson has no constant of that name, so Boot could not build its mapper, Spring MVC
could not build its JSON converter, and the start failed — nothing ever listened on 19389. The log holds the whole chain of causes
(`.harness/mine/run.log`); the last one names the word. Fix the value in the last line — the constant's name, as Jackson spells it
— and run that line again from the same shell.

**Done** when you can print

```
exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type
```

— and name the three keys that changed, against TiffinBox's own (`{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}`):
`mealsPerDay`, `pricePerMeal` and `mealType`; `name`, one word already, stays. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
