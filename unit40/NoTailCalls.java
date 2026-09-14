// Proof: this call IS the last thing the method does, and Java still keeps the frame.
// SUPPOSED TO CRASH. Run: java NoTailCalls.java
int countDown(int day, int counted) {
    if (day == 0) return counted;                 // base case is there - this is not runaway
    return countDown(day - 1, counted + 1);       // a tail call: nothing left to do after it
}

void main() {
    IO.println("30 days      : " + countDown(30, 0));
    IO.println("1000000 days : " + countDown(1_000_000, 0));
}
