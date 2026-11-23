# Exercise - unit 22: the count that reads zero

**Your turn:** the template saves a dish and the count that follows it reads zero. Make that count read one without a second write.

This exercise needs Docker and an Elasticsearch container: a count is the index's own answer, so an index has to hold the document.
The lines below start a new one - the course's Elasticsearch image by its tag, `docker.elastic.co/elasticsearch/elasticsearch:9.4.8`
(the course measured it at the digest `../c8-tiffinbox/compose.yaml` names), with the six settings that file explains, on
`127.0.0.1:20618` - and build TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo`, for its libraries and for the shipped
`Dish`. `SaveLab.java` then starts a small Spring Boot context - Elastic's client and Spring Data Elasticsearch's template, three of
Boot's own auto-configurations, nothing else - creates the index `dishes` with `Dish`'s own settings and mapping, saves ONE dish through
the template (`ElasticsearchOperations.save`), and prints the count the index answers next. The client's trace logger is on, so every
request the program sends is a line of its log. Run the lines from `c8-unit22/`, in bash or zsh (the first line points at JDK 25 and
at the docker socket on the author's Mac - point them at yours; on a machine without the image, `docker -H "$DH" run` pulls it; a
second run reuses the jar the first built under `.harness/ex` - remove that folder to build it again):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -f "$EX/run.log"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
cp exercise/SaveLab.java "$EX/SaveLab.java"
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
saved: dish 1 · the count that follows: 0
curl -iX HEAD '/dishes'
curl -iX PUT '/dishes'
curl -iX PUT '/dishes/_doc/1?refresh=false'
curl -iX POST '/dishes/_search?search_type=query_then_fetch&typed_keys=true'
check: _count -> 0 · document writes the program sent: 1 · a refresh behind the write: no · solved: no
```

The template's save sent the document with `refresh=false` and nothing after it: the next request, the count, asked the index before
the index made the new document searchable, and the count read `0`. The document is in the index - a refresh, or the index's own next
one, makes it searchable - but the count that follows the save reads none. The check is `exercise/check.sh`: the index's own count by
`curl`, and the program's own requests off its log - exactly one document write, and a refresh behind it - never the exit of the run,
and never an index that once held the solution: each run starts its own container and removes it after. Make the same lines print
`saved: dish 1 · the count that follows: 1` and `solved: yes`, with one document write - `SOLUTION.md` shows one way. Saving twice
fails the check (two writes); a pause before the count fails it too (no refresh line - the trace is the judge, never the count alone).
