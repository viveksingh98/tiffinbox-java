package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The bean whose proxy the lesson prints: one call (saveOk), the self-invocation trap (outer -> this.inner) and its fix on the outer
 * method (outerTx), and @Transactional on a protected, a package-private and a private method. Each method prints what
 * TransactionSynchronizationManager says inside it (S4.1), and the methods that fail save first, then throw.
 */
@Service
public class Svc23 {
    final CustomerEntityRepository repo;

    public Svc23(CustomerEntityRepository repo) {
        this.repo = repo;
    }

    /** one call, one transaction: saves and returns */
    @Transactional
    public void saveOk(String name) {
        H.p("  inside saveOk: " + H.tx());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
    }

    /** saves, then fails */
    @Transactional
    public void inner(String name) {
        H.p("  inside inner: " + H.tx());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new H.Boom("inner failed after the save of " + name);
    }

    /** the trap: no annotation here, and the call to inner never leaves this object */
    public void outer(String name) {
        H.p("  inside outer: " + H.tx());
        this.inner(name);
    }

    /** the fix on the outer method: it carries the annotation */
    @Transactional
    public void outerTx(String name) {
        H.p("  inside outerTx: " + H.tx());
        this.inner(name);
    }

    @Transactional
    protected void protInner(String name) {
        H.p("  inside protInner: " + H.tx());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new H.Boom("protInner failed after the save of " + name);
    }

    @Transactional
    void pkgInner(String name) {
        H.p("  inside pkgInner: " + H.tx());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new H.Boom("pkgInner failed after the save of " + name);
    }

    @Transactional
    private void privInner(String name) {
        H.p("  inside privInner: " + H.tx() + " · this.repo " + (repo == null ? "null" : "set") + " · this.getClass() " + getClass().getName());
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new H.Boom("privInner failed after the save of " + name);
    }

    /** a nestmate (Caller23 is not one: this static method is) calling the private method on the PROXY reference it was given */
    static void callPrivateOn(Svc23 proxy, String name) {
        proxy.privInner(name);
    }
}
