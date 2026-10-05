# Solution — the token in the environment, and where docker inspect shows it

The same image and the same token file as `../README.md`; the token goes into `docker run`'s `-e`, read from your file,
and no folder is mounted:

```bash
docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -e TIFFINBOX_SHUTDOWN_TOKEN="$(head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token)" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
{ printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
```

**Measured.** `../README.md`'s first bash block, then the block above, every line exactly as written, in one clean shell
(`env -i HOME=… PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`), from `c5-unit15/`, on 2026-10-05.
Two things are masked here: the token (yours, 32 random hexadecimal characters) and the container IDs `docker run -d` printed.

```
$ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  (exit 0)
$ export PATH="$JAVA_HOME/bin:$PATH"
  (exit 0)
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean install
  (exit 0)
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
  (exit 0)
$ rm -rf .harness/mine && mkdir -p .harness/mine/secrets/tiffinbox && (umask 077 && openssl rand -hex 16 > .harness/mine/secrets/tiffinbox/shutdown-token)
  (exit 0)
$ docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/.harness/mine/secrets:/workspace/secrets:ro" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
[a container ID]
  (exit 0)
$ i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
  (exit 0)
$ docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
TIFFINBOX_ADDRESS=0.0.0.0
  (exit 0)
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
{"stopping":true} 200
  (exit 0)
$ docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
0
tiffinbox-web-mine
  (exit 0)
$ docker run -d --name tiffinbox-web-mine -m 1g -e TIFFINBOX_ADDRESS=0.0.0.0 -e TIFFINBOX_SHUTDOWN_TOKEN="$(head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token)" -p 127.0.0.1:18866:18425 tiffinbox-web:1.0.0
[a container ID]
  (exit 0)
$ i=0; until docker logs tiffinbox-web-mine 2>&1 | grep -q 'TiffinBox listening'; do i=$((i + 1)); [ $i -lt 60 ] || break; sleep 1; done
  (exit 0)
$ docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tiffinbox-web-mine | grep '^TIFFINBOX_' | sort
TIFFINBOX_ADDRESS=0.0.0.0
TIFFINBOX_SHUTDOWN_TOKEN=[masked: the 32-character token]
  (exit 0)
$ { printf 'X-Shutdown-Token: '; head -n 1 .harness/mine/secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18866/shutdown
{"stopping":true} 200
  (exit 0)
$ docker wait tiffinbox-web-mine && docker rm tiffinbox-web-mine
0
tiffinbox-web-mine
  (exit 0)
```

**Why.** `-e` writes the variable into the container's own record, its configuration, and `docker inspect` prints that record
to anyone who can reach this Docker. The mounted folder is read by
TiffinBox at start and never enters that record: with the folder, `docker inspect` lists one `TIFFINBOX_` variable, the address.
Either way POST /shutdown answers 200: Boot binds the same key, `tiffinbox.shutdown-token`, from the environment variable or from
the config tree's file. (The image built by the first two commands downloads, inside the build, what its buildpacks need — the
JRE, syft and a library jar — when this Docker has no image of that name yet: network, in the build step.)
