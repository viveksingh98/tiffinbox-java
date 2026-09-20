package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * One driver's trip out of the kitchen: it is created when a van leaves, it accumulates the
 * stops made on that trip, and it is finished when the van comes back.
 *
 * <p>Nothing about this object is shareable. Two trips are two objects — which is exactly the
 * assumption the container is about to ignore.
 */
public final class DeliveryRun {

    private static final AtomicInteger BUILT = new AtomicInteger();

    private final int runId;
    private final List<String> stops = new ArrayList<>();

    public DeliveryRun() {
        this.runId = BUILT.incrementAndGet();
    }

    public int runId() { return runId; }

    public DeliveryRun stop(String customer) { stops.add(customer); return this; }

    public List<String> stops() { return List.copyOf(stops); }

    /** DERIVED: how many DeliveryRun objects this JVM has ever constructed. */
    public static int built() { return BUILT.get(); }
}
