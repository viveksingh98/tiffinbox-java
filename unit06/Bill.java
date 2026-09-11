void main() {
    int mealsPerDay = 2;
    int pricePerMeal = 120;
    int daysInMonth = 30;
    int monthlyBill = mealsPerDay * pricePerMeal * daysInMonth;   // 7200
    int fullWeeks = daysInMonth / 7;                              // 4
    int leftoverDays = daysInMonth % 7;                           // 2
    int discounted = monthlyBill - monthlyBill * 10 / 100;        // 6480
    int clearer = monthlyBill - (monthlyBill * 10) / 100;         // 6480, same, louder
    boolean isRegular = mealsPerDay >= 2;                         // true
    boolean bigSpender = isRegular && monthlyBill > 5000;         // true
    IO.println("Monthly bill: " + monthlyBill);
    IO.println("Full weeks: " + fullWeeks);
    IO.println("Leftover days: " + leftoverDays);
    IO.println("After 10% off: " + discounted);
    IO.println("Regular: " + isRegular + ", big spender: " + bigSpender);
}
