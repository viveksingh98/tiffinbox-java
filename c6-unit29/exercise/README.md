# Exercise — the routes that never asked

**Your turn:** the README turns on header versioning, and old routes now answer four hundred. Give unversioned requests a version, and run the seven again.

TiffinBox's own routes — `/customers`, `/revenue`, `/dashboard`, `/kitchen`, POST `/shutdown` — carry no version on their
mappings. The commands below switch on one of Boot's API-versioning keys for one run of TiffinBox's own jar (`anchor/`, the tree the
web-layer testing lesson made — no harness class joins it), in the array `V=( … )`, which the last line passes as `"${V[@]}"` — one
word per option, in bash and in zsh (the Mac's Terminal shell) alike: as shipped, `V` names the header TiffinBox reads a version from,
`API-Version`, and nothing else.

Run everything from `c6-unit29/`, in one shell. The commands copy `anchor/` to `.harness/mine/anchor` (git-ignored; `receipts.sh`
wipes `.harness/` when it runs) and give the copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand
-hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. `CURLSET` is the
comparison set since the secrets lesson, `../c5-unit11/curlset.sh`: the seven requests, POST /shutdown with the token's header read from
the copy's own file. The last line runs in a subshell (the parentheses), so your shell stays in `c6-unit29/` for the next run: it builds
the copy offline against this unit's `.m2-demo`, starts TiffinBox's jar on `127.0.0.1:19585` in a job of its own — its locale pinned
(`-Duser.language=en -Duser.country=US`), its pid saved — waits until readiness answers 200 (Actuator's routes take no version), runs the
seven into `.harness/mine/seven.txt`, and then stops TiffinBox: by POST /shutdown when the seven's last line says it answered 2xx, else by
its pid (`kill "$p"` — a POST /shutdown that answered 400 stopped nothing). It waits for that pid (`wait "$p"`) and prints the seven's md5,
how many of the seven answered 400, and how TiffinBox was stopped. A build that failed, or a JVM that never answered — another JDK's
`java`, say — ends the line before it prints. TiffinBox's whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty:
run `./receipts.sh` once first (no GraalVM, no Docker and no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
CURLSET="$PWD/../c5-unit11/curlset.sh"
V=(--spring.mvc.apiversion.use.header=API-Version)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19585 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19585/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && "$CURLSET" 19585 secrets/tiffinbox/shutdown-token > ../seven.txt && if grep -qE '^POST +/shutdown +-> 2' ../seven.txt; then how="POST /shutdown"; else kill "$p" && how="its pid - POST /shutdown answered $(grep -E '^POST +/shutdown' ../seven.txt | awk '{ print $4 }')"; fi && { wait "$p"; echo "the seven: md5 $(md5 -q ../seven.txt) · answered 400: $(grep -c -- ' -> 400 ' ../seven.txt) · TiffinBox stopped by: $how"; })
```

As shipped, it prints `the seven: md5 7d36b99ea48f2bb5fc961fbac1fd8a6a · answered 400: 5 · TiffinBox stopped by: its pid - POST /shutdown answered 400`
— TiffinBox started and said it was ready; then every one of its own routes that the strategy reads — four GETs and POST /shutdown —
answered 400, `"detail":"API version is required."` (a problem detail, because TiffinBox switched problem details on), and the
shutdown never happened. `/nowhere` (404) and GET `/shutdown` (405) answered as before. A request that names no version is refused
because nothing gives it one. Boot's metadata lists eight keys under `spring.mvc.apiversion` — this unit's `surface` capture prints
them — and one of them names the version a request gets when it sends none. Add it inside `V=( … )`, after the header key — 1.0 (any
version would do here: TiffinBox's own handlers carry none; 1.0 is the one the menu handlers in this lesson started from) — from the
same shell, and run the last line again.

**Done** when you can print

```
the seven: md5 466c20ed7e0d5439cb052f32ce09de1b · answered 400: 0 · TiffinBox stopped by: POST /shutdown
```

— the seven answer as they did before versioning was switched on, byte for byte, POST /shutdown included. The same line is in this unit's
`exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
