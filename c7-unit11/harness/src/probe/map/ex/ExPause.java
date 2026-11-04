package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

/** The exercise's pause: days, and the customer it belongs to. */
@Entity
public class ExPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int days;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id")
    private ExCustomer customer;

    protected ExPause() { }
    public ExPause(ExCustomer customer, int days) { this.customer = customer; this.days = days; }
    public Long getId() { return id; }
    public int getDays() { return days; }
}
