# Exercise — Columns, Enums and Converters

**Your turn:** the README's enum was reordered and Ravi became non-veg. Change how the column stores it so he stays vegetarian.

Run it from this unit's folder (`c7-unit07/`) after `./receipts.sh` has run once: it builds `.harness/after` (after/, copied, its
jar extracted) and `.harness/hc` (the mapping harness, compiled). The block copies the exercise's entity,
`harness/src/probe/map/ex/ExCustomer.java` (`@Enumerated(EnumType.ORDINAL)`), to `.harness/ex/` and compiles it there; it compiles a
second `MealType` from the harness's own with its constants reordered (`NON_VEG` first) into `.harness/ex/reordered`. Build 1 — the
harness as compiled — writes Ravi=VEG, Meera=NON_VEG and Priya=VEGAN into an H2 database in a file, `.harness/ex/db/ex.mv.db`; build 2
is the same harness with the reordered `MealType` ahead of it on the class path, in a JVM of its own, and reads them back. Then the
file goes. The JVMs' flags travel as an array, `V`, so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes .harness/ex/reordered && cp harness/src/probe/map/ex/ExCustomer.java .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
sed 's/{ VEG, NON_VEG, VEGAN }/{ NON_VEG, VEG, VEGAN }/' harness/src/probe/map/enums/MealType.java > .harness/ex/MealType.java && javac -d .harness/ex/reordered .harness/ex/MealType.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN -Dh2file=../ex/db/ex)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main write ex.ExCustomer) > .harness/mine.log 2>&1; echo "build 1: exit $?"
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/reordered:../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main read - ex.ExCustomer) >> .harness/mine.log 2>&1; echo "build 2: exit $?"
rm -rf .harness/ex/db
grep -E '^PROBE (MealType|ex_customer)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
build 1: exit 0
build 2: exit 0
PROBE MealType in this build: [VEG, NON_VEG, VEGAN] - ordinals [0, 1, 2]
PROBE ex_customer raw, read by a second connection: [Ravi=0, Meera=1, Priya=2]
PROBE MealType in this build: [NON_VEG, VEG, VEGAN] - ordinals [0, 1, 2]
PROBE ex_customer raw, read by a second connection: [Ravi=0, Meera=1, Priya=2]
PROBE ex_customer read by Hibernate: [Ravi=NON_VEG, Meera=VEG, Priya=VEGAN]
```

Build 1 stored positions — Ravi's row holds `0`. Build 2's `MealType` starts with `NON_VEG`, so position 0 is `NON_VEG` now: Ravi,
who ordered vegetarian, reads back as `NON_VEG`, Meera as `VEG`. The rows never changed (the raw column, read by a second connection,
is `0, 1, 2` both times), and no line says anything went wrong.

**Done** when build 2 reads `Ravi=VEG` — the enum still reordered, Ravi's row still the one build 1 wrote. The solution, and what it
prints, is in `SOLUTION.md`.
