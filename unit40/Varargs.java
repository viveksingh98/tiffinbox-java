// One method, however many bills. Run: java Varargs.java
int total(int... amounts) {
    int sum = 0;
    for (int amount : amounts) sum += amount;   // inside the method it is just an array
    return sum;
}

void show(int... amounts) {
    IO.println(amounts.length + " bills " + Arrays.toString(amounts) + " -> " + total(amounts));
}

void main() {
    show();
    show(7200);
    show(7200, 4500, 3600, 7200, 5520);
    int[] lastMonth = {7200, 4500, 3600};
    show(lastMonth);                            // an array goes in unchanged
}
