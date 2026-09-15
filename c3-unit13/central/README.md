# `central/` — the authoring-time version sweep, shipped so you can check it

Two files, fetched **2026-09-15** and kept **verbatim**:

| File | Fetched from |
|---|---|
| `assertj-core-maven-metadata.xml` | `https://repo1.maven.org/maven2/org/assertj/assertj-core/maven-metadata.xml` |
| `assertj-core-listing.html` | `https://repo1.maven.org/maven2/org/assertj/assertj-core/` |

They are here for one reason. The deck's recap says Central's `<release>` field is not the newest GA,
and gives numbers — and a claim you cannot re-derive is not evidence. `./receipts.sh release` reads
these two files and derives every one of those numbers, **offline**. Nothing in this project makes a
metadata request at build time: this unit's network tier is `resolution only`, and a `curl` against
`repo.maven.apache.org` is not covered by it. The sweep is how the pin was verified; it is not a
build input, and it never appears in a capture.

They are a **dated snapshot**, not a live read. Central will have moved on. That is the point: the
slide quotes what was true on 2026-09-15 and ships the bytes it quoted, so the two can be compared.
