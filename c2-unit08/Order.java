import java.util.List;
public class Order {
    interface Priced { int price(); }
    static abstract class Meal { abstract String label(); }
    static <T extends Priced & Meal> String describe(T m) { return m.label(); }
}
