void main() throws IOException {
    var lines = Files.readAllLines(Path.of("customer.csv"));
    IO.println(lines.size() + " customers on file");
}
