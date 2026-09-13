import java.util.WeakHashMap;

void main() {
    var cache = new WeakHashMap<Object, String>();
    Object key = new Object();
    cache.put(key, "Ravi: 7200");
    IO.println("cached entries:        " + cache.size());

    key = null;
    System.gc();
    // no Thread.sleep here

    IO.println("after key = null + gc: " + cache.size());
}
