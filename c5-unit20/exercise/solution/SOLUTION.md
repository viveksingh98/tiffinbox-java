# Solution — count, delete, build again, count

In the same shell, after `exercise/README.md`'s commands, from `c5-unit20/` — one line: it counts `Customer`'s entries in the file
the README's build wrote (and lists the methods of that entry), deletes the hint with `sed`, runs the README's Maven line again —
the AOT step — and counts again:

```bash
f=.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json; w=$(grep -c '"type": "com\.tiffinbox\.Customer"' $f); m=$(sed -n '/"type": "com\.tiffinbox\.Customer"/,/^    }/p' $f | grep -o '"name": "[A-Za-z]*"' | cut -d'"' -f4 | paste -sd' ' -); sed -i '' '/^@RegisterReflectionForBinding(Customer.class)$/d' .harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java && mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package > /dev/null && echo "com.tiffinbox.Customer entries - with the hint: $w, methods $m · deleted, built again: $(grep -c '"type": "com\.tiffinbox\.Customer"' $f)"
```

(The closing quote in the pattern matters: without it, `com.tiffinbox.Customer` also matches `com.tiffinbox.CustomerRepository`,
which is in the file. `sed -i ''` is the Mac's `sed`; GNU `sed` takes `-i` alone. Maven's `-q` still prints Boot's banner and two
log lines — the AOT step starts TiffinBox's `main` to read its configuration, without starting the server — so the line sends
that build's output to `/dev/null`.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-06; again after BLUE's part C edits — the same)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit20/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's four lines ran as written, one after another in that shell, every one exit 0; the first three printed nothing, the Maven
line printed 9 non-blank lines even with `-q` (Boot's banner and two log lines: the AOT step starts TiffinBox's `main`). The file it
wrote: `reachability-metadata.json`, 56,437 bytes, beside `native-image.properties`. Then the line above, exit 0, printed:

```
com.tiffinbox.Customer entries - with the hint: 1, methods mealsPerDay mealType name pricePerMeal · deleted, built again: 0
```

With the hint, Spring's AOT step wrote one entry for the record: its fields, its constructors, and four methods — `name`,
`mealsPerDay`, `pricePerMeal`, `mealType`, the accessors of the record's four components. Without it, no entry at all: nothing else
in TiffinBox registers `Customer` (the `breaks` capture, B, finds the same difference in the binary's build, and `/customers`
answering 500). The same line is in this unit's `exercise` capture.

The run after BLUE's part C edits (`env -i`, the same shell, the README's four lines typed in as written, then the line above): every line
exit 0; the README's lines printed 0, 0, 0 and 9 non-blank lines; the line above printed the Done line, and left the file — built again
without the hint — at 55,951 bytes with 0 `Customer` entries. `.m2-demo` held GraalVM's metadata repository (receipts.sh checks it is
there after its first build): without it, the Maven line's plugin would have fetched it from GitHub, even with `-o` (README.md, *The
repository*).
