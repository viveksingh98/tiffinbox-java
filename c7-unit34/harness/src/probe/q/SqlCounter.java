package probe.q;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

/**
 * The second witness: one count per event of Hibernate's SQL logger, org.hibernate.SQL - one per statement it sends; the texts kept,
 * in order. And the slow-query logger, org.hibernate.SQL_SLOW: its events counted, and the smallest time one of them reports kept.
 */
public class SqlCounter extends AppenderBase<ILoggingEvent> {
    public static final AtomicInteger sql = new AtomicInteger(), slow = new AtomicInteger();
    public static volatile long slowMin = Long.MAX_VALUE;
    public static final List<String> texts = new ArrayList<>();
    static final Pattern TOOK = Pattern.compile("^Slow query took (\\d+) milliseconds ");

    @Override
    protected void append(ILoggingEvent e) {
        if (e.getLoggerName().equals("org.hibernate.SQL")) {
            sql.incrementAndGet();
            synchronized (texts) { texts.add(e.getFormattedMessage().strip().replaceAll("\\s+", " ")); }
        } else if (e.getLoggerName().equals("org.hibernate.SQL_SLOW")) {
            slow.incrementAndGet();
            var m = TOOK.matcher(e.getFormattedMessage());
            if (m.find()) slowMin = Math.min(slowMin, Long.parseLong(m.group(1)));
        }
    }
}
