void main() {
    IO.println(calculateBill(2, 120, 30));
    IO.println(calculateBill(1, 150, 30));
    IO.println(calculateBill(2, 120));
    printReceipt("Ravi", calculateBill(2, 120));
}

int calculateBill(int mealsPerDay, int pricePerMeal, int days) {
    return mealsPerDay * pricePerMeal * days;
}

int calculateBill(int mealsPerDay, int pricePerMeal) {
    return calculateBill(mealsPerDay, pricePerMeal, 30);
}

void printReceipt(String name, int amount) {
    IO.println("%s owes %d this month".formatted(name, amount));
}
