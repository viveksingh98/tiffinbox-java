package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** @Digits alone: the column comes from the validation annotation. */
@Entity
public class DigitsOnlyBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    @Digits(integer = 8, fraction = 2) public BigDecimal amount;

    public DigitsOnlyBill() { }
}
