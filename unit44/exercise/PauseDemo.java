import com.tiffinbox.Pause;

void main() {
    Pause ravi = new Pause("Ravi", 14, 20);
    IO.println(ravi.describe());
    IO.println("Days: " + ravi.days());
    IO.println("Math.abs(Integer.MIN_VALUE): " + Math.abs(Integer.MIN_VALUE));   // answered from Math.abs(int)'s own doc
    try { new Pause("Ravi", 20, 14); } catch (IllegalArgumentException e) { IO.println("Caught, exactly as the Javadoc promised: " + e.getMessage()); }
}
