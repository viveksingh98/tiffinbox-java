import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.TimeUnit;

void main() throws Exception {
    var rail = new ArrayBlockingQueue<String>(2);
    IO.println("offer 1: " + rail.offer("Ravi 1"));
    IO.println("offer 2: " + rail.offer("Meera 1"));
    IO.println("offer 3: " + rail.offer("Sunil 1") + "   <- silently dropped");
    IO.println("offer 3 with a deadline: " + rail.offer("Sunil 1", 200, TimeUnit.MILLISECONDS));
    IO.println("queue size: " + rail.size() + ", remaining capacity: " + rail.remainingCapacity());
    rail.add("Priya 1");
}
