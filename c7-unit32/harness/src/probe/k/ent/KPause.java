package probe.k.ent;

import jakarta.persistence.Cacheable;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

/** The anchor's pause table, mapped by the harness and cached (@Cacheable, @Cache READ_WRITE): a cached collection's elements. */
@Entity
@Table(name = "pause")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class KPause {
    @Id
    Long id;
    int days;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    KCustomer customer;

    public int getDays() { return days; }
}
