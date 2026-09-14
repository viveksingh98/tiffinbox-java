import java.util.HashMap;
import java.util.Map;

public class ReportFixed {
    static Map<String, Integer> bills = new HashMap<>();

    // Asha's bill for one customer, in whole rupees.
    static int billFor(String customer) {
        Integer amount = bills.getOrDefault(customer, 0);
        return amount;
    }

    static void printReport(String customer) {
        IO.println(customer + " owes " + billFor(customer));
    }

    public static void main(String[] args) {
        bills.put("Ravi", 7200);
        bills.put("Meera", 4500);
        printReport("Ravi");
        printReport("Priya");
    }
}
