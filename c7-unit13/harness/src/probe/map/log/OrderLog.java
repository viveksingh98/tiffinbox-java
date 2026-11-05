package probe.map.log;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZonedDateTime;

/** One order's times, five ways - no field is named after an SQL keyword (H2 refuses a column named offset: S2.8). */
@Entity
public class OrderLog {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) public Long id;
    public LocalDateTime wall;                                   // a wall clock: no zone anywhere
    public Instant moment;                                       // a moment, as Hibernate maps an Instant by default
    @JdbcTypeCode(SqlTypes.TIMESTAMP) public Instant momentNoZone;   // a moment forced into a column with no zone - Course 2's TIMESTAMP
    public OffsetDateTime offsetAt;                              // a moment with an offset
    public ZonedDateTime zonedAt;                                // a moment with a zone

    protected OrderLog() { }
    public static OrderLog empty() { return new OrderLog(); }
}
