# Solution - unit 22: the count that reads one

One way: save through the template with its refresh policy set for that write - `operations.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(...)`,
a template whose writes ask Elasticsearch to refresh the index before they answer (`refresh=true` on the request). The count that follows
reads the document, and the program sent ONE document write. The other honest answer is the repository's own `save` - a `Dishes.save`, as
`DishIndexSync` uses - which sends `refresh=false` and then a `_refresh` of the index (`../c8-unit22`, nrt). The lines are the exercise's,
with one changed: the program copied into `.harness/ex` is `SaveLab.java` with that one line edited, by `perl -pe`:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -f "$EX/run.log"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
perl -pe 's/ops\.save\(dish\);/ops.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(dish);/' exercise/SaveLab.java > "$EX/SaveLab.java"
docker -H "$DH" run -d --name c8u22-es-ex -p 127.0.0.1:20618:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
i=0; until curl -sf --noproxy '*' -o /dev/null http://127.0.0.1:20618/_cluster/health || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" "$EX/SaveLab.java" > "$EX/run.log" 2>&1; grep -E '^(index dishes|saved: )' "$EX/run.log"; grep -oE "curl -iX [A-Z]+ '[^']*/dishes[^']*'" "$EX/run.log" | sed -E "s#'http://127\.0\.0\.1:[0-9]+#'#"
bash exercise/check.sh "$EX/run.log"
docker -H "$DH" rm -fv c8u22-es-ex > /dev/null
```

What it prints:

```
built: 1 jar
index dishes before: absent
saved: dish 1 · the count that follows: 1
curl -iX HEAD '/dishes'
curl -iX PUT '/dishes'
curl -iX PUT '/dishes/_doc/1?refresh=true'
curl -iX POST '/dishes/_search?search_type=query_then_fetch&typed_keys=true'
check: _count -> 1 · document writes the program sent: 1 · a refresh behind the write: yes · solved: yes
```

The same save, the same count, one document write - and `refresh=true` on it: the index refreshed before it answered the write, so the
count that follows it read `1`, and `exercise/check.sh` says `solved: yes`. Saving the dish twice, or pausing before the count, is not
it: the check counts the writes and looks for the refresh, and either one leaves `solved: no`.
