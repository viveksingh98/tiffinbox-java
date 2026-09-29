# Solution — whose H2?

Measured 2026-09-29 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1) by running `../README.md`'s commands exactly as
written — the transcript is `RUN.txt` — and, independently, by `../../receipts.sh` (its `exercise` capture):

```
start   pom.xml <h2.version>: 2.5.250         build exit 0 · lib/ holds: h2-2.5.250.jar
solved  pom.xml <h2.version>: (line deleted)  build exit 0 · lib/ holds: h2-2.4.240.jar
Boot's own BOM, spring-boot-dependencies-4.1.1.pom, line 68: <h2.version>2.4.240</h2.version>
```

The build does not fail, and `lib/` now holds **`h2-2.4.240.jar` — Boot's H2**, not TiffinBox's.

`${h2.version}` never became undefined. Properties are inherited down the parent chain: TiffinBox's parent is
`spring-boot-starter-parent`, whose parent is `spring-boot-dependencies`, and that BOM defines
`<h2.version>2.4.240</h2.version>` (line 68 above) — the same property name TiffinBox happened to use. With TiffinBox's
line gone, its own `<version>${h2.version}</version>` reads Boot's value. With the line present, TiffinBox's property
*overrides* Boot's, which is the documented way to move a Boot-managed version.

What this exercise does not measure: whether TiffinBox behaves the same on H2 2.4.240. A version is a decision, and a
different application could depend on something that differs between the two.
