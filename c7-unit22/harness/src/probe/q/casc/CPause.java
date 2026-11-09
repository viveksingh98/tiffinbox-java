package probe.q.casc;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** The harness's own pause, on c_pause: the owning side of CCustomer's pauses (its customer_id is the foreign key). */
@Entity
@Table(name = "c_pause")
public class CPause {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id")
    public CCustomer customer;

    public int days;

    protected CPause() {
    }

    public CPause(CCustomer customer, int days) {
        this.customer = customer;
        this.days = days;
        customer.pauses.add(this);
    }
}
