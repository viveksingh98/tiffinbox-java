package probe.map.money;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Digits;

import java.math.BigDecimal;

/** A bill's amount as Course 2 kept it, a BigDecimal, with its column's precision and scale written: no @Digits (B). */
@Entity
public class Bill {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    @Column(precision = 10, scale = 2) public BigDecimal amount;

    public Bill() { }
}
