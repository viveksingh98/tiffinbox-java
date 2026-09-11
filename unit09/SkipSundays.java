void main() {
    int total = 0;
    for (int day = 1; day <= 30; day++) {
        if (day % 7 == 0) continue;
        total += 240;
        if (total > 5000) {
            IO.println("Budget alert on day " + day);
            break;
        }
    }
    IO.println("Total so far: " + total);
}
