package probe.web;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** The course's harness: the same three versions with the version in the path - /api/{v}/menu, the segment at index 1
 *  (index 0 is "api"). Read by the path-segment strategy alone. */
@RestController
public class MenuPath {
    @GetMapping(path = "/api/{v}/menu", version = "1.0")
    Map<String, Object> names() { return Menu.answer("1.0", "the path"); }

    @GetMapping(path = "/api/{v}/menu", version = "1.1+")
    Map<String, Object> count() { return Menu.answer("1.1+", "the path"); }

    @GetMapping(path = "/api/{v}/menu", version = "2.0")
    Map<String, Object> monthTotal() { return Menu.answer("2.0", "the path"); }
}
