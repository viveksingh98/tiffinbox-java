package com.tiffinbox;

/**
 * No Spring at all. Plain objects made with `new`. Run it WITHOUT the agent and nothing can advise them;
 * run it WITH -javaagent:aspectjweaver and the aspect is woven into the classes themselves as they load.
 * Same program, one JVM flag of difference.
 */
public final class Limits {
    private Limits() { }

    static void report(String who, Kitchen k, FinalKitchen f) {
        System.out.println(who + ":");
        Counter.hits = 0; k.price("Ravi");      System.out.println("  one price() from outside            : advice ran " + Counter.hits);
        Counter.hits = 0; k.priceTwice("Ravi"); System.out.println("  priceTwice(), two calls INSIDE      : advice ran " + Counter.hits);
        Counter.hits = 0;
        try { f.price("Ravi");                  System.out.println("  the same price(), declared final    : advice ran " + Counter.hits); }
        catch (NullPointerException e) {        System.out.println("  the same price(), declared final    : advice ran " + Counter.hits
                                                        + ", then NullPointerException: " + e.getMessage()); }
    }

    public static void main(String[] a) {
        report("plain objects made with new, no Spring", new Kitchen(), new FinalKitchen());
    }
}
