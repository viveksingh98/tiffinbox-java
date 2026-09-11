void main() {
    var lines = Files.readAllLines(Path.of("customers.csv"));
    IO.println(lines.size() + " customers on file");
}
