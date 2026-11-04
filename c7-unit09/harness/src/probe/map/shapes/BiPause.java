package probe.map.shapes;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

/** The owning side of shape 3: the foreign key column, customer_id, is written from this field. */
@Entity
public class BiPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne
    @JoinColumn(name = "customer_id")
    private BiCustomer customer;
    private int days;

    protected BiPause() { }
    public BiPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public BiCustomer getCustomer() { return customer; }
    public void setCustomer(BiCustomer customer) { this.customer = customer; }
    public int getDays() { return days; }
}
