void main() {
    int wallet = 2000;
    int dailyCost = 240;
    int days = 0;
    while (wallet >= dailyCost) {
        wallet -= dailyCost;
        days++;
    }
    IO.println(days + " days of tiffin, " + wallet + " left");
}
