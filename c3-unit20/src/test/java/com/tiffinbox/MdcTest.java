package com.tiffinbox;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import com.tiffinbox.kitchen.Mdc;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The MDC claims of this unit, asserted rather than eyeballed.
 *
 * <p>ListAppender is Logback's own in-memory appender: it keeps every event it is handed,
 * with its MDC map attached, so a test can read what WOULD have been rendered without
 * parsing a rendered line. The pool is a single thread and every task is waited for, so
 * nothing here is a race.
 */
class MdcTest {

    private final ListAppender<ILoggingEvent> captured = new ListAppender<>();
    private Logger kitchen;

    @BeforeEach
    void attach() {
        kitchen = (Logger) LoggerFactory.getLogger("kitchen");
        captured.start();
        kitchen.addAppender(captured);
        MDC.clear();
    }

    @AfterEach
    void detach() {
        kitchen.detachAppender(captured);
        MDC.clear();
    }

    private String idOf(int index) {
        return captured.list.get(index).getMDCPropertyMap().get("orderId");
    }

    @Test
    void theIdIsOnEveryLineTheThreadWritesAndOnNoOther() {
        MDC.put("orderId", "A-4417");
        kitchen.info("accepted");
        kitchen.info("cooking");
        MDC.remove("orderId");
        kitchen.info("end of service");

        assertThat(captured.list).hasSize(3);
        assertThat(idOf(0)).isEqualTo("A-4417");
        assertThat(idOf(1)).isEqualTo("A-4417");
        assertThat(idOf(2)).isNull();
    }

    @Test
    void aPlainSubmitLosesTheIdAtTheThreadBoundary() throws Exception {
        try (ExecutorService pool = Executors.newSingleThreadExecutor()) {
            MDC.put("orderId", "A-4417");
            kitchen.info("accepted");
            pool.submit(() -> { kitchen.info("cooking"); return null; }).get();
        }
        assertThat(idOf(0)).isEqualTo("A-4417");
        assertThat(idOf(1)).isNull();          // the pool thread never had it
    }

    @Test
    void carryingMovesTheIdAcrossAndDoesNotLeaveItBehind() throws Exception {
        try (ExecutorService pool = Executors.newSingleThreadExecutor()) {
            MDC.put("orderId", "A-4417");
            pool.submit(Mdc.carrying(() -> { kitchen.info("cooking Arun"); return null; })).get();
            MDC.remove("orderId");
            // the SAME pooled thread, now with nothing in the caller's context
            pool.submit(Mdc.carrying(() -> { kitchen.info("cooking Bela"); return null; })).get();
        }
        assertThat(idOf(0)).isEqualTo("A-4417");
        assertThat(idOf(1)).isNull();          // and not A-4417, which is the dangerous answer
    }
}
