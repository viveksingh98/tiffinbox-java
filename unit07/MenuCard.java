void main() {
    String dish = "cottage cheese curry";
    int price = 120;
    String card = """
        TiffinBox - Monday
        Veg special: %s
        Price: %d per meal
        Reply PAUSE to skip today.
        """.formatted(dish, price);
    IO.println(card);
}
