import java.util.List;

public class NotComparable {
    record Subscription(int id, String customer) { }

    static <T extends Comparable<T>> T max(List<T> items) {
        T best = items.get(0);
        for (T item : items) {
            if (item.compareTo(best) > 0) best = item;
        }
        return best;
    }

    public static void main(String[] args) {
        List<Subscription> subs = List.of(new Subscription(1, "Ravi"), new Subscription(2, "Meera"));
        System.out.println("biggest subscription: " + max(subs));
    }
}
