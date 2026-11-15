package probe.b.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

/** The write path's pause on w_pause: SEQUENCE ids (w_pause_seq, by 50), its customer the owning side of the foreign key. */
@Entity
@Table(name = "w_pause")
public class WPause {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "wp")
    @SequenceGenerator(name = "wp", sequenceName = "w_pause_seq", allocationSize = 50)
    Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id")
    WCustomer customer;
    int days;

    protected WPause() { }

    public WPause(WCustomer customer, int days) { this.customer = customer; this.days = days; }
}
