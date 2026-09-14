// The same answer twice: recursion and a loop. Run: java DaysLeft.java
int daysLeft(int day) {
    if (day == 0) return 0;              // the base case that BreakBaseCase.java was missing
    return 1 + daysLeft(day - 1);
}

int daysLeftLoop(int day) {
    int count = 0;
    while (day > 0) { count++; day--; }
    return count;
}

void main() {
    IO.println("Recursion: " + daysLeft(30));
    IO.println("Loop:      " + daysLeftLoop(30));
}
