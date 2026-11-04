# Solution — Embeddables and Value Objects

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    private Address office;$/    @AttributeOverride(name = "line1", column = @Column(name = "office_line1")) @AttributeOverride(name = "city", column = @Column(name = "office_city")) @AttributeOverride(name = "pincode", column = @Column(name = "office_pincode", length = 6)) private Address office;/' harness/src/probe/map/ex/ExCustomer.java > .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|ex_customer)' .harness/mine.log
```

One line differs from the README's: the copy of `ExCustomer.java` gets three `@AttributeOverride` annotations on its `office` field
(by hand, open `.harness/ex/ExCustomer.java` and put them above `private Address office;`):

```java
    @Embedded
    @AttributeOverride(name = "line1", column = @Column(name = "office_line1"))
    @AttributeOverride(name = "city", column = @Column(name = "office_city"))
    @AttributeOverride(name = "pincode", column = @Column(name = "office_pincode", length = 6))
    private Address office;
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE ex_customer's columns, as the catalogue gives them (8): [office_pincode, pincode, id, city, line1, name, office_city, office_line1]
PROBE ex_customer's rows, read by a second connection (1): [700016 | 411001 | 1 | Pune | 12 MG Road | Ravi | Kolkata | 4 Park Street]
```

Each `@AttributeOverride` names one of `Address`'s fields and gives it a column for this one use: the home keeps `line1`, `city` and
`pincode`, the office gets `office_line1`, `office_city` and `office_pincode`. `Address` itself is unchanged. An override replaces the
whole `@Column`, so `length = 6` is written again for the office's pincode. One row, eight columns: the id, the name, and three for each
address.
