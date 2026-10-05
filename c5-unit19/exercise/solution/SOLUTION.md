# Solution — two counts with `grep -c`

The file is `.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json`.
Each reflection entry names its class on one line, `"type": "…"`; so `grep -c` with the class's prefix counts TiffinBox's
entries, and the same with `Customer` and its closing quote counts the record's. In the same shell, after
`exercise/README.md`'s commands, from `c5-unit19/`:

```bash
f=.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json; echo "reflection entries naming com.tiffinbox: $(grep -c '"type": "com\.tiffinbox\.' $f) · com.tiffinbox.Customer: $(grep -c '"type": "com\.tiffinbox\.Customer"' $f)"
```

(The closing quote matters: without it, `com.tiffinbox.Customer` also matches `com.tiffinbox.CustomerRepository`, which is in
the file — the scan found it, and Spring builds it — and the count would say 1.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-05)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit19/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's four lines ran as written, one after another in that shell, every one exit 0; the first three printed nothing, the Maven
line printed 9 non-blank lines even with `-q` — Boot's banner and two log lines, because `process-aot` starts TiffinBox's `main` to read
its configuration (it never starts the server). The file it wrote: `reachability-metadata.json`, 55,436 bytes, beside
`native-image.properties`. Then the line above, exit 0, printed:

```
reflection entries naming com.tiffinbox: 9 · com.tiffinbox.Customer: 0
```

The nine: `CustomerRepository`, `Dashboard`, `Database`, `MealType`, `OrderQueue`, `TiffinBoxProperties`, `web.TiffinBoxApp`,
`web.TiffinBoxServer` and `web.TiffinBoxServer__ApplicationContextInitializer` — classes Spring itself builds, binds or calls,
and its own generated initializer. `Customer` is not one of them: Spring never builds a `Customer`; TiffinBox's own code does,
and Jackson turns it into JSON by reflection, which no build step saw. The same lines are in this unit's `exercise` capture.
