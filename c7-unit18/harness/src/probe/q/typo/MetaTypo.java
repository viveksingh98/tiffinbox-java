package probe.q.typo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntity_;
import org.springframework.data.jpa.domain.Specification;

/**
 * The metamodel's typo, typed: the generated CustomerEntity_ has no field nmae, so javac refuses this file. It is compiled on
 * its own, never into the harness (meta's javac refusal).
 */
public final class MetaTypo {
    private MetaTypo() {
    }

    public static Specification<CustomerEntity> byName(String name) {
        return (r, q, cb) -> cb.equal(r.get(CustomerEntity_.nmae), name);
    }
}
