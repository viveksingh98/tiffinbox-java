// The rest of the Arrays toolbox, on one screen. Run: java ArraysToolkit.java
void main() {
    int[] orders = {40, 42, 38, 45, 50, 60, 55};
    IO.println("copyOf(orders, 3)         : " + Arrays.toString(Arrays.copyOf(orders, 3)));
    IO.println("copyOf(orders, 9)         : " + Arrays.toString(Arrays.copyOf(orders, 9)));
    IO.println("copyOfRange(orders, 2, 5) : " + Arrays.toString(Arrays.copyOfRange(orders, 2, 5)));

    int[] fresh = new int[7];
    Arrays.fill(fresh, 7);
    IO.println("fill(fresh, 7)            : " + Arrays.toString(fresh));

    int[] a = {40, 42, 38};
    int[] b = {40, 42, 38};
    IO.println("a == b                    : " + (a == b));
    IO.println("Arrays.equals(a, b)       : " + Arrays.equals(a, b));

    int[] sorted = Arrays.copyOf(orders, orders.length);
    Arrays.sort(sorted);
    IO.println("sorted                    : " + Arrays.toString(sorted));
    IO.println("binarySearch(sorted, 50)  : " + Arrays.binarySearch(sorted, 50));
    IO.println("stream(orders).sum()      : " + Arrays.stream(orders).sum());
}
