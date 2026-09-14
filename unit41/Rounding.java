void main() {
    IO.println("(int) 2.99   = " + (int) 2.99);
    IO.println("(int) 2.01   = " + (int) 2.01);
    IO.println("(int) -2.99  = " + (int) -2.99);
    IO.println("Math.floor(-2.99) = " + Math.floor(-2.99));

    IO.println("Math.round(2.99) = " + Math.round(2.99));
    IO.println("Math.round(2.5)  = " + Math.round(2.5));
    IO.println("Math.round(3.5)  = " + Math.round(3.5));
    IO.println("Math.round(-2.5) = " + Math.round(-2.5));

    IO.println("Math.rint(2.5)   = " + Math.rint(2.5));
    IO.println("Math.rint(3.5)   = " + Math.rint(3.5));
    IO.println("Math.rint(-2.5)  = " + Math.rint(-2.5));

    IO.println("Math.ceil(2.01)  = " + Math.ceil(2.01));
    IO.println("Math.floor(2.99) = " + Math.floor(2.99));

    int mealsPerDay = 2;
    double pricePerMeal = 140.0;
    IO.println("widening, free: " + mealsPerDay * pricePerMeal * 3);
    IO.println("(int) 3_000_000_000L = " + (int) 3_000_000_000L);
}
