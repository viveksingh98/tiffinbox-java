// One million 32-character Latin-1 note lines, then measure the heap that holds them.
// Run:  java -Xms1g -Xmx1g -XX:+UseSerialGC Heap.java
// Then: java -Xms1g -Xmx1g -XX:+UseSerialGC -XX:-CompactStrings Heap.java
void main() {
    int n = 1_000_000;
    String[] notes = new String[n];
    for (int i = 0; i < n; i++) {
        notes[i] = "delivered lunch note no." + String.format("%08d", i);
    }
    System.gc();
    Runtime rt = Runtime.getRuntime();
    long used = rt.totalMemory() - rt.freeMemory();
    IO.println("notes held:     " + notes.length);
    IO.println("length of one:  " + notes[0].length() + " characters");
    IO.println("used heap:      " + (used / (1024 * 1024)) + " MB");
}
