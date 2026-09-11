package com.tiffinbox;

import java.nio.file.Path;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Scanner;

public class TiffinBoxApp {

    private static final DateTimeFormatter INDIAN = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final Scanner in;
    private final CustomerRepository repository;
    private final BillingService billing = new BillingService();
    private final List<Customer> customers;

    public TiffinBoxApp(Scanner in, CustomerRepository repository) {
        this.in = in;
        this.repository = repository;
        this.customers = repository.load();
        IO.println("Loaded " + customers.size() + " customers from " + repository.path());
    }

    public static void main(String[] args) {
        var app = new TiffinBoxApp(new Scanner(System.in), new CustomerRepository(Path.of("customers.csv")));
        app.run();
    }

    public void run() {
        int choice;
        do {
            printMenu();
            choice = readChoice();
            try {
                switch (choice) {
                    case 1 -> listCustomers();
                    case 2 -> addCustomer();
                    case 3 -> billReport();
                    case 4 -> pauseCustomer();
                    case 5 -> saveAndExit();
                    default -> IO.println("Please enter a number from 1 to 5");
                }
            } catch (TiffinBoxException e) {
                IO.println("Error: " + e.getMessage());
            }
        } while (choice != 5);
    }

    private void printMenu() {
        IO.println("""

                TiffinBox - Asha's tiffin service
                1  List customers
                2  Add customer
                3  Bill report
                4  Pause a customer
                5  Save and exit""");
        IO.print("Choose (1-5): ");
    }

    private int readChoice() {
        if (!in.hasNextLine()) {
            IO.println("(input closed)");
            return 5;
        }
        try {
            return Integer.parseInt(in.nextLine().trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String readLine(String prompt) {
        IO.print(prompt);
        if (!in.hasNextLine()) {
            throw new TiffinBoxException("input closed");
        }
        return in.nextLine().trim();
    }

    private int readInt(String prompt, int fallback) {
        var text = readLine(prompt);
        if (text.isEmpty() && fallback > 0) {
            return fallback;
        }
        try {
            return Integer.parseInt(text);
        } catch (NumberFormatException e) {
            throw new TiffinBoxException("not a number: '" + text + "'");
        }
    }

    private LocalDate readDate(String prompt) {
        var text = readLine(prompt);
        try {
            return LocalDate.parse(text, INDIAN);
        } catch (DateTimeParseException e) {
            throw new TiffinBoxException("not a date (use dd/MM/yyyy): '" + text + "'");
        }
    }

    private Customer find(String name) {
        return customers.stream()
                .filter(c -> c.name().equalsIgnoreCase(name))
                .findFirst()
                .orElseThrow(() -> new TiffinBoxException("no customer named " + name));
    }

    private void listCustomers() {
        IO.println();
        if (customers.isEmpty()) {
            IO.println("No customers yet - choose 2 to add one");
            return;
        }
        for (var c : customers) {
            IO.println("%-8s %d meals/day  %3d per meal  %s".formatted(
                    c.name(), c.mealsPerDay(), c.pricePerMeal(), c.isVeg() ? "veg" : "non-veg"));
        }
        IO.println(customers.size() + " customers");
    }

    private void addCustomer() {
        IO.println();
        var name = readLine("Name: ");
        int meals = readInt("Meals per day (1-3): ", 0);
        boolean isVeg = readLine("Veg? (y/n): ").equalsIgnoreCase("y");
        int defaultPrice = MealType.of(isVeg).defaultPrice();
        int price = readInt("Price per meal [" + defaultPrice + "]: ", defaultPrice);
        var customer = new Customer(name, meals, price, isVeg);
        customers.add(customer);
        IO.println("Added " + customer.name() + ": monthly bill " + customer.monthlyBill());
    }

    private void billReport() {
        IO.println();
        IO.println("%-8s %-8s %6s".formatted("Name", "Type", "Bill"));
        for (var c : billing.sortedByBill(customers)) {
            var note = billing.pausedDays(c) > 0 ? "  (paused " + billing.pausedDays(c) + " days)" : "";
            IO.println("%-8s %-8s %6d%s".formatted(c.name(), c.mealType(), billing.bill(c), note));
        }
        IO.println("Total revenue: " + billing.totalRevenue(customers)
                + "  |  veg customers: " + billing.vegCount(customers) + " of " + customers.size());
        IO.println("By type: " + billing.revenueByType(customers));
        IO.println("Pay by " + billing.paymentOptions());
    }

    private void pauseCustomer() {
        IO.println();
        var customer = find(readLine("Customer name: "));
        var from = readDate("Pause from (dd/MM/yyyy): ");
        var to = readDate("Pause to (dd/MM/yyyy): ");
        var pause = new Pause(customer.name(), from, to);
        billing.addPause(pause);
        IO.println(customer.name() + " paused " + pause.days() + " days (" + from.format(INDIAN) + " to "
                + to.format(INDIAN) + "): this month's bill " + billing.bill(customer)
                + " instead of " + customer.monthlyBill());
    }

    private void saveAndExit() {
        repository.save(customers);
        IO.println("Saved " + customers.size() + " customers to " + repository.path() + ". Bye!");
    }
}
