package com.tiffinbox;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.classic.spi.LoggingEvent;
import net.logstash.logback.encoder.LogstashEncoder;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * What the encoder actually writes, asserted on the bytes rather than read off a screen.
 *
 * <p>The encoder is driven directly - no appender, no file - so these three assertions are
 * about the ENCODING and nothing else.
 */
class JsonEventTest {

    private LogstashEncoder encoder;
    private LoggerContext context;

    @BeforeEach
    void start() {
        context = (LoggerContext) LoggerFactory.getILoggerFactory();
        encoder = new LogstashEncoder();
        encoder.setContext(context);
        encoder.start();
        MDC.clear();
    }

    @AfterEach
    void stop() {
        encoder.stop();
        MDC.clear();
    }

    private String encode(Level level, String message, Throwable t) {
        var event = new LoggingEvent();
        event.setLoggerName("kitchen");
        event.setLevel(level);
        event.setMessage(message);
        event.setThreadName("main");
        event.setTimeStamp(System.currentTimeMillis());
        event.setMDCPropertyMap(Map.copyOf(MDC.getCopyOfContextMap() == null ? Map.of() : MDC.getCopyOfContextMap()));
        if (t != null) {
            event.setThrowableProxy(new ch.qos.logback.classic.spi.ThrowableProxy(t));
        }
        ILoggingEvent e = event;
        return new String(encoder.encode(e), StandardCharsets.UTF_8);
    }

    @Test
    void everyMdcEntryBecomesATopLevelKey() {
        MDC.put("orderId", "B-9082");
        String json = encode(Level.WARN, "kitchen is behind - 12 slips waiting", null);

        assertThat(json).contains("\"orderId\":\"B-9082\"");
        assertThat(json).contains("\"level\":\"WARN\"");
        // the delimiter that breaks a text layout is just a character inside a string here
        assertThat(json).contains("\"message\":\"kitchen is behind - 12 slips waiting\"");
    }

    @Test
    void anAbsentMdcEntryIsAnAbsentKeyNotAnEmptyOne() {
        String json = encode(Level.INFO, "end of service", null);

        assertThat(json).doesNotContain("orderId");
        assertThat(json).contains("\"message\":\"end of service\"");
    }

    @Test
    void aStackTraceIsOneFieldOnOneLine() {
        MDC.put("orderId", "B-9082");
        String json = encode(Level.ERROR, "could not cook", new IllegalStateException("rail jammed"));

        assertThat(json).contains("\"stack_trace\":");
        assertThat(json).contains("rail jammed");
        // one object, one physical line - the newlines inside the trace are escaped
        assertThat(json.strip().lines().count()).isEqualTo(1L);
        assertThat(json).contains("\\n\\tat ");
    }
}
