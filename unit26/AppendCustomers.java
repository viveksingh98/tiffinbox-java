void main() throws IOException {
    var path = Path.of("customers.csv");
    Files.writeString(path, "Ravi,2,120,true\nMeera,1,150,false\n");
    Files.writeString(path, "Sunil,1,120,true\n", StandardOpenOption.APPEND);
    try (var lines = Files.lines(path)) {
        IO.println(lines.count() + " customers on file");
    }
    IO.println(Files.readAllLines(path).getLast());
}
