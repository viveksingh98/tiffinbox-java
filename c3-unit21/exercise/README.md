# Exercise — make the customer a field, not a substring

## The start state

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" -q compile exec:exec
jq -c 'select(.customer=="Bela")' target/logs/kitchen.json
```

Nothing. Six events in the file and **zero** hits, because "Bela" is inside the message
string and nowhere else. `grep Bela` finds it; `jq` cannot, because there is no field to
ask about.

## Your task

Make this work:

```
jq -c 'select(.customer=="Bela")' target/logs/kitchen.json
```

Edit the two `accepted for ...` calls in
`src/main/java/com/tiffinbox/kitchen/KitchenEvents.java`. The order id gets into the JSON
through the MDC; the customer name should not, because it belongs to **one event** rather
than to every line of the request. The encoder ships the tool for that case —
`net.logstash.logback.argument.StructuredArguments.kv`, used as a logging argument.

Do **not** change `logback.xml`. The point is that a new field costs no configuration.

## The end state you are reaching

```
{"@timestamp":"...","message":"accepted for customer=Bela",...,"orderId":"B-9082","customer":"Bela"}
```

and, in the text log next to it:

```
<time> INFO  kitchen B-9082 - accepted for customer=Bela
```

**One argument, both audiences.** `kv` renders `customer=Bela` into the human-readable
message *and* adds `"customer":"Bela"` as a top-level JSON key. The keys on that event go
from eight to nine, and the answer to the query goes from 0 to 1.

## The answer

`solution/KitchenEvents.java`. `../receipts.sh solution` copies it into a throwaway copy of
this directory, runs both states, and prints the query's hit count before and after with
the key list beside it.
