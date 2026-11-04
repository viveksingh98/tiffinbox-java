package probe.map.cascade;

import java.util.List;

/** A customer, whichever cascade her pauses carry: her id, the collection Hibernate manages, and a setter that replaces it. */
public interface Parent {
    Long getId();
    List<Kid> getPauses();
    void setPauses(List<Kid> pauses);
}
