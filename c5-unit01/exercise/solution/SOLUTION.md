# Solution

`solution/TiffinBoxServer.java` is `../after/`'s file with the three bridge lines deleted; `main` is one line:
`SpringApplication.run(TiffinBoxApp.class, args);`.

## The run that measured it

`../README.md`'s blocks, run exactly as written from `c5-unit01/exercise/` on 2026-09-29 (JDK 25.0.4.1, Maven 3.9.16,
Spring Boot 4.1.1), after `../receipts.sh` had passed. The one manual step, the edit, was made by deleting exactly the
three lines; the edited file then compared equal (`cmp`) to `solution/TiffinBoxServer.java`.

```
$ (cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests clean package)
$ java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18527 > new.log 2>&1 &
$ sleep 5
$ ../../c4-unit31/curlset.sh 18527 | grep ' -> ' | md5 -q
115c36bac276128e245ca57df11c2891
```

Done: the seven responses hash to `115c36bac276128e245ca57df11c2891`, the line `receipts.sh` prints for both projects
(`.r-identical.out`); `new.log` says `TiffinBox listening on http://127.0.0.1:18527`, and after `curlset.sh`'s
`POST /shutdown` nothing listens on 18527. Boot's `commandLineArgs` property source answers `tiffinbox.port` before
the file does.

```
$ java -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18528 > old.log 2>&1 &
$ sleep 5
$ lsof -nP -a -p $! -iTCP -sTCP:LISTEN
COMMAND   PID       USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
java    64506 viveksingh   34u  IPv6 0x5cd70191f71bb715      0t0  TCP 127.0.0.1:18425 (LISTEN)
$ kill $!
```

**The old command listens on 18425** — the port in `tiffinbox.properties` — and `old.log` has no WARN or ERROR line
(0 of them). A bare `18528` is a *non-option* argument: Boot keeps it (`ApplicationArguments.getNonOptionArgs()`) but
no property is named by it, so nothing reads it and nothing warns. That is why the last course needed the bridge, and
why deleting it changes the run command: from here on it is `java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=<port>`.
(PID and device columns vary run to run; the port does not.) `kill $!` stopped it: 0 listeners on 18425 afterwards.
