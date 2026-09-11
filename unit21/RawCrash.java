void main() {
    List names = new ArrayList();
    names.add("Ravi");
    names.add(42);
    for (Object o : names) {
        String name = (String) o;
        IO.println(name.length());
    }
}
