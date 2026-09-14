// TiffinBox: the ledger has held whole RUPEES in an int since day one, and that was right.
// Today every meal gains a ten-paise packaging charge, so the ledger has to move to paise.
void main() {
    int hoods         = 884;
    int customers     = 4;
    int rupeesEach    = 6_075;                       // 6,075 rupees a month, whole rupees
    int perHoodRupees = customers * rupeesEach;      // 24,300 rupees
    int perHoodPaise  = perHoodRupees * 100;         // 2,430,000 paise  <- the one new line

    IO.println("per neighbourhood, rupees : " + perHoodRupees);
    IO.println("per neighbourhood, paise  : " + perHoodPaise);
    IO.println("Integer.MAX_VALUE         : " + Integer.MAX_VALUE);
    IO.println("neighbourhoods that fit, in rupees : " + Integer.MAX_VALUE / perHoodRupees);
    IO.println("neighbourhoods that fit, in paise  : " + Integer.MAX_VALUE / perHoodPaise);
    IO.println("");

    int  intRupees = 0;
    int  intPaise  = 0;
    long longPaise = 0L;
    for (int n = 1; n <= hoods; n++) {
        intRupees += perHoodRupees;
        intPaise  += perHoodPaise;   // no cast, no warning
        longPaise += perHoodPaise;
    }
    IO.println("884 hoods as int rupees : " + intRupees + "  = " + group(intRupees) + " rupees");
    IO.println("884 hoods as int paise  : " + intPaise  + "  = " + rupees(intPaise)  + " rupees");
    IO.println("884 hoods as long paise : " + longPaise + "  = " + rupees(longPaise) + " rupees");
    IO.println("rupee total is negative : " + (intRupees < 0));
    IO.println("paise total is negative : " + (intPaise  < 0));

    int checked = 0;
    for (int n = 1; n <= hoods; n++) {
        try {
            checked = Math.addExact(checked, perHoodPaise);
        } catch (ArithmeticException e) {
            IO.println("");
            IO.println("Math.addExact stopped at neighbourhood " + n);
            IO.println("  " + e);
            IO.println("last total it would vouch for: " + checked + " paise = " + rupees(checked) + " rupees");
            break;
        }
    }
    IO.println("");
    IO.println("Math.toIntExact(" + longPaise + ") ...");
    int narrowed = Math.toIntExact(longPaise);
    IO.println("never printed: " + narrowed);
}

static String group(long n) {
    return String.format(Locale.ROOT, "%,d", n);
}

static String rupees(long paise) {
    String sign = paise < 0 ? "-" : "";
    long abs = Math.abs(paise);
    return sign + String.format(Locale.ROOT, "%,d", abs / 100)
                + String.format(Locale.ROOT, ".%02d", abs % 100);
}
