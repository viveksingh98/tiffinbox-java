package com.tiffinbox;

import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * The same job - 200 ms of work - asked for "every 300 ms" three ways. The gaps between STARTS are printed
 * raw, and then classified: THE CLAIM IS THE SHAPE, not any one number (contract 2f.1).
 */
public final class RateVsDelay {
    private RateVsDelay() { }
    static final int PERIOD = 300, WORK = 200;
    public static class Rate  { @Scheduled(fixedRate = PERIOD)  public void j() { Firings.job(WORK); } }
    public static class Delay { @Scheduled(fixedDelay = PERIOD) public void j() { Firings.job(WORK); } }
    public static class Over  { @Scheduled(fixedRate = PERIOD)  public void j() { Firings.job(500); } }
    @Configuration @EnableScheduling static class C { }
    /** A pool of FOUR scheduler threads (added after the section's RED review): does the pool size change the overlap rule? */
    @Configuration @EnableScheduling static class C4 {
        @Bean ThreadPoolTaskScheduler taskScheduler() {
            ThreadPoolTaskScheduler s = new ThreadPoolTaskScheduler(); s.setPoolSize(4); s.setThreadNamePrefix("four-"); return s;
        }
    }
    /** No @EnableScheduling at all. */
    @Configuration static class Off { }

    static List<Long> run(Class<?> job) throws Exception { return run(C.class, job); }
    static List<Long> run(Class<?> cfg, Class<?> job) throws Exception {
        Firings.reset(4);
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(cfg, job); ctx.refresh();
            Firings.finished.await(5, TimeUnit.SECONDS);          // close right after the 4th job ENDS
        }
        return Firings.gaps().subList(0, 3);
    }

    static String shape(List<Long> g, long target) {
        boolean all = g.stream().allMatch(x -> Math.abs(x - target) <= 40);
        return (all ? "every gap within 40 ms of " : "NOT every gap near ") + target;
    }

    public static void main(String[] args) throws Exception {
        List<Long> r = run(Rate.class), d = run(Delay.class);
        System.out.println("  fixedRate  = 300, job 200 ms   gaps between starts: " + r + "   -> " + shape(r, PERIOD));
        System.out.println("  fixedDelay = 300, job 200 ms   gaps between starts: " + d + "   -> " + shape(d, PERIOD + WORK));
        List<Long> o = run(Over.class);
        System.out.println("  fixedRate  = 300, job 500 ms   gaps between starts: " + o + "   -> " + shape(o, 500)
                + ", at most " + Firings.maxRunning + " running at once");
        List<Long> o4 = run(C4.class, Over.class);
        System.out.println("  the same, a POOL OF 4 threads  gaps between starts: " + o4 + "   -> " + shape(o4, 500)
                + ", at most " + Firings.maxRunning + " running at once");
        Firings.reset(4);
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(Off.class, Rate.class); ctx.refresh();
            Thread.sleep(1000);
        }
        System.out.println("  fixedRate  = 300 WITHOUT @EnableScheduling   firings in 1 s: " + Firings.starts.size());
    }
}
