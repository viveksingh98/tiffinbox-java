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
 * <p>TODO: change the configuration so that JMH can print an error term, and then answer
 * the question in the README - which of these two is faster?
 */
@State(Scope.Benchmark)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Fork(1)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 2, time = 1, timeUnit = TimeUnit.SECONDS)
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
