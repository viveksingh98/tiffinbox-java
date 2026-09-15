package com.tiffinbox.bench;

import com.tiffinbox.Customer;
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
 * The same call, four ways, in one run - and one of the four numbers is a measurement of
 * nothing.
 *
 * <p>{@code Customer.monthlyBill()} is two multiplications on a record the viewer has
 * carried since the first course. {@code baseline} does nothing at all, so it measures
 * JMH's own per-invocation overhead and gives the other three a floor to be read against.
 *
 * <p>A JIT compiler that can prove a computed value is never used is entitled to stop
 * computing it. It will not warn you. JMH will not fail. The result comes out perfectly
 * well formed, with an error term and a unit, and it is nonsense.
 *
 * <p><b>An honest note about how this file was written, because it is the real lesson.</b>
 * The first version of this break built the six-line receipt string with a StringBuilder
 * and discarded it - and the JIT did <i>not</i> eliminate it: discarded 140.441 ± 0.777
 * ns/op against consumed 138.475 ± 4.504. Allocation is much harder for the compiler to
 * prove dead than arithmetic is. So you cannot tell by looking at your own benchmark
 * whether the work survived. That is precisely why the Blackhole is not optional: it is not
 * a fix for a problem you can see coming, it is the thing that stops the question arising.
 */
@State(Scope.Benchmark)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Fork(2)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
public class DeadCodeBench {

    /** Not final, so nothing is folded away before the JIT even sees it. */
    private Customer customer = new Customer("Arun", 2, 120, "VEG");

    /** Measures JMH's own overhead, and nothing else. The floor. */
    @Benchmark
    public void baseline() {
    }

    /** The result goes nowhere. */
    @Benchmark
    public void discarded() {
        customer.monthlyBill();
    }

    /** Returned - JMH consumes a returned value for you. */
    @Benchmark
    public int returned() {
        return customer.monthlyBill();
    }

    /** Handed to a Blackhole, which the compiler cannot see through. */
    @Benchmark
    public void consumed(Blackhole bh) {
        bh.consume(customer.monthlyBill());
    }
}
