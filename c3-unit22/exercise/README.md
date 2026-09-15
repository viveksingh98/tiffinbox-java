# Exercise — give the harness enough to answer with

## The start state

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" -q clean package
java -jar target/benchmarks.jar
```

```
Benchmark                 Mode  Cnt    Score   Error  Units
SplitBench.concatInALoop  avgt    2  231.109          ns/op
SplitBench.stringBuilder  avgt    2  398.291          ns/op
```

Read that as a colleague would: *concatenation is seventy percent faster than
StringBuilder.* It has a mode, a unit, a warm-up, a Blackhole and a count. It looks like a
real result.

**Now look at the `Error` column.** It is empty. Not zero — empty. JMH computed no
confidence interval at all and told you so by printing nothing, and the number beside it is
therefore a number with no claim attached.

## Your task

Two annotation values in `src/main/java/com/tiffinbox/bench/SplitBench.java`. Nothing else.
JMH needs at least three samples before it can compute a spread, and the samples are
`forks × measurement iterations`.

Then answer the question the exercise is really about:

> **Which of these two is faster?**

Compute both intervals by hand — score minus error to score plus error — and see whether
they overlap before you answer.

## The end state you are reaching

```
Benchmark                 Mode  Cnt    Score    Error  Units
SplitBench.concatInALoop  avgt    6  181.872 ± 52.296  ns/op
SplitBench.stringBuilder  avgt    6  218.915 ± 68.924  ns/op
```

`Cnt` is **6**, and every row carries an error term. Your scores will differ; the two things
that must be true on your machine are the `Cnt` and the presence of the `±`.

And the answer to the question: **on this machine, you cannot tell.** `[129.6, 234.2]`
against `[150.0, 287.8]` — the intervals overlap, so the ordering the start state stated so
confidently is not something this benchmark supports. That is not a failed exercise. It is
the exercise: the harness's job is not to tell you which is faster, it is to tell you
whether you are entitled to say so.

## The answer

`solution/SplitBench.java`. `../receipts.sh solution` copies it into a throwaway copy of
this directory, runs both states and prints the two `Cnt` values with the error-term counts
beside them — the two numbers that are the same on any machine.
