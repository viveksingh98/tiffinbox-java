void main() {
    var in = new Scanner(System.in);
    IO.println("next()        left: [" + leftOver(in, in.next()) + "]");
    IO.println("nextDouble()  left: [" + leftOver(in, in.nextDouble()) + "]");
    IO.println("nextBoolean() left: [" + leftOver(in, in.nextBoolean()) + "]");
}

String leftOver(Scanner in, Object taken) {
    return taken + "] rest of that line: [" + in.nextLine();
}
