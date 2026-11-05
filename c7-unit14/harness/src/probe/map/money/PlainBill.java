package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** A bare BigDecimal: no precision, no scale written - Hibernate's default column. */
@Entity
public class PlainBill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    public BigDecimal amount;

    public PlainBill() { }
}
