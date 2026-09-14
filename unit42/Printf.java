void main() {
    String[] names = {"Ravi", "Meera", "Sunil", "Priya"};
    String[] types = {"VEG", "NON_VEG", "VEG", "VEG"};
    int[] bills = {7200, 4500, 3600, 7200};
    System.out.printf("%-10s %-9s %8s%n", "NAME", "TYPE", "BILL");
    int total = 0;
    for (int i = 0; i < names.length; i++) {
        System.out.printf("%-10s %-9s %8d%n", names[i], types[i], bills[i]);
        total += bills[i];
    }
    System.out.printf("%-10s %-9s %8d%n", "TOTAL", "", total);
    System.out.println(String.format("[%-10s %8d]", "Ravi", 7200));
    System.out.println("[%-10s %8d]".formatted("Ravi", 7200));
}
