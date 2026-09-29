package demo;

import java.util.List;

/**
 * What the harness calls. An interface on purpose: the container can stand in for an interface in two ways - a JDK
 * proxy that implements it, or a generated subclass of the class behind it - and which one you get is a default Boot
 * flips (spring.aop.proxy-target-class). The harness prints which one it got.
 */
public interface Kitchen {

    /** Cooks one order. The implementation marks it @Async, so it runs on whatever executor Spring picked. */
    void cook(int order);

    /** Waits until every order has been cooked, then returns the names of the threads that cooked them, sorted. */
    List<String> threadsUsed() throws InterruptedException;
}
