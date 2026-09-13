import java.util.LinkedHashMap;
import java.util.Map;

void main() {
    // the last true = access order: get() moves an entry to the newest end
    var cache = new LinkedHashMap<String, Integer>(16, 0.75f, true) {
        protected boolean removeEldestEntry(Map.Entry<String, Integer> e) {
            return size() > 3;      // the ceiling
        }
    };

    cache.put("Ravi", 7200);
    cache.put("Meera", 5400);
    cache.put("Sam", 3600);
    cache.get("Ravi");            // touching Ravi makes him the newest
    cache.put("Nina", 4800);

    IO.println(cache.keySet());
}
