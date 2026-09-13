import java.util.List;

public class AddToExtends {
    sealed interface Meal permits VegMeal, NonVegMeal { int price(); }
    record VegMeal(int price) implements Meal {}
    record NonVegMeal(int price) implements Meal {}

    static void addOne(List<? extends Meal> meals) {
        meals.add(new VegMeal(120));
    }

    public static void main(String[] args) { }
}
