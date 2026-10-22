package probe.web;

import java.util.Locale;
import java.util.Map;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * The exercise's class - the course's harness, never TiffinBox's. The kitchen's menu, for one other origin: http://127.0.0.1:19486
 * may read it and PUT to it (@CrossOrigin). And, for the kitchen's admin pages, a CORS rule of their own. Ask the menu's preflight,
 * read which CORS headers come back - then make them come back.
 */
@RestController
public class KitchenCors {

    public KitchenCors() {
        System.out.println("KitchenCors: the JVM's locale: " + Locale.getDefault());
    }

    @CrossOrigin(origins = "http://127.0.0.1:19486")
    @RequestMapping(path = "/kitchen/menu", method = {RequestMethod.GET, RequestMethod.PUT})
    public Map<String, String> menu() {
        return Map.of("menu", "kitchen");
    }
}
