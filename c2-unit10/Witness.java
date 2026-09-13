import java.util.ArrayList;
import java.util.List;

class Witness {
    static <T> List<T> emptyLedger() { return new ArrayList<>(); }
    public static void main(String[] args) {
        String first = emptyLedger().getFirst();
        System.out.println(first);
    }
}
