package probe.u;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.PauseEntity;
import org.hibernate.Hibernate;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;

/** The page's read, as the anchor's pausedDaysByCustomer does it: every customer by name, her pauses summed - three ways. */
@Component
public class Svc {
    final CustomerEntityRepository repo;

    Svc(CustomerEntityRepository repo) { this.repo = repo; }

    /** No transaction of its own: the repository's ends inside findAll. */
    public Map<String, Integer> plain() {
        H.p("plain(): " + H.tx());
        return sum(false);
    }

    @Transactional(readOnly = true)
    public Map<String, Integer> inTx() {
        H.p("inTx(): " + H.tx());
        return sum(false);
    }

    @Transactional(readOnly = true)
    public Map<String, Integer> initialized() {
        H.p("initialized(): " + H.tx());
        return sum(true);
    }

    Map<String, Integer> sum(boolean init) {
        var out = new LinkedHashMap<String, Integer>();
        for (CustomerEntity e : repo.findAll(Sort.by("name"))) {
            if (init) Hibernate.initialize(e.getPauses());
            out.put(e.getName(), e.getPauses().stream().mapToInt(PauseEntity::getDays).sum());
        }
        return out;
    }
}
