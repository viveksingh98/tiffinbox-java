package probe.t.ev;

import com.tiffinbox.CustomerAdded;
import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import probe.t.H;

/**
 * Three listeners for the harness's Added - a plain @EventListener, one after the commit, one after a rollback - and one, after
 * the commit, for the anchor's own CustomerAdded (what CustomerFeed hears). Each prints its thread, the transaction's state and
 * the second connection's read of the row, inside the listener (S4.10). The after-commit listener throws for Omar: the second
 * system that fails after the database committed. @Order fixes the order in which publishEvent calls them - the plain listener
 * first, then the transactional ones register for the commit - which is otherwise not fixed (the brief's hazard).
 */
@Component
public class FeedListeners {
    @EventListener
    @Order(1)
    void plain(Added e) {
        H.p("  @EventListener heard " + e.name() + " · " + H.where() + " · the second connection sees the row " + H.has(e.name()));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Order(2)
    void afterCommit(Added e) {
        H.p("  @TransactionalEventListener(AFTER_COMMIT) heard " + e.name() + " · " + H.where() + " · the second connection sees the row "
            + H.has(e.name()));
        if (e.name().equals("Omar")) throw new IllegalStateException("the second system is down (it could not be told about Omar)");
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_ROLLBACK)
    @Order(2)
    void afterRollback(Added e) {
        H.p("  @TransactionalEventListener(AFTER_ROLLBACK) heard " + e.name() + " · " + H.where() + " · the second connection sees the row "
            + H.has(e.name()));
    }

    @TransactionalEventListener
    @Order(2)
    void customerAdded(CustomerAdded e) {
        H.p("  @TransactionalEventListener heard the anchor's CustomerAdded(" + e.customer().name() + ") · " + H.where()
            + " · the second connection sees the row " + H.has(e.customer().name()));
    }
}
