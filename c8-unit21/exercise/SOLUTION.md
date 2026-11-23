# Solution - unit 21: the word the analyzer never wrote down

The analyzer writes the tokens an index stores, and a `match` query looks its own words up through the same analyzer. TiffinBox's shipped
`dish-settings.json` - `exercise/dish-settings.json` is a byte-for-byte copy of it - adds a synonym filter, `veg, vegetarian`, after
lowercase: the vegetarian box's name then stores `vegetarian`, `veg`, `lunch` and `box`, and `veg` finds that dish and no other. The
same lines, the settings file named on the program's line changed, on a new container again:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"; DH="unix://$HOME/.orbstack/run/docker.sock"
EX="$PWD/.harness/ex"; mkdir -p "$EX"; rm -f "$EX/run.log"; [ -d "$EX/tb" ] || rsync -a --exclude target --exclude secrets after/ "$EX/tb/"
[ -f "$EX/x/tiffinbox-web-1.0.0.jar" ] || { (cd "$EX/tb" && perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -q -B "-Dmaven.repo.local=$EX/../../.m2-demo" package -DskipTests -pl tiffinbox-web -am) && perl -e '$SIG{INT}="DEFAULT"; alarm 120; exec @ARGV' java -Djarmode=tools -jar "$EX/tb/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" extract --destination "$EX/x" > /dev/null; }; echo "built: $(ls "$EX/x" | grep -c '^tiffinbox-web-1.0.0.jar$') jar"
docker -H "$DH" run -d --name c8u21-es-ex -p 127.0.0.1:20608:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" docker.elastic.co/elasticsearch/elasticsearch:9.4.8 > /dev/null
i=0; until curl -sf --noproxy '*' -o /dev/null http://127.0.0.1:20608/_cluster/health || [ $i -ge 240 ]; do sleep 0.5; i=$((i + 1)); done
perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" exercise/DishLab.java exercise/dish-settings.json > "$EX/run.log" 2>&1; grep -E '^(index dishes|dishes indexed|match |prefix )' "$EX/run.log"
bash exercise/check.sh
docker -H "$DH" rm -fv c8u21-es-ex > /dev/null
```

What it prints:

```
built: 1 jar
index dishes before: absent · settings dish-settings.json
dishes indexed: 10 of 10 rows
match name veg: 1 [1]
prefix name veg: 4 [1, 10, 2, 8]
check: match name veg -> 1 [1] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian, veg] · solved: yes
```

One hit, the vegetarian box, by the store's own `match`; and the analyzer the mapping names for `name`, `dish`, gives `veg` beside
`vegetarian`. The `prefix` line still finds four: that query never passes through the analyzer's synonym - the solution is the analyzer,
not a different query.
