public class ArrayStore {
    sealed interface Meal permits VegMeal, NonVegMeal { int price(); }
    record VegMeal(int price) implements Meal {}
    record NonVegMeal(int price) implements Meal {}

    public static void main(String[] args) {
        VegMeal[] vegOnly = { new VegMeal(120), new VegMeal(100) };
        Meal[] meals = vegOnly;
        meals[0] = new NonVegMeal(150);
    }
}
