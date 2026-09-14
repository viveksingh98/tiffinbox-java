/**
 * Bills a TiffinBox customer.
 *
 * @since 1.0
 */
public class Billing {

    /** Nothing to construct. */
    private Billing() { }

    /**
     * Bills one customer for a whole month.
     *
     * @param days days actually delivered
     * @return the bill in whole rupees
     */
    public static int bill(int days) {
        return days * 120;
    }
}

/** Runs the demo. */
void main() {
    IO.println(Billing.bill(30));
}
