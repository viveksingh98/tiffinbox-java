package probe.map.own;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** The shipped pause table, mapped by a pause that knows nothing of its customer (B, B2, C): the customer's list owns customer_id. */
@Entity
@Table(name = "pause")
public class OwnPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int days;

    protected OwnPause() { }
    public OwnPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public int getDays() { return days; }
}
