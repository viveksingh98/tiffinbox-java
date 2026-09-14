public class Menu {
    static { System.out.println("   >>> Menu's static block ran"); }

    public static final int    MAX_MEALS = 3;
    public static final String TODAY     = pickSpecial();

    static String pickSpecial() { return "Garden Bowl"; }
}
