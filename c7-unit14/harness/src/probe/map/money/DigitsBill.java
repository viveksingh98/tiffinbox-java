package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** The shipped class the S2.4 check reads (A): @Digits and @Column(precision, scale) saying one fact - eight digits before the point, two after. */
@Entity
public class DigitsBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    @Digits(integer = 8, fraction = 2) @Column(precision = 10, scale = 2) public BigDecimal amount;

    public DigitsBill() { }
}
