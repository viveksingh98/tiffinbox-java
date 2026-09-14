void main() {
    double sum = 0.1 + 0.2;
    IO.println("0.1 + 0.2         = " + sum);
    IO.println("0.1 + 0.2 == 0.3  ? " + (sum == 0.3));
    IO.println("what Java stores  : " + new BigDecimal(sum));

    double packing = 4.35;
    IO.println("4.35 * 100        = " + packing * 100);
    IO.println("(int)(4.35 * 100) = " + (int) (packing * 100));

    double drift = 0.0;
    for (int i = 0; i < 60; i++) drift += 0.05;
    IO.println("0.05 sixty times  = " + drift);

    System.out.printf("rounded for the bill: %.2f%n", sum);
    IO.println("1.0 / 0.0         = " + 1.0 / 0.0);
    IO.println("0.0 / 0.0         = " + 0.0 / 0.0);
}
