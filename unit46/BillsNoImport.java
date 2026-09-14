public class BillsNoImport {
    static Map<String, Integer> bills = new HashMap<>();

    public static void main(String[] args) {
        bills.put("Ravi", 7200);
        IO.println(bills);
    }
}
