public class Customer {
    private static int count = 0;
    private final String name;
    private int mealsPerDay;

    public Customer(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
        count++;
    }

    public String getName() { return name; }
    public int getMealsPerDay() { return mealsPerDay; }

    public void setMealsPerDay(int mealsPerDay) {
        if (mealsPerDay < 1 || mealsPerDay > 3) {
            IO.println("Rejected: " + mealsPerDay
                       + " meals a day");
            return;
        }
        this.mealsPerDay = mealsPerDay;
    }

    public static int count() { return count; }
}
