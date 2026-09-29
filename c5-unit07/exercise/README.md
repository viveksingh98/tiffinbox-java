# Exercise — an area code, zero one two three

TiffinBox as this unit left it (`../after/`) keeps its settings in `application.yaml`. The `application.yaml` in this
folder is a copy of that file, byte for byte (`../receipts.sh` checks it: the `files` capture). Add an area code to it —
the key `area-code`, under `tiffinbox:`, with the value `0123` — and **predict** what TiffinBox's environment will answer
for `tiffinbox.area-code`. Then run it, and make it answer exactly `0123`.

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/`, compiles
the harness, and writes the class path it uses to `.harness/after.classpath`. Then, from that same folder:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
AFTER="$(cat .harness/after.classpath)"
java -cp "exercise:$AFTER" com.tiffinbox.harness.Winner tiffinbox.area-code --tiffinbox.port=18679 2>&1 | grep -E '^KEY |^the class path'
```

`exercise` comes first on the class path, so Boot reads this folder's `application.yaml` instead of the copy packaged in
TiffinBox's jar — the last line says which file the class path gave. As shipped, before your edit, the block prints
(measured 2026-09-30, JDK 25.0.4.1, Spring Boot 4.1.1):

```
KEY tiffinbox.area-code -> WINNER null · from source 0 of 7, (none)
the class path gives: application.yaml <- exercise/application.yaml · application.properties <- none
```

**Done** means the first line reads `KEY tiffinbox.area-code -> WINNER 0123 · …`, and you can say why the value you first
wrote did not give it. Port 18679 is this exercise's; every run stops its own server before it exits (the harness closes
the context). When you are finished, `cp after/tiffinbox-web/src/main/resources/application.yaml exercise/` puts the
shipped copy back — `receipts.sh` expects it byte for byte.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
