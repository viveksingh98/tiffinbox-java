# Your turn — the token, in the environment instead of the folder

In the lesson, the buildpack's image read its shutdown token from a config tree: a folder on the Mac, mounted read-only
at `/workspace/secrets` — the image's working folder is `/workspace`, and `application.yaml` imports
`optional:configtree:./secrets/`. **Start the image with the token in an environment variable instead of the folder.
Then find it with `docker inspect`.**

Run everything from this unit's folder (`c5-unit15/`), with its own `.m2-demo` (every Maven build is offline). **On a
fresh clone, run `./receipts.sh` once first:** `.m2-demo` is git-ignored, so a clone's is empty, and that run fills it — its
first build asks Maven Central for what the offline build cannot find. The first two commands build the image the lesson
built — `tiffinbox-web:1.0.0`, Boot's default name for this module — with the builder pinned by its digest (the lesson's
`$BUILDER`) and the run image its builder names (`$RUNIMAGE`). The first time this Docker builds that name, the build itself
downloads a Java runtime and two tools (the JRE and syft from github.com, Spring Cloud Bindings from Maven Central): network,
in the build step. Then a token of your own (32 random hexadecimal characters, in a file only you can read, under the
git-ignored `.harness/`), and the lesson's way of running the image — the folder mounted, the container run as your own
user (`--user "$(id -u):$(id -g)"`: in a Docker volume, which keeps a file's owner and mode as Linux does, the image's own
user could not read your token's folder — the lesson's `user` capture; on this Mac, OrbStack let it), the address set, the
port published on `127.0.0.1` only:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean install
mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
rm -rf .harness/mine && mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
docker run -d --name tiffinbox-web-mine -m 1g --user "$(id -u):$(id -g)" -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/mine/secrets:/workspace/secrets:ro" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
{ printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
```

`docker run -d` prints the new container's ID. `docker inspect` lists the container's environment — sorted, because Docker
does not keep one order — and with the folder it holds one `TIFFINBOX_` variable: `TIFFINBOX_ADDRESS=0.0.0.0`. POST /shutdown,
with the header read from your file, answers `{"stopping":true} 200`; the container then exits 0 (`docker wait`), and `docker rm`
removes it.

**Your turn.** Start the same image with the token in an environment variable — the key `tiffinbox.shutdown-token` as
an environment variable is `TIFFINBOX_SHUTDOWN_TOKEN` — and **no folder mounted**. Then run the same `docker inspect` line.

**Done** when `docker inspect` lists your token beside the address, `TIFFINBOX_SHUTDOWN_TOKEN=<your 32 characters>`, and
POST /shutdown still answers `{"stopping":true} 200`. Anyone who can run `docker inspect` on this Docker can read that
line; the folder never puts the token into the container's own record. The measured answer, run exactly as written:
`solution/SOLUTION.md`.

When you are done — the image, the two cache volumes the buildpack keeps for that image's name, and your token:

```bash
docker image rm tiffinbox-web:1.0.0
docker volume rm pack-cache-b6c0f6be399c.build pack-cache-b6c0f6be399c.launch
rm -rf .harness/mine
```

(The volumes' names come from the image's full name, `index.docker.io/library/tiffinbox-web:1.0.0`: the first 12
hexadecimal characters of its SHA-256 — the same on every machine. `receipts.sh` removes the ones a run of it created.)
