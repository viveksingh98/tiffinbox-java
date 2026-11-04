package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

/** The exercise's pause: the owning side - customer_id is written from its customer. */
@Entity
public class ExPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne
    @JoinColumn(name = "customer_id")
    private ExCustomer customer;
    private int days;

    protected ExPause() { }
    public ExPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public ExCustomer getCustomer() { return customer; }
    public void setCustomer(ExCustomer customer) { this.customer = customer; }
    public int getDays() { return days; }
}
