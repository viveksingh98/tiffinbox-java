void main() {
    int mealsPerDay = 2;
    int pricePerMeal = 120;
    int total = 0;
    for (int day = 1; day <= 30; day++) {
        total += mealsPerDay * pricePerMeal;
    }
    IO.println("30-day bill: " + total);
}
