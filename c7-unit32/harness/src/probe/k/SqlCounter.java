package probe.k;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/** The second witness: one count per event of Hibernate's SQL logger, org.hibernate.SQL - one per statement it sends; the texts kept. */
public class SqlCounter extends AppenderBase<ILoggingEvent> {
    public static final AtomicInteger sql = new AtomicInteger();
    public static final List<String> texts = new ArrayList<>();

    @Override
    protected void append(ILoggingEvent e) {
        if (e.getLoggerName().equals("org.hibernate.SQL")) {
            sql.incrementAndGet();
            synchronized (texts) { texts.add(e.getFormattedMessage().strip().replaceAll("\\s+", " ")); }
        }
    }
}
