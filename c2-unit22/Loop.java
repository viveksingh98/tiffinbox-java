public class Loop {

    static String joinNames(String[] names) {
        String out = "";
        for (String n : names) {
            out = out + n + " ";
        }
        return out;
    }

    public static void main(String[] args) {
        System.out.println(joinNames(new String[] {"Meera", "Priya", "Ravi", "Sunil", "Kiran"}));
    }
}
