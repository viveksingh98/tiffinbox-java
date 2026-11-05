package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

import java.time.Instant;
import java.time.LocalDateTime;

/** The exercise: when an order was placed - the type as the README ships it. */
@Entity
public class OrderLog {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private LocalDateTime placedAt;

    protected OrderLog() { }
}
