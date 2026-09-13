import java.util.WeakHashMap;

void main() throws InterruptedException {
    var literal = new WeakHashMap<String, String>();
    String k1 = "Ravi";                  // interned literal
    literal.put(k1, "7200");
    k1 = null;

    var fresh = new WeakHashMap<String, String>();
    String k2 = new String("Ravi");      // a fresh object
    fresh.put(k2, "7200");
    k2 = null;

    System.gc();
    Thread.sleep(100);
    IO.println("literal key cache: " + literal.size());
    IO.println("new String() cache: " + fresh.size());
}
