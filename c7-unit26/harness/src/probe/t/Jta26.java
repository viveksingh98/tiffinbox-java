package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.stereotype.Service;

/** The JTA annotation, jakarta.transaction.Transactional (on the class path through Hibernate), instead of Spring's. */
@Service
public class Jta26 {
    final CustomerEntityRepository repo;

    Jta26(CustomerEntityRepository repo) { this.repo = repo; }

    void save(String n) {
        repo.save(new CustomerEntity(n, 1, 100, MealType.VEG));
        H.p("  inside, after the save of " + n + ": " + H.tx());
    }

    @jakarta.transaction.Transactional
    public void checked(String n) throws H.CheckedBoom { save(n); throw new H.CheckedBoom("checked, JTA annotation, after saving " + n); }

    @jakarta.transaction.Transactional
    public void runtime(String n) { save(n); throw new H.Boom("runtime, JTA annotation, after saving " + n); }

    @jakarta.transaction.Transactional(rollbackOn = Exception.class)
    public void checkedRollbackOn(String n) throws H.CheckedBoom { save(n); throw new H.CheckedBoom("checked, JTA rollbackOn = Exception.class, after saving " + n); }
}
