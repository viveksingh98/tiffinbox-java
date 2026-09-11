void main() throws IOException {
    var path = Path.of("customers.csv");
    Files.writeString(path, "Ravi,2,120,true\nMeera,1,150,false\n");
    var lines = Files.readAllLines(path);
    IO.println(lines.size() + " customers on file");
    for (var line : lines) {
        IO.println("- " + line);
    }
    IO.println(Files.readString(path));
}
