# Exercise — one pattern more

**Your turn:** register the raw servlet on `*.menu` as well, then request `/lunch.menu` and `/raw/lunch.menu`. Which pattern
matched each?

The video registered the harness's raw servlet on three kinds of pattern — an exact path, a path ending in `/*`, and an
extension — and asked the container which one matched each request: the servlet's answer says it, read from
`getHttpServletMapping()`. This exercise ships the registration **broken**: `exercise/RawServletConfig.java` lists `/raw` and
`/raw/*` only, so `/lunch.menu` matches none of the raw servlet's patterns. The container hands it to the default servlet, `/`
— the `DispatcherServlet` — and Spring MVC finds nothing for it: a 404.

Run everything from `c6-unit02/`. The setup below copies TiffinBox — `anchor/`, a link to `../c5-unit27/after`, the anchor this
lesson reads, unchanged — to `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), puts Spring MVC's
starter into the copy with this unit's own patch (`harness/mvc.patch`), gives it a config tree with a token of its own — 26
random lowercase letters and digits, in `.harness/mine/secrets/tiffinbox/shutdown-token`, readable by you alone, never
printed — builds it offline against this unit's `.m2-demo`, and extracts the jar. On a fresh clone `.m2-demo` is empty: run
`./receipts.sh` once first (it fills `.m2-demo`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/ && (cd .harness/mine && patch -s -p1 < ../../harness/mvc.patch)
mkdir -p .harness/mine/secrets/tiffinbox && chmod 700 .harness/mine/secrets .harness/mine/secrets/tiffinbox
(umask 077 && LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26 > .harness/mine/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
```

Then try it. `exercise/try.sh` compiles the raw servlet with the registration you name into `.harness/mine/hc`, starts the copy
exploded with it joined — TiffinBox's own server on 19318, Tomcat on 19319, both on `127.0.0.1` — waits until readiness answers
200 (60 s at most), asks Tomcat each path with `harness/paths.sh`, and stops the JVM by its pid, Ctrl-C included:

```bash
exercise/try.sh exercise/RawServletConfig.java /lunch.menu /raw/lunch.menu
```

As shipped, `/lunch.menu` gets the `DispatcherServlet`'s 404 (`{"timestamp":…,"status":404,"error":"Not Found","path":"/lunch.menu"}`),
and `/raw/lunch.menu` already reaches the raw servlet. Now add `*.menu` to the list in `exercise/RawServletConfig.java` and run
the same line again.

**Done** when the two answers read

```
GET /lunch.menu      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.menu match=EXTENSION
GET /raw/lunch.menu  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
```

— where a path pattern and an extension both fit, the container chose the path pattern: `/raw/lunch.menu` still goes to
`/raw/*`, as `/raw/lunch.tiff` did in the video. (`X-Raw-Filter: -`: the raw filter is not joined here.) The same lines are in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.
