package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * Unit 27's edits, each one transaction through this bean's proxy (Spring's @Transactional, the lesson's own tool). edit loads a
 * customer by id through the anchor's CustomerEntityRepository, prints what it loaded, may signal a latch and wait on another (the
 * race's order - never a sleep, S4.18), adds to its meals and returns: Hibernate's dirty check writes the UPDATE when the proxy
 * commits, after this method returned. lock loads with a lock mode and changes nothing.
 */
@Service
public class Edit27 {
    private final CustomerEntityRepository repo;

    @PersistenceContext
    private EntityManager em;

    Edit27(CustomerEntityRepository repo) {
        this.repo = repo;
    }

    @Transactional
    public int edit(long id, int plus, CountDownLatch loaded, CountDownLatch go) throws InterruptedException {
        String who = Thread.currentThread().getName();
        CustomerEntity c = repo.findById(id).orElseThrow();
        H.p(who + " loaded " + c.getName() + " · mealsPerDay " + c.getMealsPerDay() + H.ver(c) + " · " + H.tx());
        if (loaded != null) loaded.countDown();
        if (go != null && !go.await(60, TimeUnit.SECONDS)) throw new IllegalStateException(who + ": the other edit never committed");
        c.setMealsPerDay(c.getMealsPerDay() + plus);
        H.p(who + " sets mealsPerDay " + c.getMealsPerDay() + " and returns - the commit follows");
        return c.getMealsPerDay();
    }

    @Transactional
    public String lock(long id, LockModeType mode) {
        CustomerEntity c = em.find(CustomerEntity.class, id, mode);
        H.p("loaded " + c.getName() + " with " + mode + " · mealsPerDay " + c.getMealsPerDay() + H.ver(c) + " · no field changed · " + H.tx());
        return c.getName();
    }
}
