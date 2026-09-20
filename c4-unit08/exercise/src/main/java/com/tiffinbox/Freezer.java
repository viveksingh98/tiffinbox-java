package com.tiffinbox;

/**
 * The walk-in freezer. It is opened at startup and has to be emptied and shut when TiffinBox
 * closes for the night, or the stock is lost.
 *
 * <p>The context starts. Nothing is logged. Do not change this file.
 */
public class Freezer implements AutoCloseable {

    static int emptied;
    static int shut;

    @jakarta.annotation.PreDestroy
    void empty() { emptied++; }

    @Override public void close() { shut++; }
}
