package probe.v.repo;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.repository.Repository;

import java.util.List;

/**
 * Course 7 unit 19's projections, over the anchor's own CustomerEntity: the nested one (a customer's name and its pauses, each pause
 * as another projection) and the flat one (the name alone).
 */
public interface Proj extends Repository<CustomerEntity, Long> {
    List<WithPauses> findAllProjectedByOrderByNameAsc();

    List<NameOnly> findAllNamesByOrderByNameAsc();

    /** A nested projection: the customer's name and its pauses, each pause as another projection, DaysOnly. */
    interface WithPauses {
        String getName();

        List<DaysOnly> getPauses();

        /** A pause, its days alone. */
        interface DaysOnly {
            int getDays();
        }
    }

    /** A flat projection: the name alone. */
    interface NameOnly {
        String getName();
    }
}
