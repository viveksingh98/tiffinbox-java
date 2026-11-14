package probe.u.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** The anchor's pause table, as ECustomer's pauses. */
@Entity
@Table(name = "pause")
public class EPause {
    @Id Long id;
    int days;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") ECustomer customer;

    public int getDays() { return days; }
}
