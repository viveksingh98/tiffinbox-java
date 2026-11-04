package probe.map.cascade;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

/** A pause of OrphanCustomer's: days, and the customer it belongs to (the owning side, customer_id; nullable, as Hibernate's default). */
@Entity
public class OrphanPause implements Kid {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int days;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id")
    private OrphanCustomer customer;

    protected OrphanPause() { }
    public OrphanPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public int getDays() { return days; }
    public Object getCustomer() { return customer; }
    public void attach(Object customer) { this.customer = (OrphanCustomer) customer; }
}
