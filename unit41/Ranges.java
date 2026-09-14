void main() {
    System.out.printf("%-9s%4s%24s  %s%n", "TYPE", "BITS", "MIN", "MAX");
    System.out.printf("%-10s%2d%24s  %s%n", "byte",   Byte.SIZE,      Byte.MIN_VALUE,      Byte.MAX_VALUE);
    System.out.printf("%-10s%2d%24s  %s%n", "short",  Short.SIZE,     Short.MIN_VALUE,     Short.MAX_VALUE);
    System.out.printf("%-10s%2d%24s  %s%n", "int",    Integer.SIZE,   Integer.MIN_VALUE,   Integer.MAX_VALUE);
    System.out.printf("%-10s%2d%24s  %s%n", "long",   Long.SIZE,      Long.MIN_VALUE,      Long.MAX_VALUE);
    System.out.printf("%-10s%2d%24s  %s%n", "float",  Float.SIZE,     Float.MIN_VALUE,     Float.MAX_VALUE);
    System.out.printf("%-10s%2d%24s  %s%n", "double", Double.SIZE,    Double.MIN_VALUE,    Double.MAX_VALUE);
    System.out.printf("%-10s%2d%24d  %d%n", "char",   Character.SIZE, (int) Character.MIN_VALUE, (int) Character.MAX_VALUE);
    IO.println("boolean: 1 bit of meaning, true or false");
}
