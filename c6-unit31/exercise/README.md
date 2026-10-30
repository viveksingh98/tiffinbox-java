# Exercise — Capstone: The TiffinBox Web App

**Your turn:** the README's upload refuses every row of a good list. Read why, fix the file, and upload again.

`customers.csv` (beside this file) holds two customers, Esha and Farid, and a header. The lines below copy it to
`.harness/mine/`, start TiffinBox's jar from `.harness/after` (`./receipts.sh` builds it there, with a config tree that holds the
demo token: run it once first) on port 19600, upload the copy with the anchor README's line, and stop TiffinBox with POST
/shutdown. Run them from this unit's folder, in one shell:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mkdir -p .harness/mine && cp exercise/customers.csv .harness/mine/customers.csv
(cd .harness/after && exec java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19600) > .harness/mine/run.log 2>&1 & p=$!
for i in $(seq 1 240); do curl -sf -o /dev/null http://127.0.0.1:19600/actuator/health/readiness && break; sleep 0.25; done
(cd .harness/mine && curl -s -w ' %{http_code}\n' -F "file=@customers.csv;type=text/csv" http://127.0.0.1:19600/customers/import)
harness/shutdown.sh 19600 .harness/after/secrets/tiffinbox/shutdown-token > /dev/null; wait $p
```

As shipped, the upload answers 200 and adds nobody — every line, the header too, is refused with why:

```
{"file":"customers.csv","added":0,"refused":{"line 1":"4 values expected, 1 found","line 2":"4 values expected, 1 found","line 3":"4 values expected, 1 found"}} 200
```

**Done** is this line, from a fresh TiffinBox (the last four lines above, run again):

```
{"file":"customers.csv","added":2,"refused":{}} 200
```

Each run starts its own TiffinBox: its customers live in memory, so a second upload of the same names into one running TiffinBox
would be two refusals — `a customer named Esha already exists`.
