package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** @Digits(integer = 6) beside @Column(precision = 10): the two disagree on the precision. */
@Entity
public class SixDigitsBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    @Digits(integer = 6, fraction = 2) @Column(precision = 10, scale = 2) public BigDecimal amount;

    public SixDigitsBill() { }
}
