void main() {
    var rt = Runtime.getRuntime();
    long mb = 1024 * 1024;

    long max   = rt.maxMemory();
    long total = rt.totalMemory();
    long free  = rt.freeMemory();
    long used  = total - free;
    int cores  = rt.availableProcessors();

    IO.println("Max heap:   " + max / mb + " MB");
    IO.println("Total heap: " + total / mb + " MB");
    IO.println("Free heap:  " + free / mb + " MB");
    IO.println("Used heap:  " + used / mb + " MB");
    IO.println("CPU cores:  " + cores);
}
