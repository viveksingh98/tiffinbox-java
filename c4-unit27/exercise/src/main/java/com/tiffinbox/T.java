package com.tiffinbox;

/** Thread names, with the counter masked (contract 2g): the prefix is a fact, the number is not. */
final class T {
    private T() { }
    static String name() {
        Thread t = Thread.currentThread();
        String n = t.getName().replaceAll("\\d+$", "<n>");
        return (n.isEmpty() ? "(unnamed)" : n) + (t.isVirtual() ? " [virtual]" : "");
    }
}
