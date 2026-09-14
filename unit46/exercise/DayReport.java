// TiffinBox: how many meals must Asha cook today? Both bugs fixed.
void main() {
    String[] customers = {"Ravi", "Meera", "Sunil", "Priya"};
    var mealsToday = new HashMap<String, Integer>();
    mealsToday.put("Ravi", 2);
    mealsToday.put("Meera", 1);
    mealsToday.put("Sunil", 1);
    int total = 0;
    for (int i = 0; i < customers.length; i++) {          // bug 1: started at 1, ran to length
        String name = customers[i];
        int meals = mealsToday.getOrDefault(name, 0);      // bug 2: get() returns null, unboxing throws
        String note = mealsToday.containsKey(name) ? "" : "  (not subscribed today)";
        IO.println(name + ": " + meals + note);
        total += meals;
    }
    IO.println("Meals to cook today: " + total);
}
