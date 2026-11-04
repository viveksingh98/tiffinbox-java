package probe.map.own;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** The shipped pause table, mapped A - the owning side: customer_id is written from this field. */
@Entity
@Table(name = "pause")
public class BiOwnPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(optional = false)
    @JoinColumn(name = "customer_id")
    private BiOwnCustomer customer;
    private int days;

    protected BiOwnPause() { }
    public BiOwnPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public void setCustomer(BiOwnCustomer customer) { this.customer = customer; }
    public int getDays() { return days; }
}
