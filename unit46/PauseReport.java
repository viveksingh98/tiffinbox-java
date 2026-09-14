// TiffinBox - Asha's pause book: which days has a customer paused?
record Customer(String name, String type) { }

class PauseBook {
    private final Map<String, List<Integer>> paused = new HashMap<>();

    void pause(String name, int day) {
        paused.computeIfAbsent(name, k -> new ArrayList<>()).add(day);
    }

    // Asha rang: the customer wants this day back.
    void unpause(String name, int day) {
        List<Integer> days = paused.get(name);
        days.remove(day);
    }

    List<Integer> daysFor(String name) {
        return paused.getOrDefault(name, List.of());
    }
}

void main() {
    var book = new PauseBook();
    var ravi = new Customer("Ravi", "VEG");

    for (int day = 1; day <= 5; day++) {
        book.pause(ravi.name(), day);
    }
    IO.println("Ravi paused : " + book.daysFor(ravi.name()));
    book.unpause(ravi.name(), 2);
    IO.println("After cancelling the pause on day 2: " + book.daysFor(ravi.name()));
    book.unpause(ravi.name(), 5);
    IO.println("After cancelling the pause on day 5: " + book.daysFor(ravi.name()));
}
