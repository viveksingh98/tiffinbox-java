// SUPPOSED TO CRASH. The base case is missing on purpose. Run: java BreakBaseCase.java
int calls = 0;

// no base case - nothing ever stops the calling
int daysLeft(int day) { calls++; return 1 + daysLeft(day - 1); }

void main() {
    try {
        IO.println("Days left: " + daysLeft(30));
    } catch (StackOverflowError e) {
        IO.println("calls before the crash: " + calls);
        throw e;
    }
}
