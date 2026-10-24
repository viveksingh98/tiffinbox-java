# c6-unit24 — Sessions, Cookies and Flash Attributes

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its seventh and last unit and the last link of its anchor chain (22 → 23 →
24) · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Thymeleaf 3.1.5),
**GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**, **headless Chrome 155** driven by **node 26** (both optional),
2026-10-22. The serving lesson gave TiffinBox a form whose POST answers `302` to the dashboard — and the dashboard says nothing about
it. This unit makes it say "Lata added", once: a **flash attribute** (a value Spring MVC keeps for one client until the redirect's next
request has read it), which lives in a **session** (state the server keeps for one client between requests), which is found again by a
**cookie** (a name and value a server asks the client to keep and send back). It reads that cookie — `JSESSIONID`, `HttpOnly` — from
curl and from a real browser, and keeps the session's id out of the address: Tomcat's default **session tracking** (the ways a session's
id travels) writes it into a first redirect's `Location` too. It measures that the seven do not move and make no session, what makes
one, the note across the redirect and without a cookie, the id in the address (A/B/A′), the cookie attributes Course 10 decides,
DevTools' persistent sessions, and every form: jar, AOT jar, native binary and image.

**The anchor changes (brief ⚑2, ⚑5) — for the last time in Section 4.** `after/` is this unit's frozen copy of `../c6-tiffinbox` after
the change, and `diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit: `c6-tiffinbox` = `c6-unit24/after` at the
section's end. "Before" is `before/`, the link to `../c6-unit23/after` — the static-resource lesson's frozen tree, which `c6-tiffinbox`
equalled before this unit (`diff -rq -x target` empty, checked first). Both trees are read and copied under `.harness/`, never built in
place. Three files changed, besides the anchor's README (`change`):

- `tiffinbox-web/src/main/java/com/tiffinbox/web/DashboardPage.java` — 100 → 107 lines: `POST /customers` takes a `RedirectAttributes`
  and, once the customer is stored, `flash.addFlashAttribute("added", customer.name())` before `redirect:/dashboard`; the class comment
  says so.
- `tiffinbox-web/src/main/resources/templates/dashboard.html` — one line: `<p class="note" th:if="${added != null}" th:text="${added} +
  ' added'">`.
- `tiffinbox-web/src/main/resources/application.yaml` — 122 → 128 lines: in its **first document**, under `server:` (line 19), a 3-line
  comment and `servlet.session.tracking-modes: cookie` (R.87: line 27; the first `---` at 121). Boot's metadata gives the key no default;
  Tomcat's own default modes are `COOKIE` and `URL` (the harness's `Visits` reads them off the servlet context, `cookie`).
- `README.md` — the anchor's: its unit 24 section, and two history notes made false (below).

29 of `after/`'s 33 files are byte for byte the previous tree's; the jar's 61 libraries are the same names; the stylesheet — and so its
versioned name — is untouched.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens, 0 session ids; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.) **Docker must answer**, with
`eclipse-temurin:25-jre` already on it: the script never pulls. It **dies** when a capture's md5 differs from `receipts.md5`. One native
build per `forms` run (three per receipt), each bounded at 20 minutes; its seconds go to the terminal only. **Start it in a process
group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group, and one
run's clean-up would stop the other's processes (R.94).

**Runs (2026-10-22/23):** each `env -i` (HOME and a plain PATH, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`), a process group of its own,
`.m2-demo` re-seeded from `_research/m2-seed-s4/` alone. **1,474 s under `/bin/bash` 3.2.57**: all 9 captures 3/3, every check passed
but the bottom block's (two checks of mine were wrong, "Found on the way") and — as designed for a first run — "no published hash";
their hashes went into `receipts.md5`. **1,187 s under `./receipts.sh`** (/bin/bash 3.2.57): exit 0, all 9 = published, every check
passed. **1,424 s under `bash receipts.sh`** (Homebrew bash 5.3.9): exit 0, all 9 = published. **A sealed fresh clone**, the script as
it stands (`git clone` of tiffinbox-java at 5bee4ce, this unit's and the anchor's 52 files put in as git would take them — 0 differing
from the working tree, `before` → `../c6-unit23/after` by `readlink`; `env -i`, a `HOME` of its own whose `.mavenrc` sets `user.home` to
it and points every Java proxy at a refusing port, Maven settings sending every repository to a `file://` copy of Central's files made
from `_research/m2-seed-s4/` (4,412 files) with Maven's own proxies at the same port, the proxy variables at it too, `GRAALVM_HOME`,
`DOCKER_CONFIG`, `/bin/bash` 3.2, a process group of its own): **exit 0, all 9 = published, every check passed, 1,233 s; 720
artifacts downloaded, every one from the `file://` copy** (and TiffinBox's own, installed by the run) — its first build and DevTools'
`dependency:get` said `offline: no`, as a fresh clone's must, every capture's build `offline: yes`. **An earlier sealed attempt was not
sealed** (my fault, not the script's): its `.mavenrc` set only Java's proxy properties, which Maven's resolver does not read, and its
settings file sat where Maven never looks (Java's `user.home` is the account's, not `$HOME`) — it fetched the same 720 artifacts,
85.9 MB, from Maven Central into the clone's own `.m2-demo` in the scratch folder, then passed (all 9 = published). Those are this
unit's only downloads; nothing went into this unit's `.m2-demo` or any other folder of the repository. Every native build took 153-299
s (terminal only), under the 20-minute bound.

**Runs after BLUE S4 part 2 (2026-10-23/24; RED S4 #380, #381, #384, #404, #405, #406):** `receipts.sh` changed — the platform
masked beside Chrome's version, `browser` gained G (labelled, the control for F: the same server reached as `tiffin.test` — Chrome
refuses the cookie, `SecureOnly`, 0 cookies, no note), the thirty minutes read from `cookie`'s `maxInactiveSeconds` (#406, no longer
arithmetic on two literals) and DevTools' exit 1 asserted (R.109); the YAML's comment (line 24, after/ and c6-tiffinbox alike, every line
number kept) and the exercise card now say "a copied link keeps, and so does every link on that page" (#380). `change` re-hashed
`f3389c04…` → `d3ca321c…`, `browser` `14e693d6…` → `75c9f3a2…`, the other seven unchanged. One development run (bash 3.2, 1,324 s:
all 9 captures 3/3, then it stopped at the hygiene check, which now allows `tiffin.test` in G's three lines alone) fixed the new hashes;
a first run of record was cut off mid-`forms` when the session running it ended (no exit line — not counted). Then, each `env -i` (HOME,
a plain PATH, `GRAALVM_HOME`, `DOCKER_CONFIG`), a session of its own: **1,052 s under `./receipts.sh`** (/bin/bash 3.2.57) and
**1,122 s under `bash receipts.sh`** (Homebrew bash 5.3.9), each exit 0, all 9 captures 3/3 = published, every check passed; native
builds 137-161 s (terminal only). The exercise by hand: README then SOLUTION twice in one `env -i` shell (`;jsessionid=<id>` → the
clean address, the shell still in `c6-unit24`), and SOLUTION alone in a fresh shell whose `java` is 23 — the same. A SIGINT to the
receipt's process group while `cookie`'s JVM listened on 19531: exit 130 in 42 s, nothing left in the group, no listener on 19530-19539,
no `.r-lock`, the captures byte for byte as before, the author's Chrome untouched. **A sealed fresh clone by the recipe below**
(`git clone` at 9bbcb0e, the chain's 176 files put in as git would take them — 0 differing but the three `before` links, which
`readlink` reads as `../c6-unit16/after`, `../c6-unit22/after`, `../c6-unit23/after`; c6-tiffinbox = c6-unit24/after in the clone; a
`file://` copy of 4,420 files; pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s)): **exit 0, all 9 =
published, every check passed, 1376 s; `_remote.repositories` by repository id: 720 `>sealed=` (in 510 artifact folders),
0 `central`**; the 5 lines with no id are TiffinBox's own three modules, installed by the run. The sealed-clone paragraph above was written before RED S4 #405: as described it does not seal — the recipe below does.

Published hashes: change `d3ca321c40671555a45ec3c1c2f72cff` · cookie `4610656da5e961d0c6ec198737b08015` · flash `15b5f967cfe6429cc508e70c2aafcdbf` · tracking `9950175fd8abbd4a1d79242a201e137f` · flags `25cea182335da92a21fc9d42cbda9742` · persistent `5120b0976bcba28874c429a984eb8b61` · exercise `26bdb3d3fec28afede73683955a23da7` · browser `75c9f3a272cc7b0286a1766c597da781` · forms `f36119eccf205f86b3b5739cf257b562`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-24                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit24/.m2-demo/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s"\n' "$S/home" > "$S/home/.mavenrc"     # mvn reads $HOME/.mavenrc; Java then reads this user.home
cat > "$S/home/.m2/settings.xml" <<XML
<settings>
  <mirrors><mirror><id>sealed</id><mirrorOf>*</mirrorOf><url>file://$S/central</url></mirror></mirrors>
  <proxies>
    <proxy><id>dead-http</id><active>true</active><protocol>http</protocol><host>127.0.0.1</host><port>9</port></proxy>
    <proxy><id>dead-https</id><active>true</active><protocol>https</protocol><host>127.0.0.1</host><port>9</port></proxy>
  </proxies>
</settings>
XML
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost GRAALVM_HOME=$GRAALVM_HOME DOCKER_CONFIG=$HOME/.docker"     # this unit's native build and image need both (your own GraalVM and Docker)
# pre-flight: an artifact that exists nowhere, asked for through the sealed settings - it must fail, having asked file:// and nothing else
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit24" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but thirty-two, which are this unit's,
each read from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.servlet.session.tracking-modes=cookie,url
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.tracking-modes=cookie,url
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.same-site=strict
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.secure=true
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.timeout=90s
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.secure=true --server.servlet.session.cookie.same-site=strict
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions"
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions" --server.servlet.session.persistent=false
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Sessions.java harness/probe/web/Trace.java harness/probe/web/Visits.java
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:18431/customers
curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:18431/customers
curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard
curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:18431/customers
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:18431/probe/visits
curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:18431/probe/visits
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Zoe","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -L -X POST -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:18431/customers
curl -s -L -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:18431/customers
"$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
"$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --proxy-bypass-list=tiffin.test --host-resolver-rules='MAP tiffin.test 127.0.0.1, MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
node harness/cdp.mjs 19539 open http://127.0.0.1:18431/dashboard .harness/ev.json
node harness/cdp.mjs 19539 form http://127.0.0.1:18431/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
node harness/cdp.mjs 19539 form http://tiffin.test:18431/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
node harness/cdp.mjs 19539 cookies
node harness/cdp.mjs 19539 close
python3 harness/net.py .harness/ev.json 18431
python3 harness/net.py .harness/ev.json 18431 tiffin.test
python3 harness/netlog.py .harness/netlog.json 18431
```

The first two are the anchor's run line and class-path line with `-Duser.language=en -Duser.country=US` after `java`; the third is the
run line with Tomcat's default tracking modes for one run (`tracking` B, `forms`). The **harness line** is the class-path line with the
harness's classes and `Dump`, `Sessions` and `Visits` joined; the next five are it with one session key changed for the run (B in
Chrome, `SameSite`, `Secure`, the timeout) and with `Secure` and `SameSite` together (`browser` F). The **DevTools line** is the
class-path line with DevTools' jar from `.m2-demo` and the harness added, Live Reload off (35729 is never bound), `Keys` and `Visits`
joined and the session folder named in the run's own folder (`"$PWD/sessions"`: `.harness/after/sessions`); the next is it with
persistence off. The javac line compiles the harness's five classes against after/'s libraries. The **POST line** is the anchor's new
form line (`curl -s -D - -o /dev/null --data '…' …/customers`) with the headers and the body sent to files and curl's status printed
(`--data` sends a form's own type, `application/x-www-form-urlencoded`); the jar lines are lines with curl's cookie jar (`-b` and `-c
.harness/jar`: curl keeps what `Set-Cookie` gives and sends it back); the page line is the anchor's `curl -s -H 'Accept: text/html'
…/dashboard` with the headers and the body sent to files; the GET lines are the POST line without its form, at `/customers` and at the
harness's `/probe/visits`; the JSON line is the POST line with a JSON body and its type; the two `-L` lines follow the redirect — with
`-X POST` (curl then posts again) and without it, with the jar. The Chrome line starts headless Chrome with a profile made fresh under
`.harness/chrome`, sealed (a dead proxy at `127.0.0.1:9`, every host name unresolvable but 127.0.0.1), its DevTools protocol on
`127.0.0.1:19539`, a NetLog; `cdp.mjs` opens the dashboard in a new tab, or the form, fills it and sends it with its own button, prints
Chrome's cookie store, or closes Chrome; `net.py` reads Chrome's record of a visit's documents, `netlog.py` the NetLog. The second Chrome line, the second form line and the second `net.py` line are G's (`browser`): Chrome's resolver maps one name, `tiffin.test`, to 127.0.0.1 and the proxy is bypassed for that name alone (every other name still unresolvable, every other request still to the dead proxy), the form is asked for at that name, and `net.py` reads the visit's documents at that name (its third argument; 127.0.0.1 unless named). Every other request
is one of those with its port (`u`), its form body (`fd`) or its address (`lq`: a redirect's `Location`, quoted) changed, or the anchor's
own form line with its port.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script makes the eight other captures, each checked against `receipts.md5`, then stops where the
native build would start (exit 1).

## The browser

The `browser` capture needs **Chrome** (`CHROME=` at the top of `receipts.sh`) and **node 22 or later** (its built-in WebSocket drives
Chrome's DevTools protocol; nothing is installed). Both are optional: without them every curl capture runs and is checked, and the
script stops at the browser step with exit 2, naming this section — before the native build. Each of the four visitors is a Chrome of
its own: started with a profile made fresh under `.harness/` (never a user profile; the capture says it did not exist), sealed to
127.0.0.1, stopped by its pid — never by its name (the author's own Chrome runs beside it, untouched) — and its profile removed, so its
cookies die with it. Within one visitor every tab shares the cookie store: `open` and `form` each use a new tab. **Chrome auto-updates.**
Its version is printed to the terminal only, and masked in every capture (`User-Agent`'s `Chrome/<version>`, `sec-ch-ua`'s brand list
whole), so a new Chrome that behaves the same keeps the hash; one that sends another header or keeps cookies differently changes it, and
`cap()` dies: read the diff, then publish the new hash with the version in this README. Chrome's own record is its DevTools protocol's
network events (`net.py`: each document hop, its status and `Location`, the `Set-Cookie` headers Chrome received —
`responseReceivedExtraInfo`, matched to the hop by status — a form's body, every header Chrome put on the wire) and its cookie store
(`Storage.getCookies`); no developer-tools panel is filmed or used. Every browser claim has a second witness, the server's: `Dump` (every
request and answer, whole) and `Sessions` (each session Tomcat made). Whether the id Chrome keeps is the one the server set, sent back,
or put in a `Location` is compared before the mask and printed as yes or no.

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s4/` alone (5,890 files) and re-seeded so before each run of record. **Nothing was downloaded**
for this unit: every build said `offline: yes`, the native plugin read its metadata repository from `.m2-demo`, and every native build
log holds 0 lines of the plugin's own download. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `after/`'s `mvn
-B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; DevTools' jar, which no build fetches, is
then fetched by name (`dependency:get`, offline first). **Docker:** no pull — `docker build` prints its `load metadata` line and the base
image's digest, and `its lines that say pull: 0`. The image (`tiffinbox-session:1.0.0`) and the container (`tiffinbox-session`) are this
script's own names, checked absent first and removed on every exit. **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed; a session's id — never printed either

The demo token — `TOKEN=` at the top of `receipts.sh`, 30 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored), mounted read-only into the container, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's
standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that
served, the container's log, every file this unit ships, the binary's bytes, every blob of the image (`docker save`) and every
`SESSIONS.ser` a run wrote: 0 everywhere. The token is never put in a session. The header's name is counted too: 0 in every log.
`Dump` prints every request's headers whole and passes POST /shutdown through unprinted. The exercise makes a token of its own (`openssl
rand -hex 16`), counted 0 times in its own log and never printed. **A session's id is a key to that session** (R.18): it is masked in
every line of every capture — `JSESSIONID=<id>`, `;jsessionid=<id>` — the exercise prints it as `<id>` itself, and a last check refuses a
capture with any run of 32 capital hex digits or an unmasked `JSESSIONID=`/`jsessionid=`. `SESSIONS.ser` (DevTools' persistent sessions,
`persistent`) holds each session's id and its attributes: it is written to `.harness/after/sessions`, searched, never printed, deleted
after each run and in the trap, and git-ignored with the rest of `.harness/`.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1), and a last check refuses
any capture's java line without them; the harness's `Keys` prints the JVM's locale (`en_US`). No capture here prints a message a locale
words; the pages' `Content-Language: en-US` is the JVM's (no request names a language but Chrome's `en-US,en;q=0.9`, `--lang=en-US`).
The binary's line passes no locale option.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`); `before` — the link to `../c6-unit23/after`. `.harness/before`,
  `.harness/after` — the two trees, copied, each with a config tree, built and extracted; `.harness/after/sessions` — DevTools' session
  file, removed after each run; `.harness/nat` — after/'s native build, and `.harness/natb` — the previous tree built with the native
  profile, for its AOT metadata (`forms`); `.harness/hc` — the harness's classes; `.harness/jar` — curl's cookie jar; `.harness/chrome` —
  Chrome's profile, made fresh, removed after each visitor and on every exit; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources`:
  `Dump` — the serving lesson's, byte for byte: every request but Actuator's, POST /shutdown, `/css/` and `/favicon.ico` printed whole,
  then its status, every header a filter can read (`Set-Cookie` and `Location` among them; a Date's value not printed) and the bytes of
  body. `Sessions` (new) — a session listener bean: one line when Tomcat creates a session, one when it destroys one; no id. `Visits`
  (new) — `GET /probe/visits`: takes the request's session, counts the visit in it, answers the count, `isNew`, `maxInactiveSeconds` and
  the servlet context's tracking modes, effective and default. `Keys` — the serving lesson's, byte for byte (it prints
  `server.servlet.session.persistent` among its five). `Trace` — the CORS lesson's, byte for byte. `harness/cdp.mjs` and `net.py` (this
  unit's: `cookies` is new; `net.py` adds each hop's `Set-Cookie`), `netlog.py` and `shutdown.sh` (the CORS lesson's, byte for byte).
- **Ports** (brief ⚑1, 19530-19539): after/'s jar 19530 · the previous tree 19531 · a run with one key changed 19532 · DevTools 19533 · the
  image 19534 · the AOT jar 19535 · the binary 19536 · the browser's TiffinBox 19537 · the exercise 19538 · Chrome's DevTools port 19539.
  All ten, 18425, 8080 and 35729 are checked free first; a run that listens on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user, a request thread's number, Chrome's version, a session's id** (`gsub()`, literals escaped),
   in every line: the demo token → `[masked: the 30-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the
   folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`; `tomcat-handler-<digits>` → `tomcat-handler-<n>`;
   `Chrome/<digits>` → `Chrome/<version>`; a `sec-ch-ua:` value, whole → `(its brands and their versions: masked)`; **The platform** (RED S4 #381): the User-Agent's first brackets → `Mozilla/5.0 (<platform masked>)` and
   `sec-ch-ua-platform`'s value → `(<platform masked>)` — a viewer's Chrome on Linux or Windows sends other words there, so they never
   reach a hash; the terminal prints them instead (`Chrome … on Darwin arm64`); `JSESSIONID=<hex>` →
   `JSESSIONID=<id>`, `jsessionid=<hex>` → `jsessionid=<id>`. A last check fails if any capture holds an absolute path, the GraalVM's
   folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a date, a thread number, a stack frame, a whole HTML
   page, a Chrome version, the platform (`Macintosh`, `Mac OS X`, `Windows NT`, `X11;`, `Linux x86`, a quoted `sec-ch-ua-platform`), a session id, a `sha256:` ID other than the base image's digest, `:8080` or `:35729`, a carriage return, a java
   line without its locale, or a command with a URL that is not `127.0.0.1`'s.
2. **Headers** (`hall`): each answer's status line and every header, whole, in the order they came, on one line — under `curl -L`, one
   line per answer; a `Date` header's value → `(the time - not printed)`. `hv` reads one header's value, `none` when absent. **`ids`**
   says whether the last answer's `Set-Cookie` and `Location` carry a session id and whether it is the same one (read before the mask).
3. **Bodies** (`pagef`, `bodyf`): a page as its `<title>`, its line and byte counts, its notes (each `<p class="note">` line, whole), its
   table's first column and how many of its links carry `;jsessionid=`; a JSON answer as its bytes, the timestamp masked; no file → `no file
   - curl wrote none`, an empty one → `none (0 bytes)` (the files are removed before each request, R.119). **curl's cookie jar** (`jarf`):
   each cookie's fields as curl's own file holds them. Each filter is checked on planted inputs before any capture.
4. **Log lines** (`logl`, `recs`): matched by the log's own line shape (R.120); printed from their logger on.
5. **The harness's lines** (`hk`): printed in the order they ran, numbered from 1 for each visit or JVM; a falling running number stops
   the run. **The server's record of one request** (`srec`): the requests `Dump` printed, the `Set-Cookie` headers among their answers,
   the sessions `Sessions` saw created — counted.
6. **Chrome's record** (`net.py`), **its cookie store** (`cdp.mjs cookies`) and the **NetLog** (`netlog.py`): as "The browser" says.
7. **`SESSIONS.ser`** (`sfiles`): listed, searched for the token, the attribute's name and the jar's session id — never printed.
8. **Spring's AOT metadata** (`aotcmp`), **the native build's lines**, **docker build's lines**, **inside the container** and **on this
   Mac**: as the serving lesson's receipts declare them; `aotcmp` names new entries whose type says `tiffinbox`, `Flash`, `Redirect` or
   `Session`.
9. **A′ against A** and **C′ against C** (`asame`): the blocks, their labels aside, masked, compared line for line in the capture itself.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the exercise's
shell (`$xpid`, with every process under it) and Chrome (`$cpid`, with every process under it — `killtree`), sweeps its own process group
for any TiffinBox JVM, binary, Maven or `native-image` left and every process started with this unit's own Chrome profile, removes the
container and the image, deletes Chrome's profile, the session folder (`SESSIONS.ser`) and the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script, its checks or the exercise is bare
(a check refuses one).

**Measured** on the script as committed (2026-10-23), started as a terminal starts its foreground job (SIGINT at its default, a process
group of its own — from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`), SIGINT to the
group three times: **during a capture's JVM** (`cookie`, TiffinBox listening on 19531; 4 processes in the group), **during Chrome**
(`browser`, this unit's Chrome and its helpers running — 15 processes in the group, 10 of them Chrome's), and **during the native build**
(`forms`, native-image's driver and builder running — 5 processes in the group). Each time: **exit 130** within 1 s; 5 s later 0
processes in the group, 0 TiffinBox JVMs, binaries or native-image builders anywhere, 0 Chrome processes with this unit's profile and the
profile folder gone; 19530-19539, 8080, 18425 and 35729 free; no `tiffinbox-session` container or image; no `.r-lock`; no unfinished
capture run; no session folder; the published captures unchanged (md5 of all nine, before and after); the author's own Chrome — 30
processes — the same before and after. (One attempt at the native-build interrupt waited for a process name the builder does not carry,
and the run it watched ran to its end instead: exit 0, all 9 = published — a third run of record under /bin/bash 3.2.)

## 1 · change — the flash, the note, one key

The previous tree and after/, copied and built (offline), their jars extracted; the harness compiled; the files that differ; the three diffs whole; where the key sits in `application.yaml`; Boot's metadata for the session's keys; the jars' libraries.

`.r-change.out` · md5 `d3ca321c40671555a45ec3c1c2f72cff` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
the two jars extracted (the README's line) - the class path the harness runs on:
$ cd .harness/before && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against after/'s own libraries - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Sessions.java harness/probe/web/Trace.java harness/probe/web/Visits.java
  exit 0 · its classes: probe/web/Dump$Tee$1.class probe/web/Dump$Tee.class probe/web/Dump.class probe/web/Keys.class probe/web/Sessions.class probe/web/Trace.class probe/web/Visits.class
the files that differ, and the files only one tree has:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/DashboardPage.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/DashboardPage.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  Files .harness/before/tiffinbox-web/src/main/resources/templates/dashboard.html and .harness/after/tiffinbox-web/src/main/resources/templates/dashboard.html differ
  after/'s files: 33 · byte for byte the previous tree's: 29 · new: 0 · those that differ: 4
  tiffinbox-web/src/main/java/com/tiffinbox/web/DashboardPage.java: 100 lines -> 107
  its diff (diff -U0, its file names cut) - hunks: 4 · lines out: 2 · in: 9 - whole:
    @@ -17,0 +18 @@
    +import org.springframework.web.servlet.mvc.support.RedirectAttributes;
    @@ -37 +38,5 @@
    - *     redirect-after-POST: the browser asks for the page with a GET, so a reload never sends the form again. Every other
    + *     redirect-after-POST: the browser asks for the page with a GET, so a reload never sends the form again. The redirect
    + *     carries a note: a flash attribute ("added", the customer's name), which Spring MVC keeps in the client's session until
    + *     the redirect's GET /dashboard has read it, then drops - the page shows "... added" once. Keeping it is what makes the
    + *     session: the answer sets the session cookie, JSESSIONID, and only the cookie carries the session's id, never the
    + *     address (server.servlet.session.tracking-modes: cookie, application.yaml). Every other
    @@ -85 +90,2 @@
    -    String add(@Valid @ModelAttribute("customer") Customer customer, BindingResult errors) throws SQLException {
    +    String add(@Valid @ModelAttribute("customer") Customer customer, BindingResult errors, RedirectAttributes flash)
    +            throws SQLException {
    @@ -97,0 +104 @@
    +        flash.addFlashAttribute("added", customer.name());
  tiffinbox-web/src/main/resources/templates/dashboard.html: 15 lines -> 16
  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 1 - whole:
    @@ -6,0 +7 @@
    +  <p class="note" th:if="${added != null}" th:text="${added} + ' added'">x added</p>
  tiffinbox-web/src/main/resources/application.yaml: 122 lines -> 128
  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 6 - whole:
    @@ -21,0 +22,6 @@
    +  # Course 6: a session's id travels in its cookie, JSESSIONID, and nowhere else. Tomcat's default, cookie and url, also
    +  # writes it into the address of a redirect to a client that sent no cookie yet (/dashboard;jsessionid=...) - an address
    +  # a copied link keeps, and so does every link on that page. Above the "---": below it, only the rush profile would keep it out.
    +  servlet:
    +    session:
    +      tracking-modes: cookie
  where the key sits in after/'s application.yaml (line numbers; the first document ends at the first ---):
    server: line 19 · servlet: line 25 · session: line 26 · tracking-modes: line 27 · the first ---: line 121 · lines in the first document at the first column that say server: 1
  README.md - the anchor's README: lines added 52, removed 2 - its new section and the history notes the change made false (not shown)
  Boot's own metadata for the session's keys (spring-boot-web-server-4.1.1.jar, META-INF/spring-configuration-metadata.json):
  server.servlet.session.tracking-modes - type Session$SessionTrackingMode> · default null · Session tracking modes.
  server.servlet.session.timeout - type Duration · default "30m" · Session timeout. If a duration suffix is not specified, seconds will be used.
  server.servlet.session.persistent - type Boolean · default false · Whether to persist session data between restarts.
  server.servlet.session.store-dir - type File · default null · Directory used to store session data.
  server.servlet.session.cookie.http-only - type Boolean · default null · Whether to use "HttpOnly" cookies for the cookie.
  server.servlet.session.cookie.secure - type Boolean · default null · Whether to always mark the cookie as secure.
  server.servlet.session.cookie.same-site - type Cookie$SameSite · default null · SameSite setting for the cookie.
the executable jar's BOOT-INF/lib: 61 jars -> 61 · the same names: yes · Spring MVC's among them: spring-webmvc-7.0.9.jar
```

## 2 · cookie — the seven; what makes a session

The seven on both trees, each on a fresh JVM, line for line, and once more with the harness joined — no `Set-Cookie`, no session (`Dump`, `Sessions`); then, with the harness, the form's POST on the previous tree (no session) and on after/ (the session's cookie), the routes that make none, `Visits` without a cookie and twice with curl's jar, the jar's own line, and the tracking modes Tomcat reports.

`.r-cookie.out` · md5 `4610656da5e961d0c6ec198737b08015` · 3 of 3

```
the seven - the previous tree, the README's run line, port 19531, a fresh JVM:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19531
  listens on: 127.0.0.1:19531 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19531/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19531 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - after/, the README's run line, port 19530, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the previous tree's seven against after/'s, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
the seven once more - after/, the harness line (Dump, Sessions and Visits joined), port 19530, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19530 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the same seven as the README's run line's, byte for byte: yes
  the server's record since: requests Dump printed 5 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
what makes a session - the previous tree, the harness line, port 19531:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19531 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits
  listens on: 127.0.0.1:19531 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19531/actuator/health/readiness
  {"status":"UP"} 200
the form's POST (curl's --data: Content-Type application/x-www-form-urlencoded, a form's own type) - this unit's line:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19531/customers
  curl's line: 302 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Location: http://127.0.0.1:19531/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
  the session id in its Set-Cookie: none · in its Location: none · the same id: no
the harness's Visits, no cookie sent:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19531/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 122 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE","URL"],"defaultTrackingModes":["COOKIE","URL"]}
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 1 · sessions Tomcat created (Sessions) 1
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19531 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19531 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
what makes a session - after/, the harness line, port 19530:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19530 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
the customers, the dashboard page and the form page - no cookie sent:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19530/customers
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 282 · Date: (the time - not printed)
  body: [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 23 lines, 962 bytes - not shown but · its notes: none · its table's first column: Meera Priya Ravi Sunil · its links that carry a session id: 0
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Add a customer · TiffinBox</title> · 21 lines, 839 bytes - not shown but · its notes: none · its table's first column: no table · its links that carry a session id: 0
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
the form's POST - this unit's line:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 302 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 1 · sessions Tomcat created (Sessions) 1
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
the harness's Visits, no cookie sent:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19530/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 1 · sessions Tomcat created (Sessions) 1
the harness's Visits twice with curl's cookie jar - it keeps what Set-Cookie gives and sends it back (this unit's line):
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19530/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 1 · sessions Tomcat created (Sessions) 1
  curl's cookie jar: 1 cookie
    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19530/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":2,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  the server's record since: requests Dump printed 1 · Set-Cookie headers among their answers 0 · sessions Tomcat created (Sessions) 0
  curl's cookie jar: 1 cookie
    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · flash — the note across the redirect

after/ on the README's run line: the form's POST with curl's jar, the dashboard twice (the note, then none); without the jar (the customer stored, no note); a refused form and a JSON POST (no cookie); `curl -L -X POST` (it posts again: 405) and `curl -L` with the jar (the note).

`.r-flash.out` · md5 `15b5f967cfe6429cc508e70c2aafcdbf` · 3 of 3

```
after/, the README's run line, port 19530 - curl with a cookie jar, as a browser keeps its cookies (this unit's lines):
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 302 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
  curl's cookie jar: 1 cookie
    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>
the address it gave - the dashboard, with the jar:
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1066 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
the dashboard again, with the jar:
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
without the jar - the same POST for another customer, then the dashboard with no cookie:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Om&mealsPerDay=1&pricePerMeal=100&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 302 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 25 lines, 1108 bytes - not shown but · its notes: none · its table's first column: Lata Meera Om Priya Ravi Sunil · its links that carry a session id: 0
a form the rules refuse, and a JSON POST - no redirect, no note:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=X' http://127.0.0.1:19530/customers
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Add a customer · TiffinBox</title> · 21 lines, 1065 bytes - not shown but · its notes: none · its table's first column: no table · its links that carry a session id: 0
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Zoe","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' http://127.0.0.1:19530/customers
  curl's line: 201 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 201 · Location: http://127.0.0.1:19530/customers/Zoe · Content-Type: application/json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"name":"Zoe","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}
curl -L follows the redirect - with -X POST it posts again to the address it is given:
$ curl -s -L -X POST -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Asha&mealsPerDay=1&pricePerMeal=100&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 405 · WARN lines it added: 1 · ERROR lines: 0
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  HTTP/1.1 405 · Allow: GET · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"detail":"Method 'POST' is not supported.","instance":"/dashboard","status":405,"title":"Method Not Allowed"}
    WARN o.s.web.servlet.PageNotFound: Request method 'POST' is not supported
      its stack frames: 0, its other lines: 0 - none shown
and without -X, with the jar - a GET, as a browser follows a 302:
$ rm -f .harness/jar
  exit 0
$ curl -s -L -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' --data 'name=Dev&mealsPerDay=1&pricePerMeal=100&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 28 lines, 1357 bytes - not shown but · its notes: <p class="note">Dev added</p> · its table's first column: Asha Dev Lata Meera Om Priya Ravi Sunil Zoe · its links that carry a session id: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · tracking — A/B/A′, the id in the address

A after/ as shipped, B `--server.servlet.session.tracking-modes=cookie,url` (Tomcat's default) for the run, A′ A again: the anchor's own form line, whole, then the address it gave asked for twice by a client that keeps no cookie.

`.r-tracking.out` · md5 `9950175fd8abbd4a1d79242a201e137f` · 3 of 3

```
A - after/ as shipped (tracking-modes: cookie), the README's run line, port 19530 - the anchor's own form line:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D - -o /dev/null --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  the same address once more:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - Tomcat's default for this run, cookie and url (this unit's line), port 19530:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530 --server.servlet.session.tracking-modes=cookie,url
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D - -o /dev/null --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard;jsessionid=<id> · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  the session id in its Set-Cookie: present · in its Location: present · the same id: yes
  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard;jsessionid=<id>'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1198 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 3
  the same address once more:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard;jsessionid=<id>'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1168 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 3
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19530:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D - -o /dev/null --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  the same address once more:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19530/dashboard'
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 5 · flags — the attributes Course 10 decides

One run each with the harness: `same-site=strict`, `secure=true`, `timeout=90s` — the cookie's attributes and the session's idle time.

`.r-flags.out` · md5 `25cea182335da92a21fc9d42cbda9742` · 3 of 3

```
SameSite=Strict - after/, the harness line with one key (this unit's line), port 19532:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19532 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.same-site=strict
  listens on: 127.0.0.1:19532 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19532/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19532/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly; SameSite=Strict · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19532 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19532 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
Secure - the harness line with one key (this unit's line), port 19532:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19532 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.secure=true
  listens on: 127.0.0.1:19532 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19532/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19532/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; Secure; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19532 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19532 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a timeout of 90 seconds - the harness line with one key (this unit's line), port 19532:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19532 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.timeout=90s
  listens on: 127.0.0.1:19532 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19532/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19532/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 114 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":60,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19532 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19532 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · persistent — C (labelled), DevTools' session default

DevTools on the class path (`Keys` reads its property source): two visits with curl's jar, POST /shutdown, the session folder, a second JVM, a third visit; then with persistence off; C′ C again.

`.r-persistent.out` · md5 `5120b0976bcba28874c429a984eb8b61` · 3 of 3

```
the keys - Boot's metadata (spring-boot-web-server-4.1.1.jar):
  server.servlet.session.persistent - type Boolean · default false · Whether to persist session data between restarts.
  server.servlet.session.store-dir - type File · default null · Directory used to store session data.
C (labelled) - DevTools on after/: its extracted jar with DevTools' jar (from $M2) and the harness on its class path, Live Reload off, Keys and Visits joined, the session folder named in the run's own folder (this unit's line), port 19533:
$ rm -f .harness/jar
  exit 0
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions"
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
  the harness's lines it printed, in order: 18
     1 Keys the JVM's locale: en_US
     2 Keys the property source devtools: 10 keys
     3 Keys   server.servlet.jsp.init-parameters.development = true
     4 Keys   server.servlet.session.persistent = true
     5 Keys   spring.mvc.log-resolved-exception = true
     6 Keys   spring.template.provider.cache = false
     7 Keys   spring.thymeleaf.cache = false
     8 Keys   spring.web.error.include-binding-errors = always
     9 Keys   spring.web.error.include-message = always
    10 Keys   spring.web.error.include-stacktrace = always
    11 Keys   spring.web.resources.cache.period = 0
    12 Keys   spring.web.resources.chain.cache = false
    13 Keys property sources whose name says devtools: 1
    14 Keys the environment's spring.thymeleaf.cache: false
    15 Keys the environment's spring.template.provider.cache: false
    16 Keys the environment's spring.web.resources.cache.period: 365d
    17 Keys the environment's spring.web.resources.chain.cache: false
    18 Keys the environment's server.servlet.session.persistent: true
  listening on 35729 (Live Reload) now: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":2,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  SESSIONS.ser
  SESSIONS.ser, searched (never printed): the demo token in it 0 times · the attribute's name, visits: yes · the session id curl's jar holds: yes
  a second JVM, the same line, port 19533:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions"
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":3,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  SESSIONS.ser
  SESSIONS.ser, searched (never printed): the demo token in it 0 times · the attribute's name, visits: yes · the session id curl's jar holds: yes
persistence off for this run (this unit's line), port 19533:
$ rm -f .harness/jar
  exit 0
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions" --server.servlet.session.persistent=false
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
  the harness's lines it printed, in order: 18
     1 Keys the JVM's locale: en_US
     2 Keys the property source devtools: 10 keys
     3 Keys   server.servlet.jsp.init-parameters.development = true
     4 Keys   server.servlet.session.persistent = true
     5 Keys   spring.mvc.log-resolved-exception = true
     6 Keys   spring.template.provider.cache = false
     7 Keys   spring.thymeleaf.cache = false
     8 Keys   spring.web.error.include-binding-errors = always
     9 Keys   spring.web.error.include-message = always
    10 Keys   spring.web.error.include-stacktrace = always
    11 Keys   spring.web.resources.cache.period = 0
    12 Keys   spring.web.resources.chain.cache = false
    13 Keys property sources whose name says devtools: 1
    14 Keys the environment's spring.thymeleaf.cache: false
    15 Keys the environment's spring.template.provider.cache: false
    16 Keys the environment's spring.web.resources.cache.period: 365d
    17 Keys the environment's spring.web.resources.chain.cache: false
    18 Keys the environment's server.servlet.session.persistent: false
  listening on 35729 (Live Reload) now: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":2,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  no such folder
  a second JVM, the same line, port 19533:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions" --server.servlet.session.persistent=false
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  no such folder
C' - C again, fresh JVMs, port 19533:
$ rm -f .harness/jar
  exit 0
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions"
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
  the harness's lines it printed, in order: 18
     1 Keys the JVM's locale: en_US
     2 Keys the property source devtools: 10 keys
     3 Keys   server.servlet.jsp.init-parameters.development = true
     4 Keys   server.servlet.session.persistent = true
     5 Keys   spring.mvc.log-resolved-exception = true
     6 Keys   spring.template.provider.cache = false
     7 Keys   spring.thymeleaf.cache = false
     8 Keys   spring.web.error.include-binding-errors = always
     9 Keys   spring.web.error.include-message = always
    10 Keys   spring.web.error.include-stacktrace = always
    11 Keys   spring.web.resources.cache.period = 0
    12 Keys   spring.web.resources.chain.cache = false
    13 Keys property sources whose name says devtools: 1
    14 Keys the environment's spring.thymeleaf.cache: false
    15 Keys the environment's spring.template.provider.cache: false
    16 Keys the environment's spring.web.resources.cache.period: 365d
    17 Keys the environment's spring.web.resources.chain.cache: false
    18 Keys the environment's server.servlet.session.persistent: true
  listening on 35729 (Live Reload) now: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)
  body: {"visits":1,"new":true,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":2,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  SESSIONS.ser
  SESSIONS.ser, searched (never printed): the demo token in it 0 times · the attribute's name, visits: yes · the session id curl's jar holds: yes
  a second JVM, the same line, port 19533:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19533 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir="$PWD/sessions"
  listens on: 127.0.0.1:19533 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19533/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' http://127.0.0.1:19533/probe/visits
  curl's line: 200 · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)
  body: {"visits":3,"new":false,"maxInactiveSeconds":1800,"trackingModes":["COOKIE"],"defaultTrackingModes":["COOKIE","URL"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19533 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19533 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ ls .harness/after/sessions
  SESSIONS.ser
  SESSIONS.ser, searched (never printed): the demo token in it 0 times · the attribute's name, visits: yes · the session id curl's jar holds: yes
C' against C, its label aside, line for line the same: yes
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s commands, then `exercise/solution/SOLUTION.md`'s, read from the files and run as written in one `env -i` `/bin/bash` shell started in this folder.

`.r-exercise.out` · md5 `26bdb3d3fec28afede73683955a23da7` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ printf 'server.servlet.session.tracking-modes: cookie,url\n' > .harness/mine/after/tiffinbox-local.yaml
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19538 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19538/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · %{redirect_url}' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19538/customers | sed -E 's/jsessionid=[0-9A-F]+/jsessionid=<id>/'); ../../../harness/shutdown.sh 19538 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the redirect: $s")
  exit 0 · what they printed:
    the redirect: 302 · http://127.0.0.1:19538/dashboard;jsessionid=<id>
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19538 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ f=.harness/mine/after/tiffinbox-local.yaml && sed 's/tracking-modes: cookie,url/tracking-modes: cookie/' "$f" > "$f.new" && mv "$f.new" "$f"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19538 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19538/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · %{redirect_url}' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19538/customers | sed -E 's/jsessionid=[0-9A-F]+/jsessionid=<id>/'); ../../../harness/shutdown.sh 19538 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the redirect: $s")
  exit 0 · what they printed:
    the redirect: 302 · http://127.0.0.1:19538/dashboard
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19538 now: 0
  the copy's tiffinbox-local.yaml: server.servlet.session.tracking-modes: cookie
```

## 8 · browser — a real browser, two witnesses for every claim

Headless Chrome, a fresh sealed profile per visitor, `Dump` and `Sessions` on the server: 1 after/ — the dashboard, the form typed and sent, the cookie store, the dashboard again; C (labelled) cookie,url — the id in Chrome's address; F (labelled) `Secure` and `SameSite=Strict` over plain http to 127.0.0.1. **G (labelled) — the control for F** (RED S4 #384): the same server and line as F, a new visitor whose Chrome reaches it as `tiffin.test` — its resolver maps that one name to 127.0.0.1 and its proxy is bypassed for that name alone (`--proxy-bypass-list=tiffin.test`; every other name still unresolvable, the NetLog still 127.0.0.1 only). The same Set-Cookie arrives (`Secure; HttpOnly; SameSite=Strict`), and Chrome refuses it — `a cookie Chrome refused: SecureOnly` — so its store holds 0 cookies, the redirected GET sends none (the server's record) and the page shows no note. Same address, another origin: Chrome's exception for plain http is for a loopback origin (127.0.0.1), not for the address.

`.r-browser.out` · md5 `75c9f3a272cc7b0286a1766c597da781` · 3 of 3

```
1 after/ - the harness line (Dump, Sessions and Visits joined: the server's record of every request, whole); Chrome headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19539:
  TiffinBox - after/, the harness line, port 19537:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19537 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits
  listens on: 127.0.0.1:19537 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19537/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19539 · loopback only: yes
visit 1 - the dashboard's address, typed into a new tab:
$ node harness/cdp.mjs 19539 open http://127.0.0.1:19537/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its notes: none · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 1
    GET /dashboard - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19537
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 23
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /dashboard
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 962 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 2 - the form's address, typed into a new tab; the form filled in and sent with its own button:
$ node harness/cdp.mjs 19539 form http://127.0.0.1:19537/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its notes: Kiran added · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3
    GET /customers/new - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19537
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19537/dashboard
      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; HttpOnly
      the form's body, as Chrome sent it: name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG
      as Chrome sent it, its 18 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 54
        Content-Type: application/x-www-form-urlencoded
        Host: 127.0.0.1:19537
        Origin: http://127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    GET /dashboard - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 16 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Cookie: JSESSIONID=<id>
        Host: 127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 72
       1 Dump            > GET /customers/new
       2 Dump            >   Host: 127.0.0.1:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /customers/new
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 839 bytes
      24 Dump            > POST /customers
      25 Dump            >   Host: 127.0.0.1:19537
      26 Dump            >   Connection: keep-alive
      27 Dump            >   Content-Length: 54
      28 Dump            >   Cache-Control: max-age=0
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   sec-ch-ua-platform: (<platform masked>)
      32 Dump            >   Upgrade-Insecure-Requests: 1
      33 Dump            >   Content-Type: application/x-www-form-urlencoded
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   Origin: http://127.0.0.1:19537
      36 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      37 Dump            >   Sec-Fetch-Site: same-origin
      38 Dump            >   Sec-Fetch-Mode: navigate
      39 Dump            >   Sec-Fetch-Dest: document
      40 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      41 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      42 Dump            >   Accept-Language: en-US,en;q=0.9
      43 Sessions        a session was created
      44 Dump            < 302 POST /customers
      45 Dump            <   Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly
      46 Dump            <   Location: http://127.0.0.1:19537/dashboard
      47 Dump            <   body: 0 bytes
      48 Dump            > GET /dashboard
      49 Dump            >   Host: 127.0.0.1:19537
      50 Dump            >   Connection: keep-alive
      51 Dump            >   Cache-Control: max-age=0
      52 Dump            >   Upgrade-Insecure-Requests: 1
      53 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      54 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      55 Dump            >   Sec-Fetch-Site: same-origin
      56 Dump            >   Sec-Fetch-Mode: navigate
      57 Dump            >   Sec-Fetch-Dest: document
      58 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      59 Dump            >   sec-ch-ua-mobile: ?0
      60 Dump            >   sec-ch-ua-platform: (<platform masked>)
      61 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      62 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      63 Dump            >   Accept-Language: en-US,en;q=0.9
      64 Dump            >   Cookie: JSESSIONID=<id>
      65 Dump            < 200 GET /dashboard
      66 Dump            <   Content-Type: text/html;charset=UTF-8
      67 Dump            <   Content-Language: en-US
      68 Dump            <   Transfer-Encoding: chunked
      69 Dump            <   Date: (the time: not printed)
      70 Dump            <   Keep-Alive: timeout=60
      71 Dump            <   Connection: keep-alive
      72 Dump            <   body: 1068 bytes
    WARN lines they added: 0 · ERROR lines: 0
the cookie store, after visit 2:
$ node harness/cdp.mjs 19539 cookies
  Chrome's cookie store: 1 cookie
    JSESSIONID=<id> · domain 127.0.0.1 · path / · httpOnly true · secure false · sameSite (none) · session true
  compared: the id Chrome keeps is the one the server's record shows set: yes · the one Chrome sent back last: yes · a redirect's Location in the server's record carried an id: no
visit 3 - the dashboard's address, typed into a new tab again:
$ node harness/cdp.mjs 19539 open http://127.0.0.1:19537/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its notes: none · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 1
    GET /dashboard - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 15 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Cookie: JSESSIONID=<id>
        Host: 127.0.0.1:19537
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 24
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            >   Cookie: JSESSIONID=<id>
      17 Dump            < 200 GET /dashboard
      18 Dump            <   Content-Type: text/html;charset=UTF-8
      19 Dump            <   Content-Language: en-US
      20 Dump            <   Transfer-Encoding: chunked
      21 Dump            <   Date: (the time: not printed)
      22 Dump            <   Keep-Alive: timeout=60
      23 Dump            <   Connection: keep-alive
      24 Dump            <   body: 1037 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19539 close
  Chrome exit 0 · listening on 19539 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19537
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19537 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19537 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19537 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - Tomcat's default, cookie and url (this unit's line), a new visitor whose first request to make a session is the form's POST:
  TiffinBox - after/, cookie and url, port 19537:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19537 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.tracking-modes=cookie,url
  listens on: 127.0.0.1:19537 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19537/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19539 · loopback only: yes
visit 1 - the form's address, typed into a new tab; the form filled in and sent with its own button:
$ node harness/cdp.mjs 19539 form http://127.0.0.1:19537/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard;jsessionid=<id> · its notes: Kiran added · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3
    GET /customers/new - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19537
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19537/dashboard;jsessionid=<id>
      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; HttpOnly
      the form's body, as Chrome sent it: name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG
      as Chrome sent it, its 18 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 54
        Content-Type: application/x-www-form-urlencoded
        Host: 127.0.0.1:19537
        Origin: http://127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    GET /dashboard;jsessionid=<id> - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 16 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Cookie: JSESSIONID=<id>
        Host: 127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 72
       1 Dump            > GET /customers/new
       2 Dump            >   Host: 127.0.0.1:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /customers/new
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 839 bytes
      24 Dump            > POST /customers
      25 Dump            >   Host: 127.0.0.1:19537
      26 Dump            >   Connection: keep-alive
      27 Dump            >   Content-Length: 54
      28 Dump            >   Cache-Control: max-age=0
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   sec-ch-ua-platform: (<platform masked>)
      32 Dump            >   Upgrade-Insecure-Requests: 1
      33 Dump            >   Content-Type: application/x-www-form-urlencoded
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   Origin: http://127.0.0.1:19537
      36 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      37 Dump            >   Sec-Fetch-Site: same-origin
      38 Dump            >   Sec-Fetch-Mode: navigate
      39 Dump            >   Sec-Fetch-Dest: document
      40 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      41 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      42 Dump            >   Accept-Language: en-US,en;q=0.9
      43 Sessions        a session was created
      44 Dump            < 302 POST /customers
      45 Dump            <   Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly
      46 Dump            <   Location: http://127.0.0.1:19537/dashboard;jsessionid=<id>
      47 Dump            <   body: 0 bytes
      48 Dump            > GET /dashboard;jsessionid=<id>
      49 Dump            >   Host: 127.0.0.1:19537
      50 Dump            >   Connection: keep-alive
      51 Dump            >   Cache-Control: max-age=0
      52 Dump            >   Upgrade-Insecure-Requests: 1
      53 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      54 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      55 Dump            >   Sec-Fetch-Site: same-origin
      56 Dump            >   Sec-Fetch-Mode: navigate
      57 Dump            >   Sec-Fetch-Dest: document
      58 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      59 Dump            >   sec-ch-ua-mobile: ?0
      60 Dump            >   sec-ch-ua-platform: (<platform masked>)
      61 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      62 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      63 Dump            >   Accept-Language: en-US,en;q=0.9
      64 Dump            >   Cookie: JSESSIONID=<id>
      65 Dump            < 200 GET /dashboard;jsessionid=<id>
      66 Dump            <   Content-Type: text/html;charset=UTF-8
      67 Dump            <   Content-Language: en-US
      68 Dump            <   Transfer-Encoding: chunked
      69 Dump            <   Date: (the time: not printed)
      70 Dump            <   Keep-Alive: timeout=60
      71 Dump            <   Connection: keep-alive
      72 Dump            <   body: 1068 bytes
    WARN lines they added: 0 · ERROR lines: 0
the cookie store, after visit 1:
$ node harness/cdp.mjs 19539 cookies
  Chrome's cookie store: 1 cookie
    JSESSIONID=<id> · domain 127.0.0.1 · path / · httpOnly true · secure false · sameSite (none) · session true
  compared: the id Chrome keeps is the one the server's record shows set: yes · the one Chrome sent back last: yes · a redirect's Location in the server's record carried an id: yes · the same id: yes
$ node harness/cdp.mjs 19539 close
  Chrome exit 0 · listening on 19539 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19537
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19537 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19537 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19537 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
F (labelled) - Secure and SameSite=Strict, the attributes Course 10 decides (this unit's line), a new visitor over plain http to 127.0.0.1:
  TiffinBox - after/, Secure and SameSite=Strict, port 19537:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19537 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.secure=true --server.servlet.session.cookie.same-site=strict
  listens on: 127.0.0.1:19537 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19537/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19539 · loopback only: yes
visit 1 - the form's address, typed into a new tab; the form filled in and sent with its own button:
$ node harness/cdp.mjs 19539 form http://127.0.0.1:19537/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its notes: Kiran added · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3
    GET /customers/new - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19537
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19537/dashboard
      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; Secure; HttpOnly; SameSite=Strict
      the form's body, as Chrome sent it: name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG
      as Chrome sent it, its 18 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 54
        Content-Type: application/x-www-form-urlencoded
        Host: 127.0.0.1:19537
        Origin: http://127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    GET /dashboard - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 16 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Cookie: JSESSIONID=<id>
        Host: 127.0.0.1:19537
        Referer: http://127.0.0.1:19537/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 72
       1 Dump            > GET /customers/new
       2 Dump            >   Host: 127.0.0.1:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /customers/new
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 839 bytes
      24 Dump            > POST /customers
      25 Dump            >   Host: 127.0.0.1:19537
      26 Dump            >   Connection: keep-alive
      27 Dump            >   Content-Length: 54
      28 Dump            >   Cache-Control: max-age=0
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   sec-ch-ua-platform: (<platform masked>)
      32 Dump            >   Upgrade-Insecure-Requests: 1
      33 Dump            >   Content-Type: application/x-www-form-urlencoded
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   Origin: http://127.0.0.1:19537
      36 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      37 Dump            >   Sec-Fetch-Site: same-origin
      38 Dump            >   Sec-Fetch-Mode: navigate
      39 Dump            >   Sec-Fetch-Dest: document
      40 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      41 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      42 Dump            >   Accept-Language: en-US,en;q=0.9
      43 Sessions        a session was created
      44 Dump            < 302 POST /customers
      45 Dump            <   Set-Cookie: JSESSIONID=<id>; Path=/; Secure; HttpOnly; SameSite=Strict
      46 Dump            <   Location: http://127.0.0.1:19537/dashboard
      47 Dump            <   body: 0 bytes
      48 Dump            > GET /dashboard
      49 Dump            >   Host: 127.0.0.1:19537
      50 Dump            >   Connection: keep-alive
      51 Dump            >   Cache-Control: max-age=0
      52 Dump            >   Upgrade-Insecure-Requests: 1
      53 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      54 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      55 Dump            >   Sec-Fetch-Site: same-origin
      56 Dump            >   Sec-Fetch-Mode: navigate
      57 Dump            >   Sec-Fetch-Dest: document
      58 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      59 Dump            >   sec-ch-ua-mobile: ?0
      60 Dump            >   sec-ch-ua-platform: (<platform masked>)
      61 Dump            >   Referer: http://127.0.0.1:19537/customers/new
      62 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      63 Dump            >   Accept-Language: en-US,en;q=0.9
      64 Dump            >   Cookie: JSESSIONID=<id>
      65 Dump            < 200 GET /dashboard
      66 Dump            <   Content-Type: text/html;charset=UTF-8
      67 Dump            <   Content-Language: en-US
      68 Dump            <   Transfer-Encoding: chunked
      69 Dump            <   Date: (the time: not printed)
      70 Dump            <   Keep-Alive: timeout=60
      71 Dump            <   Connection: keep-alive
      72 Dump            <   body: 1068 bytes
    WARN lines they added: 0 · ERROR lines: 0
the cookie store, after visit 1:
$ node harness/cdp.mjs 19539 cookies
  Chrome's cookie store: 1 cookie
    JSESSIONID=<id> · domain 127.0.0.1 · path / · httpOnly true · secure true · sameSite Strict · session true
  compared: the id Chrome keeps is the one the server's record shows set: yes · the one Chrome sent back last: yes · a redirect's Location in the server's record carried an id: no
$ node harness/cdp.mjs 19539 close
  Chrome exit 0 · listening on 19539 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19537
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19537 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19537 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19537 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
G (labelled) - the control for F: the same server and line, a new visitor whose Chrome reaches it by a name its resolver maps to 127.0.0.1 (tiffin.test, this unit's line) - the same address over plain http, another origin:
  TiffinBox - after/, Secure and SameSite=Strict, port 19537:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19537 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits --server.servlet.session.cookie.secure=true --server.servlet.session.cookie.same-site=strict
  listens on: 127.0.0.1:19537 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19537/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --proxy-bypass-list=tiffin.test --host-resolver-rules='MAP tiffin.test 127.0.0.1, MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19539 · loopback only: yes
visit 1 - the form's address at that name, typed into a new tab; the form filled in and sent with its own button:
$ node harness/cdp.mjs 19539 form http://tiffin.test:19537/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its notes: none · its links that carry a session id: 0
$ python3 harness/net.py .harness/ev.json 19537 tiffin.test
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3
    GET /customers/new - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 7 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: tiffin.test:19537
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    POST /customers - the answer Chrome got: 302 · Location: http://tiffin.test:19537/dashboard
      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; Secure; HttpOnly; SameSite=Strict
      a cookie Chrome refused: SecureOnly
      the form's body, as Chrome sent it: name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG
      as Chrome sent it, its 12 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 54
        Content-Type: application/x-www-form-urlencoded
        Host: tiffin.test:19537
        Origin: http://tiffin.test:19537
        Referer: http://tiffin.test:19537/customers/new
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    GET /dashboard - the answer Chrome got: 200 text/html
      its Set-Cookie, as Chrome received it: none
      as Chrome sent it, its 9 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Host: tiffin.test:19537
        Referer: http://tiffin.test:19537/customers/new
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 52
       1 Dump            > GET /customers/new
       2 Dump            >   Host: tiffin.test:19537
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Upgrade-Insecure-Requests: 1
       5 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       6 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
       7 Dump            >   Accept-Encoding: gzip, deflate
       8 Dump            >   Accept-Language: en-US,en;q=0.9
       9 Dump            < 200 GET /customers/new
      10 Dump            <   Content-Type: text/html;charset=UTF-8
      11 Dump            <   Content-Language: en-US
      12 Dump            <   Transfer-Encoding: chunked
      13 Dump            <   Date: (the time: not printed)
      14 Dump            <   Keep-Alive: timeout=60
      15 Dump            <   Connection: keep-alive
      16 Dump            <   body: 839 bytes
      17 Dump            > POST /customers
      18 Dump            >   Host: tiffin.test:19537
      19 Dump            >   Connection: keep-alive
      20 Dump            >   Content-Length: 54
      21 Dump            >   Cache-Control: max-age=0
      22 Dump            >   Upgrade-Insecure-Requests: 1
      23 Dump            >   Content-Type: application/x-www-form-urlencoded
      24 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      25 Dump            >   Origin: http://tiffin.test:19537
      26 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      27 Dump            >   Referer: http://tiffin.test:19537/customers/new
      28 Dump            >   Accept-Encoding: gzip, deflate
      29 Dump            >   Accept-Language: en-US,en;q=0.9
      30 Sessions        a session was created
      31 Dump            < 302 POST /customers
      32 Dump            <   Set-Cookie: JSESSIONID=<id>; Path=/; Secure; HttpOnly; SameSite=Strict
      33 Dump            <   Location: http://tiffin.test:19537/dashboard
      34 Dump            <   body: 0 bytes
      35 Dump            > GET /dashboard
      36 Dump            >   Host: tiffin.test:19537
      37 Dump            >   Connection: keep-alive
      38 Dump            >   Cache-Control: max-age=0
      39 Dump            >   Upgrade-Insecure-Requests: 1
      40 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      41 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      42 Dump            >   Referer: http://tiffin.test:19537/customers/new
      43 Dump            >   Accept-Encoding: gzip, deflate
      44 Dump            >   Accept-Language: en-US,en;q=0.9
      45 Dump            < 200 GET /dashboard
      46 Dump            <   Content-Type: text/html;charset=UTF-8
      47 Dump            <   Content-Language: en-US
      48 Dump            <   Transfer-Encoding: chunked
      49 Dump            <   Date: (the time: not printed)
      50 Dump            <   Keep-Alive: timeout=60
      51 Dump            <   Connection: keep-alive
      52 Dump            <   body: 1037 bytes
    WARN lines they added: 0 · ERROR lines: 0
the cookie store, after visit 1:
$ node harness/cdp.mjs 19539 cookies
  Chrome's cookie store: 0 cookies
  compared: the id Chrome keeps is the one the server's record shows set: no · the one Chrome sent back last: no · a redirect's Location in the server's record carried an id: no
$ node harness/cdp.mjs 19539 close
  Chrome exit 0 · listening on 19539 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19537
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19537 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19537 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19537 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 9 · forms — every form keeps the id out of the address (⚑7, R.103)

The native build of after/ (offline); what Spring's AOT step registers against the previous tree; then the jar, the AOT jar, the binary and the image: each one's address and the seven; on a second start the form's first POST with curl's jar and the dashboard twice; on a third, the same POST with `cookie,url` passed at start.

`.r-forms.out` · md5 `f36119eccf205f86b3b5739cf257b562` · 3 of 3

```
the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 203 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Using a deprecated option --enable-http from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Using a deprecated option --enable-https from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Option 'FallbackThreshold' is deprecated and might be removed in a future release: It no longer has any effect, and no replacement is available. Please refer to the GraalVM release notes.
    Warning: Option 'DynamicProxyConfigurationResources' is deprecated and might be removed in a future release: This can be caused by a proxy-config.json file in your META-INF directory. Consider including proxy configuration in the reflection section of reachability-metadata.json instead.. Please refer to the GraalVM release notes.
    [1/8] Initializing...
    [2/8] Performing analysis...
    [3/8] Building universe...
    [4/8] Parsing methods...
    [5/8] Inlining methods...
    [6/8] Compiling methods...
    [7/8] Laying out methods...
    [8/8] Creating image...
    The build process encountered 5 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:
$ cd .harness/natb && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the previous tree, the profile native · offline: yes · exit 0
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 690 -> 690 · types only the previous tree registers: none · only after/: 0 · entries that differ: 1
    only after/, the rest: 0 (not named)
    differs: com.tiffinbox.web.DashboardPage - its methods only before: add(Customer, BindingResult) · only after: add(Customer, BindingResult, RedirectAttributes) · its other keys only before: none · only after: none
  resource entries: 30 -> 30 · only after/: none
1 the jar - .harness/after, the README's run line, port 19530:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19530 (http) with context path '/'
$ $CURLSET 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the form, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1066 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19530/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  this form's answers: the POST 302 · a session id in its address: no · its cookie: JSESSIONID=<id>; Path=/; HttpOnly · notes on the first page: 1 (Lata added) · on the second: 0
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then Tomcat's default, on a third start (this unit's line):
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19530 --server.servlet.session.tracking-modes=cookie,url
  listens on: 127.0.0.1:19530 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19530/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19530/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19530/dashboard;jsessionid=<id> · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: present · the same id: yes
  this form's answer with cookie and url: the POST 302 · a session id in its address: yes · the cookie's: yes
$ harness/shutdown.sh 19530 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19530 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19535:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19535
  listens on: 127.0.0.1:19535 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19535/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19535 (http) with context path '/'
$ $CURLSET 19535 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the form, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19535
  listens on: 127.0.0.1:19535 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19535/actuator/health/readiness
  {"status":"UP"} 200
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19535/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19535/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19535/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1066 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19535/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  this form's answers: the POST 302 · a session id in its address: no · its cookie: JSESSIONID=<id>; Path=/; HttpOnly · notes on the first page: 1 (Lata added) · on the second: 0
$ harness/shutdown.sh 19535 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19535 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then Tomcat's default, on a third start (the README's AOT line and B's option):
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19535 --server.servlet.session.tracking-modes=cookie,url
  listens on: 127.0.0.1:19535 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19535/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19535/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19535/dashboard;jsessionid=<id> · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: present · the same id: yes
  this form's answer with cookie and url: the POST 302 · a session id in its address: yes · the cookie's: yes
$ harness/shutdown.sh 19535 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19535 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19536:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19536
  listens on: 127.0.0.1:19536 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19536/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19536 (http) with context path '/'
$ $CURLSET 19536 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the form, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19536
  listens on: 127.0.0.1:19536 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19536/actuator/health/readiness
  {"status":"UP"} 200
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19536/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19536/dashboard · Content-Language: en · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19536/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1066 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19536/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  this form's answers: the POST 302 · a session id in its address: no · its cookie: JSESSIONID=<id>; Path=/; HttpOnly · notes on the first page: 1 (Lata added) · on the second: 0
$ harness/shutdown.sh 19536 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19536 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then Tomcat's default, on a third start (the README's line and B's option):
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19536 --server.servlet.session.tracking-modes=cookie,url
  listens on: 127.0.0.1:19536 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19536/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19536/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19536/dashboard;jsessionid=<id> · Content-Language: en · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: present · the same id: yes
  this form's answer with cookie and url: the POST 302 · a session id in its address: yes · the cookie's: yes
$ harness/shutdown.sh 19536 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19536 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19534:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-session:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-session:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-session --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19534:18425 tiffinbox-session:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19534/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19534
  on this Mac, listening on port 19534: 127.0.0.1:19534
$ $CURLSET 19534 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-session
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the form, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-session --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19534:18425 tiffinbox-session:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19534/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19534
  on this Mac, listening on port 19534: 127.0.0.1:19534
$ rm -f .harness/jar
  exit 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19534/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19534/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: none · the same id: no
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19534/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1066 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
$ curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19534/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 24 lines, 1036 bytes - not shown but · its notes: none · its table's first column: Lata Meera Priya Ravi Sunil · its links that carry a session id: 0
  this form's answers: the POST 302 · a session id in its address: no · its cookie: JSESSIONID=<id>; Path=/; HttpOnly · notes on the first page: 1 (Lata added) · on the second: 0
$ harness/shutdown.sh 19534 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-session
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
  then Tomcat's default, on a third container (the README's run line and B's option, after the image's name) - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-session --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19534:18425 tiffinbox-session:1.0.0 --server.servlet.session.tracking-modes=cookie,url
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19534/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19534
  on this Mac, listening on port 19534: 127.0.0.1:19534
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19534/customers
  curl's line: 302
  HTTP/1.1 302 · Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly · Location: http://127.0.0.1:19534/dashboard;jsessionid=<id> · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)
  body: none (0 bytes)
  the session id in its Set-Cookie: present · in its Location: present · the same id: yes
  this form's answer with cookie and url: the POST 302 · a session id in its address: yes · the cookie's: yes
$ harness/shutdown.sh 19534 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-session
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
four forms, one tree: the seven (masked) 4 of 4 times 466c20ed7e0d5439cb052f32ce09de1b · the form's POST 302, no session id in its address, the cookie HttpOnly, the note once: 4 of 4 · with cookie and url, the session id in the address, the cookie's: 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
  the locale: options on the binary's and the image's run lines: 0 (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)
```


## Exercise

**Your turn:** the README's redirect carries the session id in its address. Set one key so only the cookie carries it, and post again.
`exercise/README.md` has the commands (copy `after/`, write the copy a `tiffinbox-local.yaml` that sets
`server.servlet.session.tracking-modes: cookie,url`, give the copy a token of its own); its last line, in a subshell, builds the copy
offline, starts it on 19538 from the copy's folder, posts the form with no cookie — a first visit — keeps the status and the redirect's
address (`%{redirect_url}`, a session id in it printed as `<id>`), stops it, waits for its JVM and prints — as shipped — `the redirect: 302
· http://127.0.0.1:19538/dashboard;jsessionid=<id>`. Done is `the redirect: 302 · http://127.0.0.1:19538/dashboard`. Measured answer:
`exercise/solution/SOLUTION.md` (the README's two `export` lines, the line that makes the local file's `cookie,url` `cookie` —
idempotent — and the README's last line again), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 24` section (after unit 23's, before Course 5's README
begins) with the anchor's new line — the form's POST with its answer's headers (`curl -s -D - -o /dev/null --data '…' …/customers`) —
and **two history notes amended in place**, found by grepping the README for `session`, `cookie`, `Set-Cookie`, `redirect`, `302`,
`Location`, `first document`, `line N` and `---` (S2.22, S4.11), each hit read:
- the problem-detail section's "one key in the first document (line 64, above the `---` at 99)", already noted by unit 23 (`---` at
  115) → the key is at line 70 and the `---` at 121 since;
- the static-resource section's "lines 77, 78 and 80, above the `---` at 115" → 83, 84 and 86, the `---` at 121.

Left as they were, and still true (each read): the serving section's form line and its "→ `302`, `Location:
http://127.0.0.1:18431/dashboard`, no body" (still so — now with a `Set-Cookie`, which this unit's section says), its browser paragraph
(`302` → `GET /dashboard`, Kiran in the table — still so), the redirect-after-POST sentence, the CSRF line (still Course 10's), and the
static-resource section's versioned link (the stylesheet is untouched; the page is 30 bytes longer only when it carries a note).
`c6-tiffinbox/README.md`: lines added and removed against the previous tree's in `change`.

## The ledger rows and hand-offs this unit pays

| Row | Paid how | Where |
|---|---|---|
| the roadmap's "the session cookie inspected; sets up course 10" | the cookie from curl (`Set-Cookie`, curl's jar) and from Chrome (its record, its cookie store), both witnessed by the server; Course 10 by its roadmap title, *Spring Security — complete*: `SameSite`, `Secure` (measured, not set), CSRF and session fixation (named, not measured) | `cookie`, `browser`, `flags` |
| **C6-18** the session note (S3's: `server.servlet.session.persistent` by effect) | DevTools' default read off the environment (`true`), shown by effect across two JVMs (visits 1, 2, 3; off: 1) | `persistent` |
| **C6-31** | no developer-tools panel: Chrome's own record named; every new term glossed (a session, a cookie, HttpOnly, a flash attribute, session tracking) | the script |
| H-07 (C6/07 named this lesson among `@SessionAttribute`'s homes) | `@SessionAttribute` is not used: the flash attribute reaches the page through the model; named here, not spoken | — |

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 8 | 24's image | never run | **the image: the seven `466c20ed…`, the clean redirect, the HttpOnly cookie, the note once; `cookie,url` passed after the image's name → the id in the address; published on 127.0.0.1 alone, 0 tokens in its layers** (`forms`) |
| 12 | C on 24/after: Chrome's address after a first-contact form POST under `cookie,url` | the harness's `Flash` | **24/after's own form: `Location: …/dashboard;jsessionid=<id>`, Chrome's address `/dashboard;jsessionid=<id>`, the cookie's own id (compared), the note shown; Chrome sent the cookie too, so the page's links stayed clean** (`browser` C) |
| 13 | 24's persistent session under DevTools' own restart | two JVMs, SIGTERM | **two JVMs, POST /shutdown, DevTools on the class path: visits 1, 2 → 3, SESSIONS.ser written and read; off → 1, no file. DevTools' own restart (its restarter) not measured: unspoken** (`persistent`) |
| 14 | the exercise as viewers run it | end states on sketches | **one `env -i` shell: the id in the address, then the clean address** (`exercise`, and below) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **C is in `browser`** (brief: "C (labelled, Chrome)" under `tracking`): Chrome is optional (⚑8), so `tracking` holds A/B/A′ by curl
  and the labelled C is a visitor of `browser`.
- **`${added != null}`, not `${added}`** (brief ⚑5's template line): Thymeleaf reads the strings `false`, `off` and `no` as false, so a
  customer with such a name would get no note; the comparison is measured in all four forms (`forms`).
- **B's page carries the id in every link** (not in the brief): reached by `…;jsessionid=<id>` with no cookie, the dashboard's three
  links — the stylesheet's and the two in the header — end in `;jsessionid=<id>` (Thymeleaf's `@{…}` goes through the response's URL
  encoding). In Chrome, which sent the cookie too, they stayed clean (`browser` C: 0).
- **A cookie-less client loses the note under `cookie`** (not in the brief): the trade the key makes — under B the address carries the
  session to such a client (`tracking`).
- **"the first session-making request"** (brief) is, on this tree, the form's POST — the flash makes the session; the pages, the
  customers and the seven make none (`cookie`, two witnesses: `Dump` and `Sessions`).
- **Boot's timeout is `30m`** (brief: "maxInactiveSeconds 1800"): the same, from Boot's metadata; 90 s → 60 (one case: whole minutes).

## Found on the way

- **BLUE S4 part 2 (RED S4 #380, #387, #406):** the YAML's comment (line 24, in after/ and `c6-tiffinbox`) and the exercise card said
  a log and a browser's history keep the `;jsessionid=` address — unmeasured, and TiffinBox's own log never holds it (Tomcat's access
  log would, and Boot ships it off). Both now say what the captures show: a copied link keeps it, and so does every link on that page
  (B: 3). The voice's "Tomcat counts whole minutes" is Boot's doing — spring-boot-tomcat-4.1.1's
  `TomcatServletWebServerFactory.getSessionTimeoutInMinutes()` (javap: `Duration.toMinutes`, then `Math.max(1, …)`) hands Tomcat's
  `Context.setSessionTimeout(int)` whole minutes; the voice says "Boot hands Tomcat whole minutes". The thirty-minute check now reads
  `maxInactiveSeconds` from the capture (it was arithmetic on two literals, a check that could not fail).
- **DevTools' JVM exits 1 — explained and asserted** (RED S4 #404; R.109): DevTools' restarter runs the application again on a
  thread of its own (`restartedMain`) and ends the first `main` thread by throwing its `SilentExitException`; the handler it installs
  (`SilentExitExceptionHandler`, javap of spring-boot-devtools-4.1.1) stays silent and calls `System.exit(0)` only when that thread is
  the last one alive — it is not, so it just returns, and Java's launcher, whose `main` thread ended with an uncaught exception, exits
  1 when the last thread stops after POST /shutdown. A ten-line probe (a `main` that starts a thread, then throws with a silent
  handler) exits 1 the same way. `receipts.sh` asserts it now: each DevTools JVM a capture stops, on DevTools' port (19533), exits 1, and
  every other JVM a capture stops exits 0. Not spoken.
- **Every new check fails on a planted fault first** (R.65, S4.10): the checks block runs alone — `receipts.sh` with no build and no
  capture, on a copy of the published captures and this unit's files in a scratch folder (with the siblings it reads: `c5-unit11`'s
  `curlset.sh`, `c6-unit19`'s and `c6-unit22`'s harness, `c6-unit23/after`, the anchor's README) — with one thing changed per plant
  (`plants.py`, this unit's scratch folder): **69 plants, 69 stops under /bin/bash 3.2 and 69 under bash 5.3.9**, each naming its own
  check (the same 69 lines under both). Fifty-seven change one line of a capture (the files byte for byte, the first `---` above the
  key, Boot's timeout default, the libraries, the flash line, the key's value; one seven's md5, their sameness, a `Set-Cookie` in the
  seven, the previous tree's POST with a cookie, after/'s without, the idle time, the jar's second visit new, the jar's cookie with an
  expiry, the previous tree's modes, the customers making a session, PageNotFound's WARN; the note's first, second and cookie-less
  pages, the refused form's status, a cookie on the JSON POST, `-L -X POST`'s 405, `-L` with the jar; A's address, B's address, B's
  ids, B's links, A′, B's `$` line; SameSite, Secure, the timeout; the restart, persistence off, a token in `SESSIONS.ser`, DevTools'
  default, DevTools' exit 1, 35729, C′; the exercise's two lines and its ERROR count; the note in Chrome, the store's `httpOnly`, C's ids,
  C's address, F's `secure`, the seal, the fresh profile, the cookie on the redirected GET, a refused cookie; the forms' summary, a token
  in the binary, loopback, a pull; and six hygiene faults — an absolute path, a raw session id, a short unmasked one, Chrome's version,
  an unpinned java line, a date); seven change a shipped file (the spoken exercise line, a bare `wait` in the solution, a stop by name in
  `cdp.mjs`, the raw token in `net.py`, the harness named in after/'s code, `Dump` and `Keys` no longer the serving lesson's). The
  unplanted copy passes, before and after; every file is restored byte for byte (md5). One plant first stopped the wrong check — "a page
  makes a session" changed the first matching record, the previous tree's POST — and was made exact (the customers' record).
- **Four of this script's own faults, caught before the runs of record:** the date-and-time hygiene check, rewritten from Section 3's
  `sed … "$f" | grep`, had lost its file — it read standard input, which a run in the background leaves empty, so it passed without
  reading a capture; the checks-only run, given a terminal's standard input, hung there. It now reads the capture (and its plant, a
  date, stops it). `srec` first counted every line `Dump` printed for a request — its headers too — as requests (20 for the seven's 5);
  it now counts request lines. The forms' summary line first matched a raw `JSESSIONID=` value where the line already said `<id>` (0 of
  4). The check for an unmasked session id first fired on the YAML comment's `;jsessionid=...` — it now refuses `JSESSIONID=`/
  `jsessionid=` followed by a hex digit, beside the 32-hex-digit check. And bash 3.2 keeps the backslashes of `\/` in a `${x/a/b}`
  replacement and the quotes of `"'…'"` in a replacement inside double quotes, where bash 5.3 drops them: every such replacement is a
  variable now (`fd`, the derivations).
- **`${added != null}`, measured** (scratch, a copy of after/ on 19532, the jar): with `th:if="${added}"` the customers named `no`, `off`
  and `false` got no note (0, 0, 0) and `Lata` got hers (1); with `${added != null}` all four got theirs (1, 1, 1, 1).
- **The exercise as viewers run it**, beyond the capture: the README then SOLUTION, then SOLUTION again, in one `env -i` `/bin/bash`
  shell → the id in the address, then the clean address twice, each exit 0, the shell left in `c6-unit24/`, the local file's value
  changed once; 19538 free after each (the capture's run, and the solution's idempotent `sed`).
- **The probe's sketch and this tree agree** where they overlap (S4 notes Step 8, Step 9, Step 10): `HttpOnly` with no `SameSite` and
  no `Secure`, `GET /customers` sets no cookie, a jar → not new, 1800 seconds, the note once and none without the cookie, `;jsessionid=`
  under `cookie,url` in all forms, Strict and Secure each one key, 90 s → 60, persistence across two JVMs, Chrome's store flags and its
  `Secure` cookie on 127.0.0.1. Where they part: the first session-making request here is TiffinBox's own form POST (the sketch used a
  harness route), the curl first-contact case with `cookie` alone (measured here: a clean `Location`), B's links carrying the id, and
  Spring's AOT metadata (690 → 690: one entry differs, `DashboardPage`'s `add` with `RedirectAttributes`).
- **Under the Mac's Java 23:** the README's last line alone, in an `env -i` `/bin/bash` shell without the two `export` lines (`java
  -version`: 23.0.1), ends with exit 1 and prints no line — its Maven build fails under 23, so no JVM starts; 19538 free after it.

## For RED

- **Read `../c6-unit24/after`** (= `../c6-tiffinbox` now): `application.yaml`'s first document ends at line 121; the dashboard shows
  `<p class="note">… added</p>` only on the request after a form POST that stored a customer; the page is 962 bytes (23 lines) with the
  seed's four customers, 1036 (24 lines) with Lata added, 1066 on the request that shows her note.
- **The seven** stay `466c20ed7e0d5439cb052f32ce09de1b` and make no session (both witnesses).
- **Chrome:** 155.0.8059.85; `cdp.mjs` here opens a tab per command and keeps one Chrome per visitor (its cookie store).
- **RED:** re-run the sealed clone, both bashes, SIGINT during a JVM, Chrome and the native build; the session-id hygiene (a capture with
  a 32-hex run); `SESSIONS.ser` gone after the trap; Chrome's `Secure` on loopback (one host: 127.0.0.1).
- **Ports** 19530-19539 are this unit's. The image `tiffinbox-session:1.0.0` / container `tiffinbox-session` are this unit's names.
