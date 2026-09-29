# Solution

Measured 2026-09-29 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1) by running `../README.md`'s two blocks **exactly as
written**, from `c5-unit03/exercise/`, against this unit's own `.m2-demo` after `../receipts.sh` had filled it.

The build block's last line printed:

```
jackson-annotations-2.21.jar jackson-core-2.21.5.jar jackson-databind-2.21.5.jar
```

The serve block printed `115c36bac276128e245ca57df11c2891` (the seven answers, the same hash as in the receipts' `responses`
capture and as Course 4's), and `wait` returned 0 — the server stopped on the set's own `POST /shutdown`.

**One family, Boot's version.** With the line gone, nothing of yours names a Jackson version at all, so Boot's BOM (the
bill of materials `spring-boot-starter-parent` inherits) decides all three through its own `jackson-2-bom.version` —
2.21.5 here, the same family the receipts' `steer` capture shows for a project that imports Boot's list (row B). The
break was different: there, `jackson-databind` was pinned alone, so databind stayed on 2.22.2 while Boot moved the other
two. TiffinBox keeps the property because the track's Jackson is 2.22.2 (Course 2).
