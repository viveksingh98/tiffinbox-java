public class Concat {

    static String label(String name, int bill) {
        return name + " -> " + bill;
    }

    public static void main(String[] args) {
        System.out.println(label("Ravi", 7200));
    }
}
