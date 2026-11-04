# Solution — Columns, Enums and Converters

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes .harness/ex/reordered && sed 's/EnumType.ORDINAL/EnumType.STRING/' harness/src/probe/map/ex/ExCustomer.java > .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
sed 's/{ VEG, NON_VEG, VEGAN }/{ NON_VEG, VEG, VEGAN }/' harness/src/probe/map/enums/MealType.java > .harness/ex/MealType.java && javac -d .harness/ex/reordered .harness/ex/MealType.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN -Dh2file=../ex/db/ex)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main write ex.ExCustomer) > .harness/mine.log 2>&1; echo "build 1: exit $?"
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/reordered:../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main read - ex.ExCustomer) >> .harness/mine.log 2>&1; echo "build 2: exit $?"
rm -rf .harness/ex/db
grep -E '^PROBE (MealType|ex_customer)' .harness/mine.log
```

One line differs from the README's: the copy of `ExCustomer.java` gets `EnumType.STRING` in its `@Enumerated` (by hand, open
`.harness/ex/ExCustomer.java` and change that one word). What it prints (measured, `../receipts.sh`, capture `exercise`, in the same
shell, after the README's lines, in bash and in zsh):

```
build 1: exit 0
build 2: exit 0
PROBE MealType in this build: [VEG, NON_VEG, VEGAN] - ordinals [0, 1, 2]
PROBE ex_customer raw, read by a second connection: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]
PROBE MealType in this build: [NON_VEG, VEG, VEGAN] - ordinals [0, 1, 2]
PROBE ex_customer raw, read by a second connection: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]
PROBE ex_customer read by Hibernate: [Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]
```

By name, build 1 writes the words `VEG`, `NON_VEG`, `VEGAN` into the column (on H2 a column of H2's own `enum` type — `enumddl` shows that DDL for the same mapping); build 2 reads each word back
as the constant of that name, wherever it now stands in the enum — Ravi is `VEG`. The reorder in build 2 is the same; only what the
column stores changed.
