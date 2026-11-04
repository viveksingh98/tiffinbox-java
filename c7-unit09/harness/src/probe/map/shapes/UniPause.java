package probe.map.shapes;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/** A pause that knows nothing of its customer (shape 1): its table still holds the customer_id the customer's list names. */
@Entity
public class UniPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int days;

    protected UniPause() { }
    public UniPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public int getDays() { return days; }
}
