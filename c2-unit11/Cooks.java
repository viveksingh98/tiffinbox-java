import java.util.List;

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

void main() throws InterruptedException {
    List<Customer> morning = List.of(new Customer("Ravi", 2, 120, true),
                                     new Customer("Meera", 1, 150, true));
    List<Customer> evening = List.of(new Customer("Sunil", 3, 100, false),
                                     new Customer("Priya", 1, 120, true));

    int[] totals = new int[2];
    String[] ranOn = new String[2];

    Runnable morningShift = () -> {
        ranOn[0] = Thread.currentThread().getName();
        totals[0] = morning.stream().mapToInt(Customer::monthlyBill).sum();
    };
    Runnable eveningShift = () -> {
        ranOn[1] = Thread.currentThread().getName();
        totals[1] = evening.stream().mapToInt(Customer::monthlyBill).sum();
    };

    Thread cook1 = Thread.ofPlatform().name("cook-morning").unstarted(morningShift);
    Thread cook2 = Thread.ofPlatform().name("cook-evening").unstarted(eveningShift);

    String before = cook1.getState().toString();
    cook1.start();
    cook2.start();
    cook1.join();
    cook2.join();
    String after = cook1.getState().toString();

    IO.println("main runs on:       " + Thread.currentThread().getName());
    IO.println("cook-morning state: " + before);
    IO.println("cook-morning state: " + after);
    IO.println("morning shift ran on " + ranOn[0] + " -> " + totals[0]);
    IO.println("evening shift ran on " + ranOn[1] + " -> " + totals[1]);
    IO.println("kitchen total:       " + (totals[0] + totals[1]));
}
