package com.tiffinbox;

import com.tiffinbox.bench.Receipts;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The test that has to pass before any benchmark number is worth reading.
 *
 * <p>Two benchmarks that produce different output are not a comparison - they are two
 * measurements of two different programs, and no benchmark harness anywhere checks that
 * for you. JMH will happily give you a beautiful table comparing a correct implementation
 * with a broken one.
 *
 * <p>So: same roster, same string, all three. And one assertion on the content, so that
 * "all three agree" cannot be satisfied by all three being empty.
 */
class ReceiptsAgreeTest {

    private static final String EXPECTED_FIRST_LINE = "Arun x2 = 7200";

    @Test
    void allThreeImplementationsProduceTheSameReceipt() {
        String a = Receipts.concat(Receipts.ROSTER);
        String b = Receipts.builder(Receipts.ROSTER);
        String c = Receipts.stream(Receipts.ROSTER);

        assertThat(a).isEqualTo(b).isEqualTo(c);
    }

    @Test
    void allThreeStillAgreeAtTheSizeTheBenchmarkAlsoRunsAt() {
        var big = Receipts.rosterOf(600);

        assertThat(big).hasSize(600);
        assertThat(Receipts.concat(big))
                .isEqualTo(Receipts.builder(big))
                .isEqualTo(Receipts.stream(big));
    }

    @Test
    void andTheReceiptIsNotEmpty() {
        String a = Receipts.concat(Receipts.ROSTER);

        assertThat(a.lines()).hasSize(Receipts.ROSTER.size());
        assertThat(a.lines().findFirst()).contains(EXPECTED_FIRST_LINE);
    }
}
