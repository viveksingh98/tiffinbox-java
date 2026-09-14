void main() {
    String lid = "Meera 🍛";
    IO.println(lid);
    IO.println("length()        : " + lid.length());
    IO.println("codePointCount(): " + lid.codePointCount(0, lid.length()));
    String line = "Ravi%nMeera".formatted();
    IO.println("%n bytes: " + line.getBytes().length + " " + Arrays.toString(line.getBytes()));
    String slashN = "Ravi\nMeera";
    IO.println("\\n bytes: " + slashN.getBytes().length + " " + Arrays.toString(slashN.getBytes()));
}
