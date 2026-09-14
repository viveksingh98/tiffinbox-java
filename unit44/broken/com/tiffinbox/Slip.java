package com.tiffinbox;

/** A typo in a tag. */
public class Slip {
    /** Nothing to construct. */
    private Slip() { }

    /**
     * Bills one order.
     *
     * @param dayz days delivered
     * @return the bill
     */
    public static int billFor(int days) { return days * 120; }
}
