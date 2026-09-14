// Reads the two private fields every String has had since Java 9.
// Needs:  java --add-opens java.base/java.lang=ALL-UNNAMED Compact.java
import java.lang.reflect.Field;

void row(Field value, Field coder, String label, String s) throws Exception {
    byte[] bytes = (byte[]) value.get(s);
    int c = (Byte) coder.get(s);
    IO.println(String.format("%-31s length()=%-3d bytes=%-3d coder=%d (%s)",
            label, s.length(), bytes.length, c, c == 0 ? "LATIN1" : "UTF16"));
}

void main() throws Exception {
    Field value = String.class.getDeclaredField("value");
    value.setAccessible(true);
    Field coder = String.class.getDeclaredField("coder");
    coder.setAccessible(true);

    row(value, coder, "\"Ravi\"", "Ravi");
    row(value, coder, "\"NON_VEG\"", "NON_VEG");
    row(value, coder, "\"Meera Priya Ravi Sunil Kiran\"", "Meera Priya Ravi Sunil Kiran");
    row(value, coder, "\"Ravi é\"", "Ravi é");
    row(value, coder, "\"Ravi ₹\"", "Ravi ₹");
}
