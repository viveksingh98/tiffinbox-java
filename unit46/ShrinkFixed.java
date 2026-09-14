void main() {
    var days = new ArrayList<>(List.of(1, 2, 3, 4, 5));
    days.remove(Integer.valueOf(2));
    IO.println(days);
}
