# Exercise — let Boot read the port

`TiffinBoxServer.main` still starts with the last course's bridge: three lines that copy the first command-line
argument into the system property `tiffinbox.port`, so that the documented command, `java -jar tiffinbox-web-1.0.0.jar
<port>`, kept working. Boot reads its own command line now — `commandLineArgs` is one of the four property sources it
added — so the bridge can go.

**Delete those three lines**, and give the port the way Boot reads it: `--tiffinbox.port=<port>`.

Start from this unit's frozen `after/`, not from `../../c5-tiffinbox` (later units keep changing the anchor). Run every
block below from `c5-unit01/exercise/`, after `../receipts.sh` has filled `../.m2-demo` — the build then needs no
network. Ports 18527 and 18528 are this unit's (contract §R.10).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rsync -a --exclude target ../after/ my-tiffinbox/
```

Now edit `my-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java`: delete the three lines at
the top of `main` — the `if (args.length > 0) {`, the `System.setProperty(...)` inside it, and its closing `}`. Then:

```bash
(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests clean package)
java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18527 > new.log 2>&1 &
sleep 5
../../c4-unit31/curlset.sh 18527 | grep ' -> ' | md5 -q
```

**Done means** the last line prints `115c36bac276128e245ca57df11c2891` — the hash `receipts.sh` prints for the seven
responses, before and after (`.r-identical.out`). `curlset.sh` ends with `POST /shutdown`, so the server stops itself.

Then run the command the last course documented — the port as a bare first argument — and ask the operating system
which port the server really listens on:

```bash
java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18528 > old.log 2>&1 &
sleep 5
lsof -nP -a -p $! -iTCP -sTCP:LISTEN
kill $!
```

Which port did you get, and why did nothing warn you? When you are done: `rm -rf my-tiffinbox new.log old.log`.
The answer, and the run that measured it, are in `solution/SOLUTION.md`.
