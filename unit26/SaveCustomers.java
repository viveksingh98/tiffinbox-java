void main() throws IOException {
    var path = Path.of("customers.csv");
    Files.writeString(path, "Ravi,2,120,true\nMeera,1,150,false\n");
    IO.println("Saved " + path.getFileName() + ": " + Files.exists(path) + ", " + Files.size(path) + " bytes");
}
