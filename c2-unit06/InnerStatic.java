void main() {
    new Counter<String>();
    new Counter<Integer>();
    IO.println("created: " + Counter.created);
}
class Counter<T> {
    static int created = 0;
    Counter() { created++; }
}
