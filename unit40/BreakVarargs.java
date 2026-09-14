int total(int... amounts, String label) {
    int sum = 0;
    for (int amount : amounts) sum += amount;
    return sum;
}

void main() {
    IO.println(total(7200, 4500, "March"));
}
