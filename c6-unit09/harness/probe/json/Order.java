package probe.json;

import java.lang.reflect.RecordComponent;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's (outside com.tiffinbox, joined by --spring.main.sources). The order Jackson writes an
 * object's properties in, asked of Boot's mapper through Spring MVC's JSON converter: a record of its own, Plate(zeta, alpha,
 * mid); a class with the same three public fields, Tray; a map the same three keys are put in, in that order (a LinkedHashMap,
 * as TiffinBox's own map answers are); and the components of TiffinBox's own record, com.tiffinbox.Customer, read off the class
 * in the order it declares them, beside the same names sorted. Each route returns its type, never Object.
 */
@RestController
public class Order {

    public record Plate(String zeta, int alpha, String mid) { }

    public static class Tray {
        public String zeta = "z";
        public int alpha = 1;
        public String mid = "m";
    }

    @GetMapping("/probe/order/record")
    public Plate record() {
        return new Plate("z", 1, "m");
    }

    @GetMapping("/probe/order/class")
    public Tray tray() {
        return new Tray();
    }

    @GetMapping("/probe/order/map")
    public Map<String, Object> map() {
        var m = new LinkedHashMap<String, Object>();
        m.put("zeta", "z");
        m.put("alpha", 1);
        m.put("mid", "m");
        return m;
    }

    @GetMapping("/probe/order/customer")
    public String customer() throws Exception {
        List<String> declared = new ArrayList<>();
        for (RecordComponent c : Class.forName("com.tiffinbox.Customer").getRecordComponents()) {
            declared.add(c.getName());
        }
        List<String> sorted = new ArrayList<>(declared);
        sorted.sort(null);
        return "com.tiffinbox.Customer's components, in the order the record declares them: " + String.join(" ", declared)
                + " · the same names sorted: " + String.join(" ", sorted) + "\n";
    }
}
