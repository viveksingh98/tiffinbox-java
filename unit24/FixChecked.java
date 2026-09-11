void main() throws IOException {
    Files.writeString(Path.of("customers.csv"), "Ravi,2,120,true\n");
    var lines = Files.readAllLines(Path.of("customers.csv"));
    IO.println(lines.size() + " customers on file");
}
