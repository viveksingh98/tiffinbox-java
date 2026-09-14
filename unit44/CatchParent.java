void main() {
    try {
        "cottage cheese curry".substring(14, 8);
    } catch (IndexOutOfBoundsException e) {
        IO.println("caught as IndexOutOfBoundsException: " + e.getClass().getName());
        IO.println("message: " + e.getMessage());
    }
}
