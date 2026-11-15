package probe.b.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

/** The harness's SEQUENCE entity on x_seq: ids from x_seq_seq, fifty per call (allocationSize = INCREMENT BY 50), known before the INSERT. */
@Entity
@Table(name = "x_seq")
public class XSeq {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "xs")
    @SequenceGenerator(name = "xs", sequenceName = "x_seq_seq", allocationSize = 50)
    Long id;
    String name;
    int mealsPerDay;

    protected XSeq() { }

    public XSeq(String name, int mealsPerDay) { this.name = name; this.mealsPerDay = mealsPerDay; }
}
