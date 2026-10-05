# Your turn — the token, in the environment instead of the folder

In the lesson, the buildpack's image read its shutdown token from a config tree: a folder on the Mac, mounted read-only
at `/workspace/secrets` — the image's working folder is `/workspace`, and `application.yaml` imports
`optional:configtree:./secrets/`. **Start the image with the token in an environment variable instead of the folder.
Then find it with `docker inspect`.**

Run everything from this unit's folder (`c5-unit15/`), with its own `.m2-demo` (every Maven build is offline). The first
two commands build the image the lesson built — `tiffinbox-web:1.0.0`, Boot's default name for this module — with the
builder pinned by its digest (the lesson's `$BUILDER`) and the run image its builder names (`$RUNIMAGE`). Then a token of
your own (32 random hexadecimal characters, in a file only you can read, under the git-ignored `.harness/`), and the
lesson's way of running the image — the folder mounted, the address set, the port published on `127.0.0.1` only:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean install
mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
rm -rf .harness/mine && mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/mine/secrets:/workspace/secrets:ro" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
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

When you are done:

```bash
docker image rm tiffinbox-web:1.0.0
rm -rf .harness/mine
```

(The buildpack also keeps two cache volumes for the image's name, `pack-cache-<hash>.build` and `.launch`; `docker volume
ls` lists them, and `docker volume rm` removes them. `receipts.sh` removes the ones a run of it created.)
