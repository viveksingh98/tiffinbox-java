// EXERCISE 46 - "Unstick Yourself" - EDIT THIS FILE.
// An exact copy of DayReportBroken.java, so the broken original stays intact for re-reading.
// It compiles and runs as it stands: two lines, then a crash. That is the starting line.
// Three things to do here (steps 1, 2 and 4 are in README.md):
//   TODO A: one of the two bugs is on the `for` line. It never throws anything - it just
//           loses a customer, and would run off the end. Find it by reading, not by running.
//   TODO B: the other bug is the crash. The trace names the value that was null and the call
//           it could not make. Fix it so a missing name counts as 0 meals.
//   TODO C: Asha wants the report to say so. Anyone not in the map gets a note after the
//           number - two spaces, then (not subscribed today). See the acceptance block.
// The worked solution is DayReport.java - open it last.
void main() {
    String[] customers = {"Ravi", "Meera", "Sunil", "Priya"};
    var mealsToday = new HashMap<String, Integer>();
    mealsToday.put("Ravi", 2);
    mealsToday.put("Meera", 1);
    mealsToday.put("Sunil", 1);
    int total = 0;
    for (int i = 1; i <= customers.length; i++) {          // TODO A
        String name = customers[i];
        int meals = mealsToday.get(name);                  // TODO B
        IO.println(name + ": " + meals);                   // TODO C
        total += meals;
    }
    IO.println("Meals to cook today: " + total);
}
