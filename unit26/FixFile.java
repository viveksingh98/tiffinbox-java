void main() throws IOException {
    var path = Path.of("customer.csv");
    try {
        var lines = Files.readAllLines(path);
        IO.println(lines.size() + " customers on file");
    } catch (NoSuchFileException e) {
        IO.println("No file yet, starting empty: " + e.getMessage());
    }
}
