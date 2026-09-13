import com.sun.management.ThreadMXBean;
import java.lang.management.ManagementFactory;

void main() {
    var bean = (ThreadMXBean) ManagementFactory.getThreadMXBean();
    long id = Thread.currentThread().threadId();
    long check = 0;
    for (int round = 1; round <= 6; round++) {
        long before = bean.getThreadAllocatedBytes(id);
        check += sumOfCoords(2_000_000);
        long after = bean.getThreadAllocatedBytes(id);
        IO.println("round " + round + ": allocated " + (after - before) / 1024 + " KB");
    }
    IO.println("checksum: " + check);
}

long sumOfCoords(int n) {
    long total = 0;
    for (int i = 0; i < n; i++) {
        var p = new Point(i, i + 1);
        total += p.x() + p.y();
    }
    return total;
}

record Point(int x, int y) {}
