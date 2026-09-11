void main() {
    int monthlyBill = 7200;
    int mealsPerDay = 2;
    monthlyBill -= 200;   // subtract, then store back
    mealsPerDay++;        // add one
    IO.println("Bill: " + monthlyBill + ", meals: " + mealsPerDay);
}
