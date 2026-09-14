class MyString extends String {
    String shout() { return toUpperCase() + "!"; }
}

void main() {
    IO.println(new MyString().shout());
}
