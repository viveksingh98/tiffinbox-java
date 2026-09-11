void main() {
    try (var log = new DeliveryLog()) {
        log.note("Ravi delivered");
        checkMeals(9);
        log.note("never printed");
    } catch (TiffinBoxException e) {
        IO.println("Rejected: " + e.getMessage());
    }
}

void checkMeals(int mealsPerDay) {
    if (mealsPerDay < 1 || mealsPerDay > 3)
        throw new TiffinBoxException("meals a day must be 1 to 3, got " + mealsPerDay);
}

class DeliveryLog implements AutoCloseable {
    DeliveryLog() { IO.println("log opened"); }
    void note(String entry) { IO.println("log: " + entry); }
    @Override public void close() { IO.println("log closed"); }
}

class TiffinBoxException extends RuntimeException {
    TiffinBoxException(String message) { super(message); }
    TiffinBoxException(String message, Throwable cause) { super(message, cause); }
}
