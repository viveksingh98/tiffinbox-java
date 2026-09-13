import java.util.WeakHashMap;

void main() throws InterruptedException {
    var cache = new WeakHashMap<Object, String>();
    Object key = new Object();
    cache.put(key, "Ravi: 7200");
    IO.println("cached entries:        " + cache.size());

    key = null;
    System.gc();
    Thread.sleep(100);

    IO.println("after key = null + gc: " + cache.size());
}
