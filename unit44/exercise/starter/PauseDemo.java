// EXERCISE 44 - the demo. Run it from this folder after compiling Pause:
//   javac -d out src/com/tiffinbox/Pause.java
//   java -cp out PauseDemo.java
import com.tiffinbox.Pause;

void main() {
    Pause ravi = new Pause("Ravi", 14, 20);
    IO.println(ravi.describe());
    IO.println("Days: " + ravi.days());
    // TODO 5: answer this from the documentation, not from the video.
    //   Math.abs takes an int and hands back its absolute value. What does it hand back
    //   for Integer.MIN_VALUE, the most negative int there is? Read Math.abs(int)'s own
    //   description - the paragraph under the first two lines - then print it here and
    //   prove it. One line, and the answer will surprise you.
    IO.println("Math.abs(Integer.MIN_VALUE): " + 0);
    try { new Pause("Ravi", 20, 14); } catch (IllegalArgumentException e) { IO.println("Caught, exactly as the Javadoc promised: " + e.getMessage()); }
}
