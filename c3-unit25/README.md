# c3-unit25 — CI in 20 minutes: GitHub Actions

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **JDK 25.0.4.1 and JDK 26.0.2.1**, Apache Maven 3.9.16, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

## Read this first: what this unit does not have

**There is no run log in this unit, because no run of this workflow exists.**
`./receipts.sh norun` asks `gh`, records the answer, and hashes only the half of it that is
about the repository:

```
NOT hashed - these two are properties of THIS machine, so they are outside it:
  gh installed .............................. yes
  gh authenticated .......................... yes
HASHED - what this repository can say about runs of itself:
  .github/workflows/ present in this repo .... no
  workflow runs gh can list ................. 0
```

The split is the whole point of the block. Whether `gh` is on **your** PATH and logged in is
a fact about your Mac, so those two answers are printed *outside* the file the md5 covers and
cannot move it. The two under them — nothing installed at `.github/workflows/`, nothing for
`gh` to list — are the same in every clone and every fork of this repository, they are the
lesson, and they are the only two inside the hash. Without `gh`, or without a login, or if
`gh run list` exits non-zero, the block **stops** rather than hash an `n/a` — the same rule
`matrix` applies when there is no second JDK.

`workflows/build.yml` is **the taught material**. It is deliberately not installed at
`.github/workflows/` in this repository: a workflow there runs on every push and spends
real minutes, and that has to be your decision, not a side effect of cloning a course repo.
To get a run log, fork this repository, copy the file into `.github/workflows/`, push, and
then `gh run list --limit 1` and `gh run view <id> --log`.

**Free minutes are a property of public repositories.** On a private one the same push
spends minutes off a quota and nothing warns you the first time.

What this unit *does* have is every command the workflow runs, run here — including both
legs of the matrix, on two real JDKs — and the bug that makes the whole exercise worth
doing.

## The bug

`src/main/resources/Menu.json` has a capital **M**. `MenuLoader` asks for `"/menu.json"`.

```
Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
mvn package exit code: 0
```

Green. Now the same classes, from three places:

```
(a) target/classes on this Mac        -> meal types declared: 3 ... ok      exit 0
(b) the jar the same build produced   -> IOException: menu resource not found  exit 1
(c) target/classes on a case-sensitive volume -> the same IOException          exit 1

states run: 3 ; states that failed: 2
and the build that produced all of them said BUILD SUCCESS: 1
```

**(b) needs nothing at all.** A zip entry name is an exact byte string on every operating
system, so packaging is the first place the two spellings stop being the same word. A build
that prints `BUILD SUCCESS` produced an artifact that cannot start.

**(c) needs one command, no privileges and no network:**

```
hdiutil create -size 64m -fs 'Case-sensitive APFS' -volname <name> <img>
hdiutil attach <img> -nobrowse
```

That volume *is* the Linux runner, on your desk, in two seconds. The cause is reproduced
locally — it is never inferred from a red run somebody else's machine had.

## The matrix, run here

`./receipts.sh matrix` runs the workflow's own goal on both legs:

```
JDK 25.0.4.1   exit 0   Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
JDK 26.0.2.1   exit 0   Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
legs that went green: 2 of 2
fail-fast in the workflow: false  (so a red 26 cannot hide a green 25)
```

And why the matrix is *25 plus one*, read off an API rather than remembered
(`central/adoptium-available-releases.json`, no network at run time):

```
Adoptium LTS releases ............... [8, 11, 17, 21, 25]
most recent LTS ..................... 25
most recent feature release ......... 26
```

**25 is the baseline. 26 is a compatibility check, not a second baseline.** If 26 goes red
the answer is "Java 26 changed something", not "downgrade the project".

## The workflow, checked by a parser

`./receipts.sh workflow` hands `workflows/build.yml` to a YAML parser and reads the answers
back, because "it looks right" is not a check:

```
jobs ........................................ 2
steps in the build job ...................... 5
distinct actions used ....................... 3
every action pinned to a MAJOR tag (@vN) .... 3 of 3
actions pinned to a branch or to @main ...... 0
secret references in the whole file ......... 1
of those, anything but secrets.GITHUB_TOKEN . 0
lines containing a literal token or password  0
```

And one thing that only a parser finds:

```
"on_key_read_as": "the BOOLEAN true (YAML 1.1)"
```

**The `on:` key at the top of every GitHub workflow is not the string `"on"` to a YAML 1.1
parser — it is the boolean `true`**, by the same rule that turns `off`, `yes` and `no` into
booleans. GitHub's own parser does not do this; ruby's and python's do. Any tool you write
to lint your own workflows has to look under both keys, and the receipt does.

## Pins, and what a pin is worth

```
actions/checkout             latest v7.0.1   published 2026-07-20   pinned as checkout@v7
actions/setup-java           latest v6.0.1   published 2026-09-09   pinned as setup-java@v6
actions/cache              NOT USED in this workflow
actions/upload-artifact      latest v7.0.1   published 2026-04-10   pinned as upload-artifact@v7
```

`actions/cache` is in the header comment and in no step, and the receipt says so out loud:
`setup-java`'s own `cache: maven` does the same job, keyed on the pom files. **Use one of
them, never both**, or you have two caches racing for one key.

**A major tag moves. A commit SHA does not.** `actions/checkout@v7` resolves to v7.0.1
today and can resolve to something else tomorrow with nothing to tell you. Pinning by SHA
is what a security-conscious repository does, and the price is that you own the upgrade:

```
- uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8  # v7.0.1
```

An unpinned `@main` is not a defensible third option.

## Secrets

The workflow contains exactly one secret reference and it is `${{ secrets.GITHUB_TOKEN }}`,
which GitHub provides. Nothing is typed, nothing is echoed, nothing is committed — and the
`workflow` block **fails the receipt** if any other secret name appears.

## The release job

`release` runs only on a tag push (`refs/tags/v*`), only after both matrix legs are green
(`needs: build`), and it is the only job with `contents: write`. Everything else runs under
a top-level `permissions: contents: read`.

**What it does not do is on screen rather than left silent:** it does not sign or notarise
anything. A macOS bundle that anyone else can open needs a paid Apple Developer certificate
and a notarisation round-trip to Apple. That is an Apple step, not a Java step, and no
amount of Maven configuration replaces it.

## Exercise — `exercise/`

See `exercise/README.md`. **Start state:** the jar from a green build dies with
`IOException: menu resource not found`, exit 1. **End state:** the same command prints `ok`,
exit 0, with **0 Java files changed**. The answer is `exercise/solution/fix.txt`, and it is
worth reading past the one-line answer: renaming a file on a case-insensitive filesystem
is its own trap, one layer down.

## Receipts

| Block | What it proves |
|---|---|
| `workflow` | the file parses, and what a parser finds that a reader does not |
| `actions` | every pin against the release the API reported, from `central/`, no network |
| `matrix` | both legs of the matrix, run on two real JDKs on this machine |
| `casebug` | three states, two failures, one green build |
| `norun` | that no run log exists, asked of `gh` rather than assumed |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm run |

**Not hashed, and the block prints them outside the capture it hashes:** `norun`'s two `gh`
answers — installed, logged in — which are properties of the machine you run it on rather
than of the repository. The two answers that *are* about the repository are inside the md5,
because they are the same wherever you clone it.
