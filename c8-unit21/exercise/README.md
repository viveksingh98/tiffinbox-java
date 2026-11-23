# Exercise - unit 21: the word the analyzer never wrote down

**Your turn:** veg finds zero dishes, and a prefix finds four, one of them the vegan box. Make veg find only the vegetarian one.

This exercise needs Docker and an Elasticsearch container: the tokens a search looks up are the ones the index stored, so an index has
to hold them. The lines below start a new one - the course's Elasticsearch image by its tag, `docker.elastic.co/elasticsearch/elasticsearch:9.4.8`
(the course measured it at the digest `../c8-tiffinbox/compose.yaml` names), with the six settings that file explains, on
`127.0.0.1:20608` - and build TiffinBox's jar from `after/`, offline, from this unit's `.m2-demo`, for its libraries and for the shipped
`Dish`, whose `name` is analysed by the analyzer `dish`. `DishLab.java` then starts a small Spring Boot context - Elastic's client and
Spring Data Elasticsearch's template, three of Boot's own auto-configurations, nothing else - creates the index `dishes` with the
settings file it is given and `Dish`'s own mapping, saves the ten rows of `after/`'s `V4__dish.sql` (ids `1` to `10` in that file's
order), and prints what the index counts, then the ids a `match` query for `veg` finds and the ids a `prefix` query for `veg` finds.
The settings file here, `exercise/dish-settings-standard.json`, defines `dish` as the standard tokenizer and lowercase - the steps of
Elasticsearch's standard analyzer. Run the lines from `c8-unit21/`, in bash or zsh (the first line points at JDK 25 and at the docker
socket on the author's Mac - point them at yours; on a machine without the image, `docker -H "$DH" run` pulls it; a second run
reuses the jar the first built under `.harness/ex` - remove that folder to build it again):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -f "$EX/run.log"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u21-es-ex -p 127.0.0.1:20608:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
i=0; until curl -sf --noproxy '*' -o /dev/null http://127.0.0.1:20608/_cluster/health || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" exercise/DishLab.java exercise/dish-settings-standard.json > "$EX/run.log" 2>&1; grep -E '^(index dishes|dishes indexed|match |prefix )' "$EX/run.log"
bash exercise/check.sh
docker -H "$DH" rm -fv c8u21-es-ex > /dev/null
```

What it prints:

```
built: 1 jar
index dishes before: absent · settings dish-settings-standard.json
dishes indexed: 10 of 10 rows
match name veg: 0 []
prefix name veg: 4 [1, 10, 2, 8]
check: match name veg -> 0 [] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian] · solved: no
```

The index stored `vegetarian`, `lunch` and `box` for the vegetarian box, and a `match` for `veg` looks up the token `veg`: none of the
ten holds it. The `prefix` query finds four, and one of them is the vegan box, `8` - a way that finds the word, and a dish that is not
vegetarian. The check is `exercise/check.sh`, the store's own answers by `curl` - the ids `match` finds, and the tokens the analyzer the
mapping names for the field's search side gives for `vegetarian` - never the exit of the run, and never on an index that once held the
solution: each run starts its own container and removes it after. Make the same lines print `1 [1]` and `solved: yes` - `SOLUTION.md`
shows one way, `../c8-unit21/README.md` (nohit, sayso, late) why the other ways are not it.
