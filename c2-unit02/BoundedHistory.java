import java.util.ArrayList;
import java.util.List;

static final List<byte[]> history = new ArrayList<>();

void main() {
    for (int day = 1; day <= 4; day++) {
        for (int i = 0; i < 10; i++) {
            history.add(new byte[1024 * 1024]);
            if (history.size() > 10) history.removeFirst();
        }
        IO.println("day " + day + ": history holds " + history.size() + " orders, " + usedMB() + " MB used");
    }
}

long usedMB() {
    System.gc();
    var rt = Runtime.getRuntime();
    return (rt.totalMemory() - rt.freeMemory()) / (1024 * 1024);
}
