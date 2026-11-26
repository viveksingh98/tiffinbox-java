# Unit 13's exercise — the cursor route takes any sort

**Your turn:** this cursor route takes any sort a client sends. Make an unknown sort a refusal, and keep the cursor bound to it.

`sh break.sh TREE` breaks a copy of `../after` (never `../after` itself): it removes the sort whitelist check in `OrderPages.java`, so the
name a client sends goes to Spring Data as a property. Build the copy and start it alone, then ask it:

```
cp -R ../after /tmp/u13-ex && sh break.sh /tmp/u13-ex
cd /tmp/u13-ex && mvn -o -DskipTests clean package -pl tiffinbox-web -am
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=21028
curl -i 'http://127.0.0.1:21028/api/v1/orders?sort=nosuch'
```

The build line skips the tests: `OrderPagesTest` asks for an unknown sort too, and the receipts never run it on the broken copy.
`sh check.sh TREE` builds the copy, starts it on 21028, sends the requests itself and passes only when the route refuses the unknown
sort with its own problem type, still refuses a cursor reused under another sort, answers page one as `../after` does, and the fix lives
in `OrderPages.java` alone.

What it prints on the broken copy (measured by the receipts, H2):

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
sort=nosuch -> 500 application/json · type none · detail Internal Server Error
a newest cursor reused with sort=oldest -> 400 application/problem+json · type tag:tiffinbox.example,2026:cursor-mismatch · detail this cursor was written for another request: sort (the cursor's newest, this request's oldest)
sort=newest -> 200 application/json · ids [19, 20, 17, 18, 15]
the JVM's log: lines naming an Exception 3
FAIL clause 1: an unknown sort is not refused 400 sort-unknown naming the four sorts (got 500 application/json)
FAIL clause 5: a Sort.by(...) built from the request's own value
check.sh: 2 clause(s) failed
```
