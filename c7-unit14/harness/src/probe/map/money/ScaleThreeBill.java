package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** The planted scale = 3: DigitsBill with @Column(scale = 3) beside @Digits(fraction = 2) - the two annotations disagree. */
@Entity
public class ScaleThreeBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    @Digits(integer = 8, fraction = 2) @Column(precision = 10, scale = 3) public BigDecimal amount;

    public ScaleThreeBill() { }
}
