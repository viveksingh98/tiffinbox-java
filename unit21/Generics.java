void main() {
    List<String> customers = new ArrayList<>(List.of("Ravi", "Meera", "Sunil"));
    IO.println(firstOr(customers, "nobody"));
    IO.println(firstOr(new ArrayList<Integer>(), 0));
    IO.println(max(List.of(7200, 4500, 3600)));
    IO.println(max(List.of("Ravi", "Meera", "Sunil")));
}

<T> T firstOr(List<T> list, T fallback) {
    return list.isEmpty() ? fallback : list.getFirst();
}

<T extends Comparable<T>> T max(List<T> list) {
    T best = list.getFirst();
    for (var item : list) if (item.compareTo(best) > 0) best = item;
    return best;
}
