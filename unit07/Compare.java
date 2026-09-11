void main() {
    String stored = "veg";
    String prefix = "ve";
    String typed = prefix + "g";
    IO.println(typed);
    IO.println(stored);
    IO.println(typed == stored);
    IO.println(typed.equals(stored));
    IO.println("VEG".equalsIgnoreCase(stored));
}
