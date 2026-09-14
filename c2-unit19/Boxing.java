// TiffinBox: a meal count and a monthly bill, both boxed into Integer objects.
void main() {
    Integer a = 127, b = 127;
    Integer c = 128, d = 128;
    IO.println("Integer a = 127, b = 127;  a == b : " + (a == b));
    IO.println("Integer c = 128, d = 128;  c == d : " + (c == d));
    IO.println("c.equals(d)                       : " + c.equals(d));
    IO.println("");

    HashMap<String, Integer> meals = new HashMap<>();
    meals.put("Meera", 2);
    meals.put("Priya", 2);
    HashMap<String, Integer> bills = new HashMap<>();
    bills.put("Meera", 7200);
    bills.put("Priya", 7200);

    IO.println("meal counts  2 == 2      : " + (meals.get("Meera") == meals.get("Priya")));
    IO.println("bills     7200 == 7200   : " + (bills.get("Meera") == bills.get("Priya")));
    IO.println("bills .equals            : " + bills.get("Meera").equals(bills.get("Priya")));
    IO.println("");

    IO.println("bills.get(\"Kiran\")        : " + bills.get("Kiran"));
    int boom = bills.get("Kiran");
    IO.println("never printed: " + boom);
}
