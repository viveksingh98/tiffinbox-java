void main() {
    var ravi = new Customer();
    ravi.name = "Ravi";
    ravi.mealsPerDay = 2;
    ravi.pricePerMeal = 120;
    ravi.isVeg = true;
    IO.println(ravi.name + " eats " + ravi.mealsPerDay + " meals a day");
    IO.println("Monthly: " + ravi.monthlyBill());

    var meera = new Customer();
    meera.name = "Meera";
    meera.mealsPerDay = 1;
    meera.pricePerMeal = 150;
    meera.isVeg = false;
    IO.println("Monthly: " + meera.monthlyBill());

    var sameRavi = ravi;
    sameRavi.mealsPerDay = 3;
    IO.println(ravi.name + " now eats " + ravi.mealsPerDay);
}

class Customer {
    String name;
    int mealsPerDay;
    int pricePerMeal;
    boolean isVeg;

    int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }
}
