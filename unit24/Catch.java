void main() {
    try {
        IO.println("Average per meal: " + average(520, 0));
    } catch (ArithmeticException e) {
        IO.println("No meals today: " + e.getMessage());
    } finally {
        IO.println("Report closed");
    }
    IO.println("Program continues");
}
int average(int takings, int meals) {
    return takings / meals;
}
