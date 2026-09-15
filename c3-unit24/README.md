# c3-unit24 — git workflow for real

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **git 2.54.0**, JDK 25.0.4.1, Apache Maven 3.9.16, macOS 27.0, 8-core / 16 GB
Apple silicon, on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

## Git safety — read this before you run anything

Every repository this unit writes to is **created by `receipts.sh`, under `.repos/`, and
deleted by `./receipts.sh clean`.** Nothing here commits, pushes, rebases, resets or tags
anything else, and a `guard()` in the script refuses to run a write command against any
working tree whose top level is not inside `.repos/`.

The repository this unit **reads** is the one you are standing in — the one you cloned.
`./receipts.sh realrepo` runs `git log`, `git ls-files` and `git check-ignore` against it,
writes nothing, and says so in its own output.

`~/.gitconfig` is never read and never written either: every commit below sets its identity
through `GIT_AUTHOR_*` / `GIT_COMMITTER_*` in the environment, and every `git` invocation
goes through `git -c user.name=… -c user.email=… -c core.hooksPath=/dev/null`.

## Why the commit ids in this unit are the same on your machine as on mine

A commit's id is a hash of **eight fields**: the tree, the parents, the author name, the
author email, the author date, the committer name, the committer email and the committer
date. `./receipts.sh hashes` proves it rather than asserting it — the same commit is built
twice in two directories, then a third time with **one** field changed by one second:

```
  86d904855ccc172689ef6ce5309519814a927b78
  86d904855ccc172689ef6ce5309519814a927b78
  identical: yes
the same commit again with ONE field changed - the committer date, by one second:
  3a546c0118682cea5647aee7d8fffadd679f25ae
  identical to the first: no
all three trees identical: yes
```

**Identical content, different id.** A commit id is not a checksum of your files, and that
one fact explains why a rebase changes ids, why `git rm --cached` does not shrink a
repository, and why two people can get "the same" branch with different history.

## Merge and rebase, from the same three commits

`./receipts.sh branch` builds one history, copies it, and finishes it both ways.

```
merged                                    rebased
*   merge: bela/meal-type into arun/…     * customer: put meal type on the receipt line
|\                                        * dashboard: report pause days per customer
| * customer: put meal type on the …      * TiffinBox: the dashboard, as Course Two left it
* | dashboard: report pause days per …
|/
* TiffinBox: the dashboard, as Course Two left it

commits reachable from HEAD ..... 4       commits reachable from HEAD ..... 3
commits on the first-parent line  3       commits on the first-parent line  3
merge commits ................... 1       merge commits ................... 0
the same two changes are in both: yes - identical trees
commits the rebase rewrote (same change, new id): 1
```

**The trees are identical.** The two histories are not. The merge keeps the fact that two
people worked at once; the rebase throws it away in exchange for a straight line. Neither
is correct — pick one and keep picking it, because a history that is half one and half the
other is the only genuinely bad answer.

## A message shape a command can read

`./receipts.sh convention` writes four conventional commits and then generates a changelog
with **no tool at all** — one `git log --format` and a `sed`. Then it asks the same question
of the repository you cloned:

```
commits in this history ........................ 4
commits whose subject a parser can classify .... 4
and the SAME question, asked of the repository this unit ships in (read only):
  commits ....................................... 34
  commits a conventional-commit parser can read .. 0
```

**Zero.** This repository does not use conventional commits — it uses `<scope>: <subject>`
where the scope is a filename, and it is consistent about it. That is the honest lesson:
the convention that pays is the one the whole history keeps, and a changelog generator is
only ever a `git log` over a history someone wrote for it.

## A tag is an object; a branch is a file with a hash in it

```
branch release/1.0.0  -> commit object
lightweight tag       -> commit object
annotated tag         -> tag object
```

```
object 1f91f62654495a691ff29574b209b4b6a194f3b1
type commit
tag v1.0.0
tagger TiffinBox <tiffinbox@example.invalid> 1772442000 +0000

TiffinBox 1.0.0 - the first build anyone else ran.
```

Then one more commit on `release/1.0.0`:

```
release/1.0.0 now points at ... customer: one more line
v1.0.0 still points at ........ TiffinBox: the dashboard, as Course Two left it
they are the same commit: no
```

The annotated tag records **who tagged it, when, and why**. The branch records none of
those and moves under you. A release is a claim about a moment; use the object that stores
one.

## Break 1 — `target/` committed once

`./receipts.sh ignored` builds the project **inside** the throwaway repository, so the
`target/` it commits is real output, then un-commits it:

```
files under target/ tracked after the first commit: 16
objects reachable from every ref ................. 54
$ git rm -r --cached target && git commit
files under target/ tracked now .................. 0
objects reachable from every ref ................. 56
objects the un-commit removed ................... 0
objects it ADDED ................................ 2   (one commit, one tree)
$ git cat-file -t HEAD~1:target/tiffinbox-core-1.0.0.jar -> blob
```

`.git` went from **324 KB to 332 KB**. `git rm --cached` takes a file out of the *next*
commit and out of *no* previous one — the blob is still reachable, still cloned, still
downloaded by everyone forever. The only fix is rewriting history, which is a different and
much more expensive conversation.

## Break 2 — the rule that works for everyone except you

`*.jar` is the most-pasted line in a Java `.gitignore`. `target/` and `build/` already keep
build output out; what `*.jar` adds is the Gradle wrapper.

```
git status --porcelain lines ............. 0   (nothing to report)
gradle/wrapper/gradle-wrapper.jar ........ present     <- on YOUR disk
$ git check-ignore -v gradle/wrapper/gradle-wrapper.jar
.gitignore:8:*.jar	gradle/wrapper/gradle-wrapper.jar

a colleague clones it:
gradle/wrapper/gradle-wrapper.jar ........ absent
$ ./gradlew --version
Error: Unable to access jarfile <clone>/gradle/wrapper/gradle-wrapper.jar
exit code: 1

jar files TRACKED in the repository ....... 0
jar files present in YOUR working copy .... 1
```

`receipts.sh` **actually clones the repository** to test this, because a clone is the only
honest test of a `.gitignore`. The block refuses to pass if the clone turns out to have the
jar.

The fix, in this order and no other:

```
*.jar
!gradle/wrapper/gradle-wrapper.jar
```

A `!` line cannot rescue a file inside an ignored **directory** — git never looks inside
one — so `gradle/` followed by `!gradle/wrapper/gradle-wrapper.jar` does nothing at all.

`templates/java.gitignore` is the whole rule set, with the reason on every line.

## Exercise — `exercise/`

See `exercise/README.md`. **Start state:** `git status` clean, your copy builds, the clone
dies with `Unable to access jarfile`. **End state:** `git ls-files '*.jar'` lists exactly
one file and `git ls-files '*target/*'` lists none — by changing `.gitignore` only.

## Receipts

| Block | What it proves |
|---|---|
| `branch` | merge and rebase from the same three commits; identical trees, different histories |
| `convention` | a changelog from `git log` alone — and the real repo's own convention, read-only |
| `tag` | annotated vs lightweight vs branch, read out of the object database |
| `hashes` | a commit id is a function of eight fields, not of your files |
| `ignored` | `target/` committed, then un-committed, and the repository getting *bigger* |
| `wrapper` | the clone test — the only honest test of a `.gitignore` |
| `realrepo` | this repository's own history, `git log` and `git ls-files` only, no write |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm run |
| `clean` | deletes `.repos/` |

**Not hashed, and each says so in its own output:** `.git`'s size in KB (it moves with `gc`
and with the git version) · the real repository's commit count, author count and two dates
(they move as the repo grows).
