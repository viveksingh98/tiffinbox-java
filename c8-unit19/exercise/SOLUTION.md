# Solution - unit 19: a pipeline on a renamed field

The pipeline the broken file builds is untyped - `newAggregation(group("customer")…)` - so the template sends the names as written,
and the server looks for a field `customer` that no document holds. Typed on the class whose field is renamed -
`newAggregation(OrderRenamed.class, group("customer")…)` - the template asks the class's mapping for each name and sends `$cust`. The
line below makes that one change while copying the file; run the same lines with it:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null && echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u19-mongo-ex -p 127.0.0.1:20589:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd --unixSocketPrefix /data/db > /dev/null
sed 's/newAggregation(group(/newAggregation(OrderRenamed.class, group(/' exercise/RenamedRevenue.java > "$EX/RenamedRevenue.java"
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" "$EX/RenamedRevenue.java" > "$EX/run.log" 2>&1; grep -E '^(orders saved:|group |groups:)' "$EX/run.log"
docker -H "$DH" rm -fv c8u19-mongo-ex > /dev/null
```

What it prints:

```
built: 1 jar
orders saved: 120
group Sunil 9000
group Ravi 7200
group Meera 4500
group Priya 3600
groups: 4
```

The four customers again, and their totals add up to the null group's one total. The orders in `orders_r` did not change - only the
names the pipeline sends did.
