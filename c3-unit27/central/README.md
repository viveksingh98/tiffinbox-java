# central/ — three files, fetched once, committed on purpose

`../receipts.sh graalvm` derives every version and size below from these files and **makes
no network request**. That matters more here than anywhere else in the course: this unit's
central claim is about a toolchain that is **not installed on the machine it was written
on**, so the evidence has to be checkable rather than remembered.

| File | Source | Fetched |
|---|---|---|
| `native-maven-plugin-maven-metadata.xml` | `repo1.maven.org/maven2/org/graalvm/buildtools/native-maven-plugin/maven-metadata.xml` | 2026-09-15 |
| `native-maven-plugin-directory-listing.html` | the directory listing beside it, which carries a publication date per version | 2026-09-15 |
| `graalvm-ce-builds-latest.json` | `api.github.com/repos/graalvm/graalvm-ce-builds/releases/latest` — the tag, the date, and every asset's **size in bytes** | 2026-09-15 |

The asset size is the honest answer to *"why did you not just install it?"*: it is a number,
it is in the file, and `receipts.sh` reads it out rather than describing it.
