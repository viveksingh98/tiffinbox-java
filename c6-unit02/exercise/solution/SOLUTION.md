# Solution — one pattern more

Run from `c6-unit02/`, after `exercise/README.md`'s setup. `RawServletConfig.java` here is the shipped registration with one
pattern added — `*.menu` — beside `/raw` and `/raw/*`. One line: it compiles that file with the raw servlet, starts the copy
with it joined (TiffinBox on 19318, Tomcat on 19319, both on `127.0.0.1`), waits for readiness, asks Tomcat both paths, and
stops the JVM by its pid.

```bash
exercise/try.sh exercise/solution/RawServletConfig.java /lunch.menu /raw/lunch.menu
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-12):

```
GET /lunch.menu      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.menu match=EXTENSION
GET /raw/lunch.menu  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
```

`/lunch.menu` now matches the extension. `/raw/lunch.menu` still matches `/raw/*`: given a path pattern and an extension that
both fit, the container chose the path pattern — as it did for `/raw/lunch.tiff` in the video.
