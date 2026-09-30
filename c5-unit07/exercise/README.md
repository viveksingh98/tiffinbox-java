# Exercise — an area code, zero one two three

TiffinBox as this unit left it (`../after/`) keeps its settings in `application.yaml`. The `application.yaml` in this
folder is a copy of that file, byte for byte — `../receipts.sh` checks it (the `files` capture), so you never edit it:
you copy it to `my/` and edit the copy. Add an area code to your copy — the key `area-code`, under `tiffinbox:`, with the
value `0123` — and **predict** what Boot will store for `tiffinbox.area-code`. Then run it, and make it store exactly
`0123`.

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/`, compiles
the harness, and writes the class path it uses to `.harness/after.classpath`. Then, from that same folder, make your copy
— once, before your first edit:

```bash
mkdir -p my && cp exercise/application.yaml my/
```

and run the harness, after every edit of `my/application.yaml`:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
AFTER="$(cat .harness/after.classpath)"
java -cp "my:$AFTER" com.tiffinbox.harness.Winner tiffinbox.area-code --tiffinbox.port=18679 2>&1 | grep -E '^KEY |^the class path'
```

`my` comes first on the class path, so Boot reads your copy instead of the `application.yaml` packaged in TiffinBox's jar
— the last line says which file the class path gave. Before your edit, the block prints (measured 2026-09-30, JDK
25.0.4.1, Spring Boot 4.1.1):

```
KEY tiffinbox.area-code -> WINNER null · from source 0 of 7, (none)
the class path gives: application.yaml <- my/application.yaml · application.properties <- none
```

**Done** means the first line reads `KEY tiffinbox.area-code -> WINNER 0123 · …`, and you can say why the value you first
wrote did not give it. Port 18679 is this exercise's; every run stops its own server before it exits (the harness closes
the context). `my/` is yours: nothing in this unit reads it, and `rm -r my` removes it.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
