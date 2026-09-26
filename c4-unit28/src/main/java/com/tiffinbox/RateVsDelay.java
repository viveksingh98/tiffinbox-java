package com.tiffinbox;

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

    static List<Long> run(Class<?> job) throws Exception {
        Firings.reset(4);
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(C.class, job); ctx.refresh();
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
    }
}
