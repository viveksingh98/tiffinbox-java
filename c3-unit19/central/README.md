# Two files fetched from Maven Central on 2026-09-15, shipped verbatim

```
https://repo1.maven.org/maven2/org/slf4j/slf4j-api/maven-metadata.xml
https://repo1.maven.org/maven2/org/slf4j/slf4j-api/
```

`../receipts.sh release` derives every number on this unit's version chip from these two
files and **makes no network request of its own** — which is what makes that chip a
receipt rather than a claim. Re-fetch them yourself with the two URLs above; the numbers
will move with the day, and the block will print the moved ones.

The claim being checked: Maven Central's `<release>` field is **the last entry of the
artifact's own version list, in version order (major number first)**. It is not "newest
GA" and it is not "newest published". For `org.slf4j:slf4j-api` it names an **alpha**,
and that alpha is **older** than the GA it hides.
