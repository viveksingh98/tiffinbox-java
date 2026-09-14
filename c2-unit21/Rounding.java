// TiffinBox: Meera, Priya and Kiran split one 100-rupee family order three ways.
void main() {
    BigDecimal bill  = new BigDecimal("100.00");
    BigDecimal three = new BigDecimal("3");
    BigDecimal share = bill.divide(three, 2, RoundingMode.HALF_UP);
    BigDecimal sum   = share.add(share).add(share);

    IO.println("bill                 = " + bill);
    IO.println("each share, rounded  = " + share);
    IO.println("three shares add to  = " + sum);
    IO.println("sum.compareTo(bill)  = " + sum.compareTo(bill) + "   (one paise short)");
    IO.println("missing              = " + (10000L - 9999L) + " paise");
    IO.println("");

    IO.println("Math.round(1.005 * 100) / 100.0             = " + Math.round(1.005 * 100) / 100.0);
    IO.println("new BigDecimal(\"1.005\").setScale(2,HALF_UP) = " + new BigDecimal("1.005").setScale(2, RoundingMode.HALF_UP));
    IO.println("1.005 as a double really is " + new BigDecimal(1.005));
    IO.println("");

    IO.println("Math.round(2.5)   = " + Math.round(2.5) + "     Math.round(-2.5)  = " + Math.round(-2.5));
    IO.println("HALF_UP   2.5 -> " + new BigDecimal("2.5").setScale(0, RoundingMode.HALF_UP)
             + "     -2.5 -> " + new BigDecimal("-2.5").setScale(0, RoundingMode.HALF_UP));
    IO.println("HALF_EVEN 2.5 -> " + new BigDecimal("2.5").setScale(0, RoundingMode.HALF_EVEN)
             + "     3.5 -> " + new BigDecimal("3.5").setScale(0, RoundingMode.HALF_EVEN));
    IO.println("");

    IO.println("bill.divide(three)   with no rounding mode ...");
    BigDecimal exact = bill.divide(three);
    IO.println("never printed: " + exact);
}
