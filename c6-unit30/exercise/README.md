# Exercise — the list the switch leaves alone

**Your turn:** the README switches compression on, yet the customer list still arrives unzipped. Find the setting that skips it, change it, and fetch again.

Compression is one of Boot's switches: `server.compression.enabled`, off unless a run sets it. The commands below switch it on for one
run of TiffinBox's own jar (`anchor/`, the tree the web-layer testing lesson made - no harness class joins it), in the array `V=( ... )`,
which the last line passes as `"${V[@]}"` - one word per option, in bash and in zsh (the Mac's Terminal shell) alike: as shipped, `V`
holds that one key, and nothing else.

Run everything from `c6-unit30/`, in one shell. The commands copy `anchor/` to `.harness/mine/anchor` (git-ignored; `receipts.sh`
wipes `.harness/` when it runs) and give the copy a config tree with a token of its own - 26 random hexadecimal digits (`openssl rand
-hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed; that file is the config
tree's only file. `S` is this unit's `harness/shutdown.sh`: POST /shutdown, with the token read from that file. The last line runs in a
subshell (the parentheses), so your shell stays in `c6-unit30/` for the next run: it builds the copy offline against this unit's
`.m2-demo`, starts TiffinBox's jar on `127.0.0.1:19596` in a job of its own - its locale pinned (`-Duser.language=en
-Duser.country=US`), its pid saved - waits until readiness answers 200, **fetches the customers' list once with gzip asked**
(`-H 'Accept-Encoding: gzip'`; `%{size_download}` is the number of bytes that crossed the wire), stops TiffinBox by POST /shutdown,
waits for that pid (`wait "$p"`) and prints the bytes, the answer's `Content-Encoding` (`none` when it has none) and the shutdown's
status. Every run is a fresh JVM: nothing is POSTed, and a second run in the same shell measures the same list. A build that failed,
or a JVM that never answered - another JDK's `java`, say - ends the line before it prints. TiffinBox's whole log is
`.harness/mine/run.log`, the answer's headers `.harness/mine/head.txt`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once
first (no GraalVM, no Docker, no TLS and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
S="$PWD/harness/shutdown.sh"
V=(--server.compression.enabled=true)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19596 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19596/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && b=$(curl -s -o /dev/null -D ../head.txt -H 'Accept-Encoding: gzip' -w '%{size_download}' http://127.0.0.1:19596/customers) && "$S" 19596 secrets/tiffinbox/shutdown-token > ../stop.txt && { wait "$p"; echo "/customers, gzip asked: $b bytes · Content-Encoding: $(tr -d '\r' < ../head.txt | grep -i '^content-encoding: ' | cut -d' ' -f2 | grep . || echo none) · TiffinBox stopped by: POST /shutdown, $(awk '{ print $4 }' ../stop.txt)"; })
```

As shipped, it prints `/customers, gzip asked: 282 bytes · Content-Encoding: none · TiffinBox stopped by: POST /shutdown, 200` - the
switch is on, gzip was asked, and the list still crossed the wire whole. Compression did not skip it by its type: `application/json` is
one of the eight types on Boot's default list (this unit's `which` capture prints them), and the dashboard page, which is smaller than two
kilobytes too, came back zipped with the same switch (`which`). Look at the answer's headers in `.harness/mine/head.txt`: the list says how long it is.
One of the five `server.compression` keys in Boot's metadata sets the size an answer of known length must reach before Tomcat zips it.
Add it inside `V=( ... )`, after the switch - 128 bytes - from the same shell, and run the last line again.

**Done** when you can print

```
/customers, gzip asked: 129 bytes · Content-Encoding: gzip · TiffinBox stopped by: POST /shutdown, 200
```

- the same list, zipped: 129 bytes cross the wire instead of 282. The same line is in this unit's `exercise` capture (`.r-exercise.out`).
The measured answer, run exactly as written: `solution/SOLUTION.md`.
