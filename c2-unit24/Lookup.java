public class Lookup {
    public static void main(String[] args) {
        try {
            Class<?> c = Class.forName("Kitchen");
            System.out.println("found                 : " + c);
        } catch (ClassNotFoundException e) {
            System.out.println("ClassNotFoundException  : " + e.getMessage());
            System.out.println("  it is a CHECKED exception - javac forced the catch");
            System.out.println("  thrown by             : " + e.getStackTrace()[0].getClassName());
        }
        System.out.println("the program carries on");
    }
}
