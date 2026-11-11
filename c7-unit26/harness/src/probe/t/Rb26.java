package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

/** The rules: each method saves one customer through the shipped repository, prints its own transaction, then ends as its name says. */
@Service
public class Rb26 {
    final CustomerEntityRepository repo;
    final EntityManager em;

    Rb26(CustomerEntityRepository repo, EntityManager em) { this.repo = repo; this.em = em; }

    void save(String n) {
        repo.save(new CustomerEntity(n, 1, 100, MealType.VEG));
        H.p("  inside, after the save of " + n + ": " + H.tx());
    }

    @Transactional
    public void checked(String n) throws H.CheckedBoom { save(n); throw new H.CheckedBoom("checked, after saving " + n); }

    @Transactional(rollbackFor = Exception.class)
    public void checkedRollbackFor(String n) throws H.CheckedBoom { save(n); throw new H.CheckedBoom("checked, rollbackFor = Exception.class, after saving " + n); }

    @Transactional
    public void runtime(String n) { save(n); throw new H.Boom("runtime, after saving " + n); }

    @Transactional(noRollbackFor = H.Boom.class)
    public void runtimeNoRollbackFor(String n) { save(n); throw new H.Boom("runtime, noRollbackFor = Boom.class, after saving " + n); }

    @Transactional
    public void error(String n) { save(n); throw new AssertionError("an Error, after saving " + n); }

    @Transactional
    public void caught(String n) {
        save(n);
        try { throw new H.Boom("thrown and caught inside, after saving " + n); } catch (H.Boom e) { H.p("  caught inside: " + e.getMessage()); }
    }

    @Transactional
    public void rollbackOnly(String n) {
        save(n);
        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        H.p("  setRollbackOnly() called; the method returns normally");
    }

    /** two writes: a customer, then something checked fails before her pause is written */
    @Transactional
    public void twoWrites(String n) throws java.io.IOException {
        var c = repo.save(new CustomerEntity(n, 1, 100, MealType.VEG));
        H.p("  customer " + n + " saved, then the pause file is read: " + H.tx());
        readPauseFile();
        em.persist(new PauseEntity(c, 2));
    }

    @Transactional(rollbackFor = Exception.class)
    public void twoWritesRollbackFor(String n) throws java.io.IOException {
        var c = repo.save(new CustomerEntity(n, 1, 100, MealType.VEG));
        H.p("  customer " + n + " saved, then the pause file is read: " + H.tx());
        readPauseFile();
        em.persist(new PauseEntity(c, 2));
    }

    void readPauseFile() throws java.io.IOException {
        throw new java.io.FileNotFoundException("pauses.csv (the pause file is missing)");
    }
}
