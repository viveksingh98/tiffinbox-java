package com.tiffinbox;

/** The one the tests use. No database, no connection, no cleanup. */
public class InMemoryRail implements Rail {
    @Override public String describe() { return "in-memory rail (a queue in this JVM)"; }
}
