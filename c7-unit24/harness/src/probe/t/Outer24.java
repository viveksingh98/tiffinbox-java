package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * run(method, mode) - @Transactional (REQUIRED): saves Asha, calls the inner bean's method named method THROUGH THE INNER BEAN'S PROXY
 * (the field the context injected: one branch per propagation, the dispatch here, never inside the inner bean), then fails
 * ("outer-fails") or catches the inner's failure and returns ("inner-fails"). call(method, fail) is the dispatch, and records what
 * the inner did - returned, failed (its own Boom) or refused <class> (the manager's refusal) - in H.outcome.
 */
@Service
public class Outer24 {
    private final CustomerEntityRepository repo;
    private final Inner24 inner;

    Outer24(CustomerEntityRepository repo, Inner24 inner) { this.repo = repo; this.inner = inner; }

    @Transactional
    public void run(String method, String mode) {
        H.p("  inside outer: " + H.tx());
        repo.save(new CustomerEntity("Asha", 1, 100, MealType.VEG));
        if (mode.equals("outer-fails")) {
            call(method, false);
            throw new H.Boom("outer failed after the inner " + method + " returned");
        }
        try {
            call(method, true);
        } catch (RuntimeException e) {
            H.p("  outer caught: " + e.getClass().getName() + ": " + H.flat(e.getMessage()) + " · " + H.tx());
        }
    }

    public void call(String method, boolean fail) {
        try {
            switch (method) {
                case "required" -> inner.required(fail);
                case "requiresNew" -> inner.requiresNew(fail);
                case "nested" -> inner.nested(fail);
                case "supports" -> inner.supports(fail);
                case "notSupported" -> inner.notSupported(fail);
                case "mandatory" -> inner.mandatory(fail);
                case "never" -> inner.never(fail);
                default -> throw new IllegalArgumentException("no inner method " + method);
            }
            H.outcome = "returned";
        } catch (RuntimeException e) {
            H.outcome = e instanceof H.Boom ? "failed" : "refused " + e.getClass().getSimpleName();
            throw e;
        }
    }
}
