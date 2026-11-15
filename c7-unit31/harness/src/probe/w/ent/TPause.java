package probe.w.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** A pause of TCustomer's: the anchor's own pause table. */
@Entity
@Table(name = "pause")
public class TPause {
    @Id Long id;
    int days;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") TCustomer customer;

    public int getDays() { return days; }
}
