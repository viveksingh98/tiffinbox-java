// A grid: seven days, two meal types. Run: java WeekGrid.java
void main() {
    int[][] weekByType = new int[7][2];                 // an array of arrays
    IO.println("Empty grid: " + Arrays.deepToString(weekByType));
    IO.println("Rows " + weekByType.length + ", columns " + weekByType[0].length);

    int[][] week = { {40,12}, {38,10}, {42,14}, {41,9}, {45,18}, {52,22}, {30,6} };
    String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
    IO.println("Wednesday non-veg: " + week[2][1]);     // [row][column]

    int[] byType = new int[2];
    for (int day = 0; day < week.length; day++) {
        for (int type = 0; type < week[day].length; type++) byType[type] += week[day][type];
        IO.println(days[day] + "  veg " + week[day][0] + "  non-veg " + week[day][1]);
    }
    IO.println("Week total: veg " + byType[0] + ", non-veg " + byType[1]);

    int[][] jagged = new int[3][];                      // rows of different lengths
    jagged[0] = new int[] {120};
    jagged[1] = new int[] {120, 150};
    jagged[2] = new int[] {120, 150, 130};
    IO.println("Jagged: " + Arrays.deepToString(jagged));
}
