package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Billing's one implementation: saves, then fails, inside its own transaction. */
@Service
public class BillingImpl implements Billing {
    final CustomerEntityRepository repo;

    BillingImpl(CustomerEntityRepository repo) { this.repo = repo; }

    @Override
    @Transactional
    public void saveAndFail(String name) {
        H.p("  inside BillingImpl.saveAndFail: " + H.tx());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new H.Boom("billing failed after the save of " + name);
    }
}
