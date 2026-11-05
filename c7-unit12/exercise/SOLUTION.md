# Solution — Inheritance: Three Strategies

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/PlatterMeal.java harness/src/probe/map/ex/SaladMeal.java .harness/ex/ && sed 's/@GeneratedValue(strategy = GenerationType.IDENTITY)/@GeneratedValue(strategy = GenerationType.SEQUENCE)/' harness/src/probe/map/ex/Meal.java > .harness/ex/Meal.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Meal.java .harness/ex/PlatterMeal.java .harness/ex/SaladMeal.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex probe.map.ex) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|the EntityManagerFactory was built|platter_meal|salad_meal)' .harness/mine.log
```

One line differs from the README's: the copy of `Meal.java` takes its id from a sequence (by hand, open `.harness/ex/Meal.java`
and change the id's annotation):

```java
    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE) private Long id;
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE the EntityManagerFactory was built
PROBE platter_meal (id | title | price | dishes): [1 | Platter | 120 | 3]
PROBE salad_meal (id | title | price | dressing): [2 | Salad | 90 | lemon]
```

One sequence (`meal_seq`) hands out the ids for both tables, so the Platter is 1 and the Salad 2 — never two meals with one id
(`tpcidentity` A′ in `../receipts.sh` shows the same for `probe.map.tpc`, with the script's `create sequence meal_seq start with 1
increment by 50`, on H2 and on PostgreSQL).
