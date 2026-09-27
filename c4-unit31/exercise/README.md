# Exercise — a route whose numbers come from the environment

Add `GET /config` to the rewired server. It returns the kitchen's settings:

```
{"cooks":3,"days":30}
```

**No `new` for a component, and no number typed in the Java** — both values must be injected from
`tiffinbox.properties`. Work on a copy:

```
rsync -a --exclude target ../../c4-tiffinbox/ my-tiffinbox/
# edit my-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
(cd my-tiffinbox && mvn -q -DskipTests package)
java -Dtiffinbox.days=7 -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18449
curl -s http://127.0.0.1:18449/config
curl -s http://127.0.0.1:18449/kitchen
curl -s -X POST http://127.0.0.1:18449/shutdown
```

Prove it the container's way: with `-Dtiffinbox.days=7`, `/config` must say 7 — and `/kitchen` must change
with it, because the morning rail reads the same property. Say in one line why the system property won over
the file. Solution in `solution/`.
