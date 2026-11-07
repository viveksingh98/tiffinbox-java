package probe.q.repo;

import java.util.List;

/** A nested projection: the customer's name and its pauses, each pause as another projection, DaysOnly. */
public interface WithPauses {
    String getName();

    List<DaysOnly> getPauses();

    /** A pause, its days alone. */
    interface DaysOnly {
        int getDays();
    }
}
