void main() {
    var in = new Scanner(System.in);
    String line = in.nextLine();
    IO.println("Scanner on a blank line: [" + line + "] null? " + (line == null));
    IO.println("hasNextLine now       : " + in.hasNextLine());
}
