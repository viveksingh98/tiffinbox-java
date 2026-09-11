void main() {
    int pausedDays = 7;
    int daysInMonth = 30;
    double skipped = pausedDays / daysInMonth * 100;
    IO.println("Skipped: " + skipped + "%");
    double fixed = pausedDays / (double) daysInMonth * 100;
    IO.println("Skipped: " + fixed + "%");
    IO.println("Skipped: %.1f%%".formatted(fixed));
}
