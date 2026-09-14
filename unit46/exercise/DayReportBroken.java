// TiffinBox: how many meals must Asha cook today? Two bugs; only one of them crashes.
void main() {
    String[] customers = {"Ravi", "Meera", "Sunil", "Priya"};
    var mealsToday = new HashMap<String, Integer>();
    mealsToday.put("Ravi", 2);
    mealsToday.put("Meera", 1);
    mealsToday.put("Sunil", 1);
    int total = 0;
    for (int i = 1; i <= customers.length; i++) {
        String name = customers[i];
        int meals = mealsToday.get(name);
        IO.println(name + ": " + meals);
        total += meals;
    }
    IO.println("Meals to cook today: " + total);
}
