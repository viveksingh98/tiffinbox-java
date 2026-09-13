void main() {
    IO.println("start:              " + usedMb() + " MB used");

    var bills = new byte[50][];
    for (int i = 0; i < 50; i++) bills[i] = new byte[1024 * 1024];
    IO.println("after allocating:   " + usedMb() + " MB used");

    bills = null;
    IO.println("after bills = null: " + usedMb() + " MB used");

    System.gc();
    IO.println("after System.gc():  " + usedMb() + " MB used");
}

long usedMb() {
    var rt = Runtime.getRuntime();
    return (rt.totalMemory() - rt.freeMemory()) / (1024 * 1024);
}
