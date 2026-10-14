package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.web.MidPattern. One
 * route whose pattern puts ** in the middle of the path - a pattern the older Ant-style matcher took, and Spring MVC's
 * default parser refuses when the context starts.
 */
@RestController
public class MidPattern {

    @GetMapping("/probe/kitchen/**/today")
    public String today() {
        return "the mid-path pattern: today\n";
    }
}
