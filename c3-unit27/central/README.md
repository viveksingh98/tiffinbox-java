# central/ — three files, fetched once, committed on purpose

`../receipts.sh graalvm` derives every version and size below from these files and **makes
no network request**. These are the *pinned* facts — what a viewer has to fetch, and which
release this unit points at — and they are deliberately **not** read from whatever GraalVM
happens to be installed. That is the whole reason the `graalvm` block hashes the same on
every machine.

⚠ **Corrected 2026-09-17.** This page used to say the unit's central claim was about a
toolchain *"not installed on the machine it was written on"*. That was true on 2026-09-15 and
is not any more: a GraalVM JDK became available on 2026-09-16 and `../receipts.sh native` now
builds a real binary with it. The distinction these files preserve is still worth having, and
it is a different one: **`graal-25.3.4.1` below is the release this unit pins, not the build
that produced the binary** (that was `Oracle GraalVM 25.0.4+7.1`, reported by the `native`
block outside its hash). Mixing the two would be the easiest wrong number on the page.

| File | Source | Fetched |
|---|---|---|
| `native-maven-plugin-maven-metadata.xml` | `repo1.maven.org/maven2/org/graalvm/buildtools/native-maven-plugin/maven-metadata.xml` | 2026-09-15 |
| `native-maven-plugin-directory-listing.html` | the directory listing beside it, which carries a publication date per version | 2026-09-15 |
| `graalvm-ce-builds-latest.json` | `api.github.com/repos/graalvm/graalvm-ce-builds/releases/latest` — the tag, the date, and every asset's **size in bytes** | 2026-09-15 |

The asset size is the honest answer to *"what does this cost a viewer?"*: it is a number, it
is in the file, and `receipts.sh` reads it out rather than describing it. It is also why
`./receipts.sh native` is opt-in — a viewer who has not paid that 339 MB gets a **skip that
names the variable to set**, never a failure.
