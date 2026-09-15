# Two files fetched from Maven Central on 2026-09-15, shipped verbatim

```
https://repo1.maven.org/maven2/org/openjdk/jmh/jmh-core/maven-metadata.xml
https://repo1.maven.org/maven2/org/openjdk/jmh/jmh-core/
```

`../receipts.sh release` derives this unit's version chip from these two files and **makes
no network request of its own**.

The point it settles: `org.openjdk.jmh:jmh-core`'s newest version is **1.37**, its
`<release>` field agrees for once, and it was published on **2023-08-03**. A viewer who
checks will find a version several years old and wonder whether this course is stale. It is
not, and the block prints the honest reason as a shape rather than an opinion: 1.37 is the
last of a long list, no rc or milestone sits above it, and a harness whose job is to be
right about warm-up, forking and statistics is a harness that stops needing to change.
