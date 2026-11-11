package probe.t.ev;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import probe.t.H;

/** Saves through the shipped repository and publishes Added: inside a transaction of its own, or with none. */
@Service
public class FeedSvc {
    final CustomerEntityRepository repo;
    final ApplicationEventPublisher events;

    FeedSvc(CustomerEntityRepository repo, ApplicationEventPublisher events) {
        this.repo = repo;
        this.events = events;
    }

    /** saves, publishes, and fails afterwards when asked - inside one transaction */
    @Transactional
    public void add(String name, boolean fail) {
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        H.p("  publishing Added(" + name + ") · " + H.where());
        events.publishEvent(new Added(name));
        H.p("  publishEvent returned");
        if (fail) throw new H.Boom("add failed after publishing " + name);
    }

    /** no transaction of its own: save's has ended when it publishes */
    public void addNoTx(String name) {
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        H.p("  publishing Added(" + name + ") with no transaction · " + H.where());
        events.publishEvent(new Added(name));
        H.p("  publishEvent returned");
    }
}
