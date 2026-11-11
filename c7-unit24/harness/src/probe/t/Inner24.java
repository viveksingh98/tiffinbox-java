package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * One method per propagation, each @Transactional with its own: each prints its TransactionSynchronizationManager line, saves Dev
 * through the shipped repository, then fails when it is asked to. Nothing here calls another method of this bean: every call comes in
 * through the proxy, from Outer24.
 */
@Service
public class Inner24 {
    private final CustomerEntityRepository repo;

    Inner24(CustomerEntityRepository repo) { this.repo = repo; }

    void body(String p, boolean fail) {
        H.p("  inside inner " + p + ": " + H.tx());
        repo.save(new CustomerEntity("Dev", 1, 100, MealType.VEG));
        if (fail) throw new H.Boom("inner " + p + " failed after the save of Dev");
    }

    @Transactional(propagation = Propagation.REQUIRED) public void required(boolean fail) { body("REQUIRED", fail); }
    @Transactional(propagation = Propagation.REQUIRES_NEW) public void requiresNew(boolean fail) { body("REQUIRES_NEW", fail); }
    @Transactional(propagation = Propagation.NESTED) public void nested(boolean fail) { body("NESTED", fail); }
    @Transactional(propagation = Propagation.SUPPORTS) public void supports(boolean fail) { body("SUPPORTS", fail); }
    @Transactional(propagation = Propagation.NOT_SUPPORTED) public void notSupported(boolean fail) { body("NOT_SUPPORTED", fail); }
    @Transactional(propagation = Propagation.MANDATORY) public void mandatory(boolean fail) { body("MANDATORY", fail); }
    @Transactional(propagation = Propagation.NEVER) public void never(boolean fail) { body("NEVER", fail); }
}
