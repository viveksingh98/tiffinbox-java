# Exercise - unit 19: a pipeline on a renamed field

**Your turn:** the revenue pipeline prints one group, null 24300, on the renamed field. Make it print the four customers again.

This exercise needs Docker and a MongoDB container: it is about a pipeline the server runs, so a server has to run it. The lines below
start one - the course's MongoDB image by its digest, with the variable the course's machine needs (`../c8-tiffinbox/compose.yaml` says
why), on `127.0.0.1:20589` - and build TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo`, for its libraries.
`RenamedRevenue.java` then makes TiffinBox's orders - one per customer per day, read off `after/`'s seed and `tiffinbox.days` - stores
them in the collection `orders_r` with the customer under another name, `cust` (`@Field`), and runs the grouping pipeline: group by
customer, sum the values, sort by the total. It prints the groups it gets back. Run the lines from `c8-unit19/`, in bash or zsh (the
first line points at JDK 25 and at the docker socket on the author's Mac - point them at yours; on a machine without the image,
`docker -H "$DH" run` pulls it):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; rm -rf "$EX"; mkdir -p "$EX"; rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
(cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null && echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u19-mongo-ex -p 127.0.0.1:20589:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd --unixSocketPrefix /data/db > /dev/null
cp exercise/RenamedRevenue.java "$EX/RenamedRevenue.java"
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" "$EX/RenamedRevenue.java" > "$EX/run.log" 2>&1; grep -E '^(orders saved:|group |groups:)' "$EX/run.log"
docker -H "$DH" rm -fv c8u19-mongo-ex > /dev/null
```

What it prints:

```
built: 1 jar
orders saved: 120
group null 24300
groups: 1
```

One group, its customer null, holding every order's value: the pipeline names the field `customer`, and no stored document has one -
each holds `cust`. The server groups every document under the same missing value, and no error says so. The check is the groups it
prints - one null group in the broken state, the four named customers once solved - never the exit of the run. Change
`exercise/RenamedRevenue.java` until the same lines print the four customers - `SOLUTION.md` shows one way, `../c8-unit19/README.md`
(field, silent) why.
