void main() {
    int[] orders = {40, 42, 38, 45, 50, 60, 55};
    int total = 0;
    for (var count : orders) total += count;
    IO.println("Meals this week: " + total);
    Arrays.sort(orders);
    IO.println(Arrays.toString(orders));
    IO.println("Busiest day: " + orders[orders.length - 1]);
    int[] empty = new int[7];
    IO.println(Arrays.toString(empty));
}
