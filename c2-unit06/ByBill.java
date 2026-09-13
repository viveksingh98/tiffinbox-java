import java.util.Comparator;

public class ByBill implements Comparator<Customer> {
    public int compare(Customer a, Customer b) {
        return Integer.compare(a.monthlyBill(), b.monthlyBill());
    }
}
