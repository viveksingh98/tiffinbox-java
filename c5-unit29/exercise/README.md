# Exercise — the image, with ten days instead of thirty

**Your turn:** start the image with ten days instead of thirty, then read what the kitchen cooked.

The video ran TiffinBox's image the anchor README's way: the jar built by Maven, packed by the anchor's `Dockerfile`, run with
your own user (`--user "$(id -u):$(id -g)"`), the config tree mounted read-only at `/app/secrets`, and the port published on
`127.0.0.1` alone. The image's entrypoint is the exec form, so an argument after the image name reaches TiffinBox — as an
option (`--name=value`), never a bare word: a bare word is refused, exit 2.

Run everything from `c5-unit29/`, with Docker answering and `eclipse-temurin:25-jre` on it (no pull). The commands below copy
TiffinBox — `anchor/` — a link to `../c5-unit27/after`, the anchor this lesson runs, unchanged — to `.harness/mine/after` (git-ignored; `receipts.sh`
wipes `.harness/` when it runs), give it a config tree with a token of its own — 26 random lowercase letters and digits, in
`.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed — build the jar offline against this
unit's `.m2-demo`, and build the image `tiffinbox-mine:1.0.0` from the anchor's `Dockerfile` (`.dockerignore` keeps `secrets/` out
of what Docker is sent). On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that:
without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this exercise's among them — and stops before the
native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target anchor/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && docker build -q -t tiffinbox-mine:1.0.0 . > /dev/null)
```

Then, from `.harness/mine/after` (the folder that holds the config tree), start the image as the video did — the name
`tiffinbox-mine`, your own user, `-m 512m`, the config tree read-only at `/app/secrets`, the port published as
`127.0.0.1:19159:18425` — with ten days given **after the image name**. Wait until
`http://127.0.0.1:19159/actuator/health/readiness` answers 200, ask `http://127.0.0.1:19159/kitchen`, then stop it with
`../../../harness/shutdown.sh 19159 secrets/tiffinbox/shutdown-token` (POST /shutdown, the token read from the file), wait for
the container to exit, and remove it (`docker rm tiffinbox-mine`). Print what the kitchen said.

**Done** when you can print

```
the kitchen, ten days, in the image: {"ordersCooked":40,"ordersValue":8100}
```

— thirty days cook 120 orders worth 24300; ten cook 40, worth 8100. An argument written before the image name is Docker's, not
TiffinBox's; one typed without `--` and `=` is refused. The same line is in this unit's `exercise` capture (`.r-exercise.out`).
The measured answer, run exactly as written: `solution/SOLUTION.md`. When you are done, `docker image rm tiffinbox-mine:1.0.0`.
