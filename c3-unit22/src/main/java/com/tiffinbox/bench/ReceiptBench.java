package com.tiffinbox.bench;

import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.infra.Blackhole;

import com.tiffinbox.Customer;

import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Building one receipt block, three ways, measured by a harness instead of a stopwatch.
 *
 * <p>Every annotation on this class is part of the answer, not decoration:
 * <ul>
 *   <li>{@code @Fork(2)} - run the whole thing twice in two FRESH JVMs. One JVM's JIT
 *       decisions are one sample, not a fact.</li>
 *   <li>{@code @Warmup} - throw these iterations away, because cold code is a different
 *       program from the same code after the JIT has finished with it.</li>
 *   <li>{@code @Measurement} - and then take these, so there is something to compute a
 *       spread from. Two forks of three iterations is six samples, and six is what appears
 *       in the Cnt column.</li>
 *   <li>{@code @BenchmarkMode} + {@code @OutputTimeUnit} - say what the number means and in
 *       what unit, on the same line as the number.</li>
 *   <li>{@code Blackhole} - consume the result, so the JIT cannot delete the work. What
 *       happens without it is in breaks/no-blackhole.</li>
 *   <li>{@code @Param} - run the whole matrix at more than one input size. A benchmark with
 *       one size does not measure an algorithm; it measures an algorithm at one size, and
 *       for these three that is the difference between two opposite answers.</li>
 * </ul>
 *
 * <p>Those are exactly the four conditions this course puts on any wall-clock number -
 * N runs with N stated, a warm-up that is stated, the machine named, every flag pinned -
 * plus the one that stops the number being a measurement of nothing. JMH prints all of
 * them whether you ask for them or not.
 */
@State(Scope.Benchmark)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Fork(2)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
public class ReceiptBench {

    /** Six customers is one kitchen's roster. Six hundred is a month of them. */
    @Param({"6", "600"})
    public int rows;

    private List<Customer> roster;

    @Setup
    public void buildRoster() {
        roster = Receipts.rosterOf(rows);
    }

    @Benchmark
    public void concatInALoop(Blackhole bh) {
        bh.consume(Receipts.concat(roster));
    }

    @Benchmark
    public void stringBuilder(Blackhole bh) {
        bh.consume(Receipts.builder(roster));
    }

    @Benchmark
    public void streamJoining(Blackhole bh) {
        bh.consume(Receipts.stream(roster));
    }
}
