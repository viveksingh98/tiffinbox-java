import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.Random;

/// Order ids for the server: java.util.Random is a formula, SecureRandom is not.
/// Run: java OrderIds.java       (compact source file, no dependencies)
String id(Random r) {
    byte[] bytes = new byte[6];
    r.nextBytes(bytes);
    return "ORD-" + HexFormat.of().withUpperCase().formatHex(bytes);
}

void main() {
    String a = id(new Random(42));
    String b = id(new Random(42));
    IO.println("java.util.Random, two objects, same seed 42:");
    IO.println("  A: " + a);
    IO.println("  B: " + b);
    IO.println("  identical? " + a.equals(b));

    SecureRandom sr = new SecureRandom();
    String c = id(sr);
    String d = id(sr);
    IO.println("java.security.SecureRandom (" + sr.getAlgorithm() + "):");
    IO.println("  C: " + c);
    IO.println("  D: " + d);
    IO.println("  identical? " + c.equals(d));
}
