import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Bug two, on its own. The same two entries through Jackson twice: once in a Map.of,
 * once in a LinkedHashMap. Run it six times in a row and watch only one of them move.
 *
 *   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
 *   cd ..            # the capstone project, already packaged
 *   for i in 1 2 3 4 5 6; do java -cp "target/lib/*:breaks" breaks/MapOrder.java; done
 */
public class MapOrder {

    public static void main(String[] args) throws Exception {
        var json = new ObjectMapper();

        Map<String, Object> unordered = Map.of("ordersCooked", 120, "ordersValue", 24300);

        var ordered = new LinkedHashMap<String, Object>();
        ordered.put("ordersCooked", 120);
        ordered.put("ordersValue", 24300);

        System.out.println("Map.of         " + json.writeValueAsString(unordered));
        System.out.println("LinkedHashMap  " + json.writeValueAsString(ordered));
    }
}
