# c2-unit14 — Locks, Atomics and Concurrent Collections (JDK 25.0.4.1)

What it teaches: the tools that replace hand-written `synchronized` — `AtomicInteger`/`LongAdder`,
`ConcurrentHashMap`, `CopyOnWriteArrayList` and `ReentrantLock.tryLock` — and what a real deadlock
looks like from the outside.

Run the four compact source files directly, no flags
(`export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):

```bash
java Atomics.java
```
```
AtomicInteger: 2000000
LongAdder:     2000000
```
Both exact, every run — this is Unit 12's lost update, fixed without a single `synchronized`.

```bash
java Revenue.java
```
```
NON_VEG: 150000
VEG: 220000
VEGAN: 140000
total: 510000
```
`ConcurrentHashMap.merge` from many threads; the totals are fixed by arithmetic, so they are
byte-identical every run.

```bash
java Snapshot.java
```
```
ArrayList:            reader saw 1, list size now 4, java.util.ConcurrentModificationException
CopyOnWriteArrayList: reader saw 3, list size now 4, no exception
```

```bash
java TryLock.java
```
```
counter locked by someone: true
tryLock() now:             false
tryLock(100ms):            false
tryLock() after release:   true
```

`java NaturalRace.java` is the honesty demo — the same `ConcurrentModificationException` bug with
no baton forcing the timing, so it does **not** throw on every run (it often prints `no exception`).
That is exactly why `Snapshot.java` uses a baton: a race you cannot reproduce is still a bug.

## The deadlock demo — it hangs on purpose

```bash
javac -d out Deadlock.java
java -cp out Deadlock          # prints nothing more and never returns
```
In a second shell:
```bash
jcmd -l                        # find the pid (the line ending in Deadlock)
jcmd <pid> Thread.print        # -> "Found one Java-level deadlock:" and the two threads
kill -9 <pid>                  # ALWAYS: a deadlocked JVM will not stop any other way
pgrep -fl "cp out Deadlock"    # must print nothing
```
`Deadlock.java` is a classic class (not a compact source file) so the stack frames in
`Thread.print` carry clean line numbers.

Check everything in this folder at once (the deadlock is time-boxed and killed for you):
`../verify_course2.sh 14`
