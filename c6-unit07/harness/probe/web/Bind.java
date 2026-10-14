package probe.web;

import java.util.List;
import java.util.Optional;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.MatrixVariable;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.web.Bind on the
 * extracted jar's class path. One route per binding annotation and default, each answering with the value its parameter got,
 * in brackets where an empty value must show - one line, no newline, so curl's status lands on the same line.
 */
@RestController
public class Bind {

    @GetMapping("/probe/bind/name/{name}")
    public String name(@PathVariable String name) {
        return "name=[" + name + "]";
    }

    @GetMapping("/probe/bind/param")
    public String param(@RequestParam String q) {
        return "q=[" + q + "]";
    }

    @GetMapping("/probe/bind/default")
    public String days(@RequestParam(defaultValue = "30") int days) {
        return "days=" + days;
    }

    @GetMapping("/probe/bind/optional")
    public String optional(@RequestParam Optional<Integer> days) {
        return "days=" + days;
    }

    @GetMapping("/probe/bind/list")
    public String list(@RequestParam List<String> tag) {
        return "tag=" + tag;
    }

    @GetMapping("/probe/bind/header")
    public String header(@RequestHeader("X-Meal") String meal) {
        return "meal=" + meal;
    }

    @GetMapping("/probe/bind/cookie")
    public String cookie(@CookieValue("plan") String plan) {
        return "plan=" + plan;
    }

    @GetMapping("/probe/bind/matrix/{day}")
    public String matrix(@PathVariable String day, @MatrixVariable(required = false) String veg) {
        return "day=" + day + " veg=" + veg;
    }

    @GetMapping("/probe/bind/attr")
    public String attr(@RequestAttribute("slip") String slip) {
        return "slip=" + slip;
    }
}
