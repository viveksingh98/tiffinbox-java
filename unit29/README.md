# Unit 29 — Streams: Reports in One Line

**What this unit teaches:** A stream is a lazy pipeline: `filter`, `map`, `sorted`, one terminal operation, and `Collectors.groupingBy`.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit29`), in the order below.

### java Reports.java

Filter → map → collect, `mapToInt().sum()`, and `joining`.

```console
$ java Reports.java
[Ravi, Sunil]
Monthly revenue: 15300
[Ravi 7200, Meera 4500, Sunil 3600]
Reminder to: Ravi, Meera, Sunil
```

### java Takings.java

`groupingBy` with `summingInt` and `counting`.

```console
$ java Takings.java
{VEG=360, NON_VEG=150, VEGAN=130}
{VEG=2, NON_VEG=1, VEGAN=1}
Takings: 640
```

### java Lazy.java

Proof that nothing runs until the terminal operation.

```console
$ java Lazy.java
pipeline built, nothing ran yet
filter Ravi
filter Meera
filter Sunil
[Ravi, Sunil]
```

### java BreakStream.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a stream is single-use.

```console
$ java BreakStream.java
2
Exception in thread "main" java.lang.IllegalStateException: stream has already been operated upon or closed
	at java.base/java.util.stream.AbstractPipeline.<init>(AbstractPipeline.java:201)
	at java.base/java.util.stream.ReferencePipeline.<init>(ReferencePipeline.java:101)
	at java.base/java.util.stream.ReferencePipeline$StatelessOp.<init>(ReferencePipeline.java:841)
	at java.base/java.util.stream.ReferencePipeline$3.<init>(ReferencePipeline.java:208)
	at java.base/java.util.stream.ReferencePipeline.map(ReferencePipeline.java:207)
	at BreakStream.main(BreakStream.java:6)
```

Exit code: `1` (non-zero — the failure is the point).
