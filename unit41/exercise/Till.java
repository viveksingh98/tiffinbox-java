long yearlyPaise(int kitchens, int rupeesPerMonth) {
    return (long) kitchens * rupeesPerMonth * 100 * 12;   // cast the FIRST operand
}

int toPaise(double rupees) {
    return (int) Math.round(rupees * 100);                // round first, cast second
}

void main() {
    int kitchens = 1200;
    int rupeesPerMonth = 20_820;
    IO.println("Yearly paise (int would break): " + yearlyPaise(kitchens, rupeesPerMonth));
    System.out.printf("%-29s: %d%n", "int would have given", kitchens * rupeesPerMonth * 100 * 12);
    System.out.printf("%-29s: %d%n", "4.35 rupees in paise, wrong", (int) (4.35 * 100));
    System.out.printf("%-29s: %d%n", "4.35 rupees in paise, right", toPaise(4.35));

    double skipped = 7 / (double) 30 * 100;
    System.out.printf("%-29s: %s%n", "Skipped, raw", skipped);
    System.out.printf("%-29s: %s%n", "Skipped, for Asha", "%.1f%%".formatted(skipped));
    System.out.printf("%-29s: %d%n", "Skipped, rounded to a whole", Math.round(skipped));

    String[] menu = {"lentil rice", "bean curry", "chickpea curry", "vegetable stew",
                     "cottage cheese curry", "spiced rice", "combo plate"};
    var picker = new Random(2026);
    for (int day = 1; day <= 3; day++) {
        System.out.printf("%-25s: %s%n", "Meal of day " + day, menu[picker.nextInt(menu.length)]);
    }
}
