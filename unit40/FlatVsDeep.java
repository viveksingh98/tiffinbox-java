// DIFFERS EVERY RUN: the flat line prints memory codes, not meals. Run: java FlatVsDeep.java
void main() {
    int[][] week = { {40,12}, {38,10}, {42,14}, {41,9}, {45,18}, {52,22}, {30,6} };
    IO.println("toString    : " + Arrays.toString(week));
    IO.println("deepToString: " + Arrays.deepToString(week));
}
