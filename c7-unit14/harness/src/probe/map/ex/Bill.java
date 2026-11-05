package probe.map.ex;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** The exercise: a bill's amount - the column says two decimals; nothing refuses a third. */
@Entity
public class Bill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(precision = 10, scale = 2)
    private BigDecimal amount;

    protected Bill() { }
}
