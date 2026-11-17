package probe.u01;

import org.hibernate.Interceptor;
import org.hibernate.type.Type;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Unit 01's flush counter: a Hibernate Interceptor named by hibernate.session_factory.interceptor (the harness's command line, never
 * the anchor's YAML). Hibernate calls findDirty once for every entity the persistence context holds when a flush runs its dirty
 * check; returning null keeps Hibernate's own comparison. The count is read before and after the commit, so the commit's own
 * flush is the difference - RED #6's method, re-run on the data line 40 · 38 · 77.
 */
public class DirtyCount implements Interceptor {
    static final AtomicInteger CALLS = new AtomicInteger();

    @Override
    public int[] findDirty(Object entity, Object id, Object[] currentState, Object[] previousState, String[] propertyNames, Type[] types) {
        CALLS.incrementAndGet();
        return null;
    }
}
