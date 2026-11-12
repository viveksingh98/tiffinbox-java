package probe.t;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The harness's one appender, and the PROBE lines' path too: every line goes through emit(). Outside a two-thread part a line is
 * printed when it arrives. Inside one (on = true) the lines are kept, with their thread, in the one order they arrived; flush()
 * then prints them thread by thread - each thread's lines in their own order, which the latches fix - so the capture is the same
 * from run to run, and seq() answers where a line stands in that one order, from which the scenario derives the order between the
 * threads (S4.18: the order is read off the log, never typed). The labels: a PostgreSQL backend's pid, once its thread printed
 * it, is written as that thread's label wherever a message names the process ("Process <pid of T1>"); a transaction id as <xid>.
 */
public class Buf extends AppenderBase<ILoggingEvent> {
    static volatile boolean on = false;
    private static final List<String[]> kept = new ArrayList<>();
    static final Map<String, String> pids = new ConcurrentHashMap<>();
    private static final Pattern PROC = Pattern.compile("([Pp]rocess )(\\d+)");
    private static final Pattern XID = Pattern.compile("(ShareLock on transaction |ExclusiveLock on transaction )(\\d+)");

    @Override
    protected void append(ILoggingEvent e) {
        emit(e.getThreadName(), String.format("%-5s [%s] %s : %s", e.getLevel(), e.getThreadName(), e.getLoggerName(),
                                              H.flat(e.getFormattedMessage())));
    }

    static String label(String s) {
        Matcher m = PROC.matcher(s);
        StringBuilder b = new StringBuilder();
        while (m.find()) {
            String l = pids.get(m.group(2));
            m.appendReplacement(b, Matcher.quoteReplacement(m.group(1) + (l == null ? m.group(2) : "<pid of " + l + ">")));
        }
        m.appendTail(b);
        return XID.matcher(b.toString()).replaceAll("$1<xid>");
    }

    static synchronized void emit(String thread, String text) {
        text = label(text);
        if (on) kept.add(new String[] {thread, text});
        else { System.out.println(text); System.out.flush(); }
    }

    /** a line the receipt reads raw and takes out of the capture (the pids, for the server's log) - never kept, never labelled */
    static synchronized void raw(String text) {
        System.out.println(text);
        System.out.flush();
    }

    /** where the first line of this thread that holds this text stands in the one order (-1: none) */
    static synchronized int seq(String thread, String holds) {
        for (int i = 0; i < kept.size(); i++) if (kept.get(i)[0].equals(thread) && kept.get(i)[1].contains(holds)) return i;
        return -1;
    }

    /** prints the kept lines thread by thread, in the order given, each thread's in its own order; then forgets them */
    static synchronized void flush(String... threads) {
        on = false;
        for (String t : threads) {
            System.out.println("PROBE   the lines of thread " + t + ", in their own order:");
            for (String[] l : kept) if (l[0].equals(t)) System.out.println("    " + l[1]);
        }
        for (String[] l : kept) {
            boolean listed = false;
            for (String t : threads) listed |= l[0].equals(t);
            if (!listed) System.out.println("PROBE   a line of another thread: " + l[1]);
        }
        System.out.flush();
        kept.clear();
    }
}
