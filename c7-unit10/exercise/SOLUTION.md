# Solution — @OneToOne and @ManyToMany

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExMeal.java .harness/ex/ && sed 's/^    private List<ExMeal> favourites = new ArrayList<>();$/    private Set<ExMeal> favourites = new HashSet<>();/' harness/src/probe/map/ex/ExFan.java > .harness/ex/ExFan.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExFan.java .harness/ex/ExMeal.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExFan) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|Salad|  returned|ex_fan)' .harness/mine.log
```

One line differs from the README's: the copy of `ExFan.java` gets a `Set` for its favourites (by hand, open `.harness/ex/ExFan.java`
and change the field):

```java
    private Set<ExMeal> favourites = new HashSet<>();
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE Salad removed from Kavya's favourites - executeUpdate calls: 1
PROBE   returned 1 <- delete from ex_fan_favourites where ex_fan_id=? and favourites_id=?
PROBE ex_fan_favourites, read by a second connection: 2 rows
```

A `Set` holds no duplicates, so Hibernate can name Salad's row by the pair — the DELETE's `where ex_fan_id=? and favourites_id=?` —
and removes that one: one DELETE, which changed 1 row, and nothing written back. The same two rows are left. (`many` B in
`../receipts.sh` shows the Set's join table with that pair as its primary key, `primary key (favourites_id, set_fan_id)`; `many` C shows
the other way out when the order matters, a `List` with `@OrderColumn`: a DELETE and an UPDATE.)
