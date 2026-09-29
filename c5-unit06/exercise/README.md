# Exercise — five cooks, and nothing you already wrote changes

TiffinBox as this unit left it (`../after/`) reads `tiffinbox.cooks=3` from its packaged `application.properties`. Make
the harness report **five** cooks — **without editing any file, and without touching TiffinBox's arguments** (everything
after `tiffinbox.cooks` stays exactly `--tiffinbox.port=18669`). Do it twice, from two different property sources, and
read which source the winner line names each time.

Run `../receipts.sh` once first: it builds `after/`, compiles the harness, and writes the class path it uses to
`../.harness/after.classpath`. Then, from this folder (`c5-unit06/exercise/`):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd ..
AFTER="$(cat .harness/after.classpath)"
java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18669 2>&1 | grep -E '^KEY |^the bean'
```

It starts wrong on purpose — three cooks, from the file:

```
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
the bean's own field: OrderQueue.cooks = 3
```

Change the `java …` line — not a file, and not the arguments after `tiffinbox.cooks` — until the first line says
`WINNER 5` and the second says `OrderQueue.cooks = 5`. **Done** means two runs, both `WINNER 5`, whose winner lines name
two different sources — and you can say why each of them outranks the file. Port 18669 is this exercise's; every run
stops its own server before it exits (the harness closes the context).

One tempting answer is wrong, and it fails without a word: see the video's last break. The answer, measured with the
commands above exactly as written, is in `solution/SOLUTION.md`.
