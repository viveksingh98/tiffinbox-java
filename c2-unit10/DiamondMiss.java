import java.util.HashMap;

class DiamondMiss {
    public static void main(String[] args) {
        var repo = new HashMap<>();
        repo.put("Ravi", 7200);
        int bill = repo.get("Ravi");
        System.out.println(bill);
    }
}
