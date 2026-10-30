# Solution — Capstone: The TiffinBox Web App

The upload reads a line as four values between commas (`name,mealsPerDay,pricePerMeal,mealType`, the anchor README's format).
`customers.csv` separates them with semicolons, so each line is one value: `4 values expected, 1 found`, for every line — and the
header is not skipped, because the upload skips a first line only when it starts with `name,`. Commas instead of semicolons, and
the same upload from a fresh TiffinBox:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
sed 's/;/,/g' exercise/customers.csv > .harness/mine/customers.csv
(cd .harness/after && exec java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19600) > .harness/mine/run.log 2>&1 & p=$!
for i in $(seq 1 240); do curl -sf -o /dev/null http://127.0.0.1:19600/actuator/health/readiness && break; sleep 0.25; done
(cd .harness/mine && curl -s -w ' %{http_code}\n' -F "file=@customers.csv;type=text/csv" http://127.0.0.1:19600/customers/import)
harness/shutdown.sh 19600 .harness/after/secrets/tiffinbox/shutdown-token > /dev/null; wait $p
```

Measured (`receipts.sh`, `exercise`, in the same shell as the README's lines):

```
{"file":"customers.csv","added":2,"refused":{}} 200
```

The `sed` reads the shipped file, so running these lines again gives the same answer: two customers added, none refused.
