void main() {
    System.out.printf("locale: %s%n", Locale.getDefault());
    System.out.printf("%.2f%n", 7 / 30.0 * 100);
    System.out.printf("%,d%n", 2_082_000);
    System.out.printf("%05d%n", 42);
    System.out.printf("%+d%n", 240);
    System.out.printf("%s owes %d rupees (%.1f%% of revenue)%n", "Ravi", 7200, 7200 * 100.0 / 22500);
    System.out.printf("%b %c %x%n", true, 'M', 255);
    System.out.printf("%d%% delivered%n", 100);
}
