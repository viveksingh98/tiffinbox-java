// break leaves ONE loop. A label says which one. Run: java Labels.java
void main() {
    int[][] week = { {40,12}, {38,10}, {42,14}, {41,9}, {45,18}, {52,22}, {30,6} };
    String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};

    for (int day = 0; day < week.length; day++) {
        for (int type = 0; type < week[day].length; type++) {
            if (week[day][type] > 40) { IO.println("Busy: " + days[day]); break; }
        }
    }

    search:
    for (int day = 0; day < week.length; day++) {
        for (int type = 0; type < week[day].length; type++) {
            if (week[day][type] > 40) { IO.println("First busy slot: " + days[day]); break search; }
        }
    }
}
