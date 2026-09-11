void main() {
    IO.println("Average per meal: " + averagePerMeal());
}
int averagePerMeal() {
    return average(520, 0);
}
int average(int takings, int meals) {
    return takings / meals;
}
