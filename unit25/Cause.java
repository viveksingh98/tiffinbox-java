void main() {
    IO.println("Average per meal: " + averagePerMeal("Sunil", 0, 0));
}

int averagePerMeal(String name, int takings, int meals) {
    try { return takings / meals; }
    catch (ArithmeticException e) {
        throw new TiffinBoxException("no meals recorded for " + name, e);
    }
}

class TiffinBoxException extends RuntimeException {
    TiffinBoxException(String message) { super(message); }
    TiffinBoxException(String message, Throwable cause) { super(message, cause); }
}
