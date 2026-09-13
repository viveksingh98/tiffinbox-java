# Unit 32 — Dates and Times with java.time

**What this unit teaches:** `LocalDate`, `Period`, `ChronoUnit` and formatters — the pause feature the capstone bills against.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit32`), in the order below.

### java Pause.java

A 7-day pause priced with `ChronoUnit.DAYS.between`, plus `Period` and `isBefore`.

```console
$ java Pause.java
2026-09-01 is a TUESDAY, 30 days
Paused 7 days, resumes 2026-09-21
Ravi's bill: 5520
Customer for 1y 2m 3d
true true
Sundays off: 4
```

### java Formats.java

`DateTimeFormatter` in both directions, and `LocalDateTime`.

```console
$ java Formats.java
Pause from 14/09/2026
2026-09-21
2026-09-21
12:30 2026-09-14T12:30
```

### java BreakDate.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** `LocalDate.parse` expects ISO order unless you hand it a formatter.

```console
$ java BreakDate.java
Exception in thread "main" java.time.format.DateTimeParseException: Text '14/09/2026' could not be parsed at index 0
	at java.base/java.time.format.DateTimeFormatter.parseResolved0(DateTimeFormatter.java:2108)
	at java.base/java.time.format.DateTimeFormatter.parse(DateTimeFormatter.java:2010)
	at java.base/java.time.LocalDate.parse(LocalDate.java:437)
	at java.base/java.time.LocalDate.parse(LocalDate.java:422)
	at BreakDate.main(BreakDate.java:2)
```

Exit code: `1` (non-zero — the failure is the point).

### java BreakInvalid.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** the calendar is checked — 30 February does not exist.

```console
$ java BreakInvalid.java
Exception in thread "main" java.time.DateTimeException: Invalid date 'FEBRUARY 30'
	at java.base/java.time.LocalDate.create(LocalDate.java:461)
	at java.base/java.time.LocalDate.of(LocalDate.java:277)
	at BreakInvalid.main(BreakInvalid.java:2)
```

Exit code: `1` (non-zero — the failure is the point).
