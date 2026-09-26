package com.tiffinbox;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * PITFALL TWO - the same job, throwing on its second run, on the SAME kind of JDK executor twice. With no
 * scheduler bean, Spring's default IS a JDK single-thread scheduled executor; what Spring adds is a wrapper
 * around your job that catches the exception, logs it at SEVERE, and lets the schedule carry on. Called
 * directly, the JDK's scheduleAtFixedRate has no such wrapper: the schedule stops for ever, and prints nothing.
 * (Renamed from TwoSchedulers after the section's RED review: the variable is the wrapper, not the scheduler.)
 */
public final class WrappedOrNot {
    private WrappedOrNot() { }
    static final AtomicInteger springRuns = new AtomicInteger(), jdkRuns = new AtomicInteger();
    static volatile String springThread = "?", jdkThread = "?";
    static void tick(AtomicInteger n) { if (n.incrementAndGet() == 2) throw new IllegalStateException("the till jammed on run 2"); }
    static String masked() { return Thread.currentThread().getName().replaceAll("\\d+", "<n>"); }
    public static class Job { @Scheduled(fixedRate = 100) public void tick() { springThread = masked(); WrappedOrNot.tick(springRuns); } }
    @Configuration @EnableScheduling static class Cfg { @Bean Job job() { return new Job(); } }

    public static void main(String[] a) throws Exception {
        System.out.println("through Spring's @Scheduled (your job inside Spring's catch-and-log wrapper), throwing on run 2:");
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) { Thread.sleep(700); }
        System.out.println("  thread: " + springThread + "   runs in 0.7 s: "
                + (springRuns.get() > 3 ? "MORE than 3 - it kept going" : "3 or fewer - it stopped"));

        System.out.println("the same job on the JDK's scheduleAtFixedRate directly - no wrapper:");
        ByteArrayOutputStream printed = new ByteArrayOutputStream();
        PrintStream out = System.out, err = System.err;
        System.setOut(new PrintStream(printed, true)); System.setErr(new PrintStream(printed, true));
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ScheduledFuture<?> f = ses.scheduleAtFixedRate(() -> { jdkThread = masked(); tick(jdkRuns); }, 0, 100, TimeUnit.MILLISECONDS);
        Thread.sleep(700);
        System.setOut(out); System.setErr(err);
        System.out.println("  thread: " + jdkThread + "   runs in 0.7 s: " + jdkRuns.get()
                + "   printed while it ran: " + (printed.size() == 0 ? "nothing" : printed.size() + " bytes")
                + "   future done? " + f.isDone());
        ses.shutdownNow();
    }
}
