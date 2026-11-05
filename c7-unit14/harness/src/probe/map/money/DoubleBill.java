package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** Course 2's wrong type for money, a double, in a column. */
@Entity
public class DoubleBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    public double amount;

    public DoubleBill() { }
}
