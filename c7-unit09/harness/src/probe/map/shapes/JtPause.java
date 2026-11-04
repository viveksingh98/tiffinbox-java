package probe.map.shapes;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/** A pause that knows nothing of its customer (shape 2): its table has no customer column at all. */
@Entity
public class JtPause {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int days;

    protected JtPause() { }
    public JtPause(int days) { this.days = days; }
    public Long getId() { return id; }
    public int getDays() { return days; }
}
