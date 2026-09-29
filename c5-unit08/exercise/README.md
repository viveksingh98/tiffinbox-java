# Exercise — the first meal type, from the environment

TiffinBox as this unit left it (`../after/`) binds `tiffinbox.meal-types` — `VEG`, `NON_VEG`, `VEGAN` in its
`application.yaml` — into the record's `mealTypes`. Override **only the first** meal type, to `VEGAN`, through an
environment variable: no file edited, and no flag added after the class name. Before you run anything, **predict** the
whole list the record will hold. Then check the record's line.

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/`, compiles
the harness, and writes the class path it uses to `.harness/after.classpath`. Then, from that same folder:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
AFTER="$(cat .harness/after.classpath)"
java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689 2>&1 | grep '^the record'
```

`Props` runs TiffinBox's own `main`, prints the record the binder built, and closes the context, which stops TiffinBox's
server — nothing is left listening on 18689, this exercise's port. As shipped, with no variable of yours set, it prints
(measured 2026-09-30, JDK 25.0.4.1, Spring Boot 4.1.1):

```
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18689, mealTypes=[VEG, NON_VEG, VEGAN]]
```

Set the variable on the same line as the command, in front of `java`, so it reaches that one run and nothing else.

**Done** means the record's line shows `VEGAN` as the first meal type, and your prediction of the whole list was right
— or you can say why it was not. The spelling rules for environment variables are the ones the previous unit measured
(its `relaxed` capture); a list item's index is part of its key.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
