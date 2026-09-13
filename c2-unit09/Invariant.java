import java.util.List;

public class Invariant {
    sealed interface Meal permits VegMeal, NonVegMeal, VeganMeal { int price(); }
    record VegMeal(int price) implements Meal {}
    record NonVegMeal(int price) implements Meal {}
    record VeganMeal(int price) implements Meal {}

    static List<VegMeal> vegOnly = List.of(new VegMeal(120), new VegMeal(100));
    static List<Meal> meals = vegOnly;

    public static void main(String[] args) {
        System.out.println(meals);
    }
}
