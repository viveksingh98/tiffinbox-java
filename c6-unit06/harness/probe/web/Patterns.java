package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.web.Patterns on the
 * extracted jar's class path. Three path patterns Spring MVC's default parser takes, each answering with what it matched:
 * a path variable ({day}), a literal beside it (today), and a variable that takes the rest of the path ({*rest}).
 */
@RestController
public class Patterns {

    @GetMapping("/probe/menu/{day}")
    public String day(@PathVariable String day) {
        return "day=" + day + "\n";
    }

    @GetMapping("/probe/menu/today")
    public String today() {
        return "the literal route: today\n";
    }

    @GetMapping("/probe/files/{*rest}")
    public String rest(@PathVariable String rest) {
        return "rest=" + rest + "\n";
    }
}
