// TiffinBox: Ravi's meal costs 120.10 a day and is billed for 30 days.
void main() {
    IO.println("0.1 + 0.2        = " + (0.1 + 0.2));
    IO.println("0.1 + 0.2 == 0.3 : " + (0.1 + 0.2 == 0.3));
    IO.println("2.00 - 1.10      = " + (2.00 - 1.10));
    IO.println("new BigDecimal(0.1)     = "
               + new BigDecimal(0.1));
    IO.println("");

    double dTotal = 0.0;
    for (int day = 1; day <= 30; day++) dTotal += 120.10;

    BigDecimal rate = new BigDecimal("120.10");
    BigDecimal bTotal = BigDecimal.ZERO;
    for (int day = 1; day <= 30; day++) bTotal = bTotal.add(rate);

    long pTotal = 0L;
    for (int day = 1; day <= 30; day++) pTotal += 12010L;

    IO.println("double     total = " + dTotal);
    IO.println("BigDecimal total = " + bTotal);
    IO.println("long paise total = " + pTotal + "  = " + rupees(pTotal) + " rupees");
    IO.println("double == 3603.00        : " + (dTotal == 3603.00));
    IO.println("what the double is short  : " + new BigDecimal("3603.00").subtract(BigDecimal.valueOf(dTotal)));
    IO.println("");

    IO.println("new BigDecimal(0.1)      = " + new BigDecimal(0.1));
    IO.println("BigDecimal.valueOf(0.1)  = " + BigDecimal.valueOf(0.1));
    IO.println("new BigDecimal(\"0.1\")    = " + new BigDecimal("0.1"));
    IO.println("");

    BigDecimal ignored = new BigDecimal("0.00");
    for (int day = 1; day <= 30; day++) ignored.add(rate);
    IO.println("30 ignored adds  = " + ignored);
    IO.println("30 real adds     = " + bTotal);
    IO.println("");

    BigDecimal bill  = rate.multiply(new BigDecimal("30"));
    BigDecimal fee   = bill.multiply(new BigDecimal("0.025"));
    BigDecimal gross = bill.add(fee);
    BigDecimal due   = gross.setScale(2, RoundingMode.HALF_UP);
    IO.println("bill  = " + bill  + "   scale " + bill.scale());
    IO.println("fee   = " + fee   + "   scale " + fee.scale());
    IO.println("gross = " + gross + "   scale " + gross.scale());
    IO.println("due   = " + due   + "      scale " + due.scale());
    IO.println("");

    BigDecimal one = new BigDecimal("3603.0");
    BigDecimal two = new BigDecimal("3603.00");
    IO.println("equals(3603.0, 3603.00)  : " + one.equals(two) + "   (scales " + one.scale() + " and " + two.scale() + ")");
    IO.println("compareTo == 0           : " + (one.compareTo(two) == 0));
    IO.println("in a HashSet             : " + new HashSet<>(List.of(one, two)).size() + " elements");
}

static String rupees(long paise) {
    return (paise / 100) + String.format(Locale.ROOT, ".%02d", paise % 100);
}
