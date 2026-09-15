package com.tiffinbox;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.atomic.AtomicInteger;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * What a switched-off DEBUG call costs - COUNTED, never timed.
 *
 * <p>The root level in logback.xml is INFO, so neither debug call below prints anything.
 * The question is what each one did before finding that out. CostlyLabel counts its own
 * toString() calls, so the answer is a number this test reads rather than a duration it
 * has to defend.
 */
class ArgumentCostTest {

    private static final Logger log = LoggerFactory.getLogger(ArgumentCostTest.class);

    /** A label that is expensive to render - and that tells you how often you rendered it. */
    record CostlyLabel(String name, AtomicInteger renders) {
        @Override
        public String toString() {
            renders.incrementAndGet();
            return "roster of " + name;
        }
    }

    private static final int CALLS = 1_000;

    /**
     * The receipt greps these three lines out of the build. They are printed AFTER the
     * assertion that fixes each number, so a line that reaches the log is a line an
     * assertion already agreed with.
     */
    private static void report(String what, int renders, int calls) {
        log.info("cost | {} | {} render(s) of {} call(s)", what, renders, calls);
    }

    @Test
    void concatenationBuildsTheStringEvenWhenTheLevelIsOff() {
        var renders = new AtomicInteger();
        var label = new CostlyLabel("Arun", renders);

        for (int i = 0; i < CALLS; i++) {
            log.debug("kitchen snapshot: " + label);      // the argument is built HERE
        }

        assertThat(log.isDebugEnabled()).isFalse();
        assertThat(renders.get()).isEqualTo(CALLS);
        report("concatenated  \"...\" + label   DEBUG off", renders.get(), CALLS);
    }

    @Test
    void theBracePlaceholderDoesNot() {
        var renders = new AtomicInteger();
        var label = new CostlyLabel("Arun", renders);

        for (int i = 0; i < CALLS; i++) {
            log.debug("kitchen snapshot: {}", label);     // the argument is handed over, not built
        }

        assertThat(log.isDebugEnabled()).isFalse();
        assertThat(renders.get()).isZero();
        report("parameterised \"...{}\", label  DEBUG off", renders.get(), CALLS);
    }

    /**
     * And when the level IS on, the placeholder form renders exactly once per call - so the
     * zero above is the level being off, not the placeholder being lazy about everything.
     * Three calls, not a thousand, because these three DO print.
     */
    @Test
    void thePlaceholderStillRendersWhenTheLevelIsOn() {
        var renders = new AtomicInteger();
        var label = new CostlyLabel("Arun", renders);

        assertThat(log.isInfoEnabled()).isTrue();
        for (int i = 0; i < 3; i++) {
            log.info("kitchen snapshot: {}", label);
        }
        assertThat(renders.get()).isEqualTo(3);
        report("parameterised \"...{}\", label  INFO  on ", renders.get(), 3);
    }
}
