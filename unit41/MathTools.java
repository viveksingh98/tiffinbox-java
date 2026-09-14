void main() {
    IO.println("Math.abs(-240)        = " + Math.abs(-240));
    IO.println("Math.max(7200, 4500)  = " + Math.max(7200, 4500));
    IO.println("Math.min(7200, 4500)  = " + Math.min(7200, 4500));
    IO.println("Math.round(23.333)    = " + Math.round(23.333));
    IO.println("Math.ceil(6.2)        = " + Math.ceil(6.2));
    IO.println("Math.floor(6.9)       = " + Math.floor(6.9));
    IO.println("Math.pow(1.1, 12)     = " + Math.pow(1.1, 12));
    IO.println("Math.sqrt(2025)       = " + Math.sqrt(2025));
    IO.println("Math.PI               = " + Math.PI);

    int bags = (int) Math.ceil(31 / 5.0);
    IO.println("bags for 31 tiffins   = " + bags);

    try {
        Math.multiplyExact(2_082_000, 1200);
    } catch (ArithmeticException e) {
        IO.println("multiplyExact throws  : " + e.getMessage());
    }
}
