package probe.map.embed;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/** The same value object as a record: the three components, equals/hashCode/toString written by the compiler. */
@Embeddable
public record RecAddress(String line1, String city, @Column(length = 6) String pincode) { }
