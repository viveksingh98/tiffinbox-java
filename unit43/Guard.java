void main() {
    var in = new Scanner(System.in);
    System.out.print("Customer name: ");
    if (!in.hasNextLine()) {
        IO.println("(no input - closing TiffinBox)");
        return;
    }
    IO.println("Welcome " + in.nextLine());
}
