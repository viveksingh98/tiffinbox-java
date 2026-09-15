# central/ — two files, fetched once, committed on purpose

`../receipts.sh release` derives this unit's version chip from these two files and **makes no
network request at all**. They are the evidence behind the claim, so a viewer can check the
arithmetic from a clean clone with the wifi off.

| File | What it is | Fetched |
|---|---|---|
| `maven-jar-plugin-maven-metadata.xml` | `https://repo1.maven.org/maven2/org/apache/maven/plugins/maven-jar-plugin/maven-metadata.xml` — the artifact's own version list, plus the `<release>` and `<latest>` fields | 2026-09-15 |
| `maven-jar-plugin-directory-listing.html` | the directory listing beside it, which carries a **publication date per version** | 2026-09-15 |

The point they make together: **`<release>` is not "newest GA" and it is not "newest published"
either.** It is the last entry of the version list in Maven's own version order, which puts
`4.0.0-beta-1` above `3.5.1` because 4 is greater than 3 — and that beta was published two years
*before* the GA it hides. Read the list, never the field.
