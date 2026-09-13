import java.util.ArrayList;
import java.util.List;

public class NoWild {
    record Customer(String name, int mealsPerDay, int pricePerMeal) {
        int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
    }
    static final List<Customer> CUSTOMERS = List.of(new Customer("Ravi", 2, 120), new Customer("Meera", 1, 150));

    public static void main(String[] args) {
        List<Object> ledger = new ArrayList<>();
        List<Integer> bills = new ArrayList<>();
        copyBills(CUSTOMERS, ledger);   // <-- Slide 4: this is the line that will not compile
        copyBills(CUSTOMERS, bills);    // this one is fine: List<Integer> is exactly List<Integer>
        System.out.println(ledger);
        System.out.println(bills);
    }

    // The same copyBills as Wildcards.java, with the wildcards taken out.
    // List<Integer> now means List<Integer> and nothing else -- not List<Object>,
    // not List<Number>, even though both can hold every Integer we produce.
    static void copyBills(List<Customer> source, List<Integer> target) {
        for (Customer c : source) target.add(c.monthlyBill());
    }
}
