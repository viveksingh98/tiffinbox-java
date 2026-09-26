package com.tiffinbox;

/**
 * Somebody configured load-time weaving and swears it works: the agent is on the command line and the
 * warnings print. Run this WITH the agent. Then decide, from the numbers - not from the warnings -
 * whether anything was woven, and fix META-INF/aop.xml until priceTwice() runs the advice twice.
 */
public class Proof {
    public static void main(String[] a) {
        Kitchen k = new Kitchen();
        Counter.hits = 0; k.priceTwice("Ravi");
        System.out.println("priceTwice(): advice ran " + Counter.hits + "   (want 2)");
    }
}
