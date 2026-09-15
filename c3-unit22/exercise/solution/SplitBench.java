package com.tiffinbox.bench;

import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.infra.Blackhole;

import java.util.concurrent.TimeUnit;

/**
 * THE EXERCISE. Read exercise/README.md first.
 *
 * <p>Two ways to build the same receipt block, correctly benchmarked in every respect but
 * one. Run it and look at the Error column.
 *
 * <p>THE ANSWER. Two forks of three measurement iterations is six samples, and six is
 * enough for JMH to compute a confidence interval. Fewer than three and it prints the
 * column empty rather than print a number it cannot defend - which is the whole lesson:
 * <b>the harness refuses to give you an error term it has not earned.</b>
 *
 * <p>And then read the two intervals. On the machine this was written on they overlap, and
 * the honest answer to "which is faster" is that this benchmark cannot tell you. That is
 * not a failed exercise. It is the exercise.
 */
@State(Scope.Benchmark)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Fork(2)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
public class SplitBench {

    @Benchmark
    public void concatInALoop(Blackhole bh) {
        bh.consume(Receipts.concat(Receipts.ROSTER));
    }

    @Benchmark
    public void stringBuilder(Blackhole bh) {
        bh.consume(Receipts.builder(Receipts.ROSTER));
    }
}
