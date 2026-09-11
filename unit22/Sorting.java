void main() {
    var names = new ArrayList<>(List.of("Ravi", "Meera", "Sunil"));
    names.sort(Comparator.naturalOrder());
    IO.println(names);
    names.sort(Comparator.reverseOrder());
    IO.println(names);
    var bills = new ArrayList<>(List.of(7200, 4500, 3600));
    Collections.sort(bills);
    IO.println(bills + " " + bills.reversed());
}
