void main() {
    var days = new ArrayList<>(List.of(1, 2, 3, 4, 5));
    int day = 2;
    IO.println("[unpause] day=" + day + " list=" + days + " size=" + days.size());
    days.remove(day);
    IO.println("[unpause] after remove list=" + days);
}
