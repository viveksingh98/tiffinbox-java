# Exercise — the token, out of the environment

TiffinBox as this unit left it (`../after/`) will not stop for just anyone: POST /shutdown answers 403 unless its
`X-Shutdown-Token` header carries `tiffinbox.shutdown-token`. Below, you start it with the token in an environment
variable — where `ps eww` shows it to anyone who can run it as you. **Move the token out of the environment into a config
tree file, newline included. POST /shutdown must still answer 200.**

Run `./receipts.sh` once first, from the unit's folder (the one that holds `receipts.sh`): it builds `after/`. Then, from
that same folder, make a folder to start TiffinBox in (inside `.harness/`, which the repository ignores), step into it,
and make a token of your own — 32 random hexadecimal characters, which nothing below ever prints:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && cd .harness/mine
TOKEN=$(openssl rand -hex 16)
```

**As shipped: the token in the environment.** Start TiffinBox in the background (its log goes to `tiffinbox.log`), wait
until it answers, then send this unit's seven requests. The last one, POST /shutdown, carries the header; `-` tells
`curlset.sh` to read the token from its standard input, so it is never on a command line. `wait` lets the JVM finish:

```bash
TIFFINBOX_SHUTDOWNTOKEN="$TOKEN" java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18719 > tiffinbox.log 2>&1 &
for i in $(seq 1 60); do curl -s -o /dev/null http://127.0.0.1:18719/kitchen && break; sleep 0.5; done
printf '%s\n' "$TOKEN" | ../../curlset.sh 18719 - | tail -1; wait
```

The line it prints (measured 2026-09-30, JDK 25.0.4.1, Spring Boot 4.1.1) — the same line as this unit's `door` capture:

```
POST  /shutdown   -> 200 application/json  {"stopping":true}
```

**Your turn.** Put the token in the config tree `application.yaml` imports (`optional:configtree:./secrets/`): one file
for the key `tiffinbox.shutdown-token`, in the folder TiffinBox starts in, holding the token and a newline, readable by you
alone. Then start TiffinBox again **with no `TIFFINBOX_` variable**, and send the seven again — this time with the header
read from your file: `../../curlset.sh 18719 <your file> | tail -1`.

**Done** means POST /shutdown still answers 200 — the line above — with the token in a file and nowhere in `ps eww`.
Port 18719 is this exercise's; nothing is left listening on it once POST /shutdown has answered.

The answer, measured with the commands above exactly as written, is in `solution/SOLUTION.md`.
