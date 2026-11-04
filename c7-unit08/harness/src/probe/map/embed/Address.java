package probe.map.embed;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/**
 * The embeddables lesson's value object: an address is three columns that belong together, never a table of its own. A class,
 * written the long way: a no-argument constructor for Hibernate, the three values, and equals/hashCode/toString by value.
 */
@Embeddable
public class Address {
    private String line1;
    private String city;
    @Column(length = 6)
    private String pincode;
    protected Address() { }
    public Address(String line1, String city, String pincode) { this.line1 = line1; this.city = city; this.pincode = pincode; }
    public String getLine1() { return line1; }
    public String getCity() { return city; }
    public String getPincode() { return pincode; }
    @Override public boolean equals(Object o) {
        return o instanceof Address a && java.util.Objects.equals(line1, a.line1) && java.util.Objects.equals(city, a.city)
                && java.util.Objects.equals(pincode, a.pincode);
    }
    @Override public int hashCode() { return java.util.Objects.hash(line1, city, pincode); }
    @Override public String toString() { return "Address[line1=" + line1 + ", city=" + city + ", pincode=" + pincode + "]"; }
}
