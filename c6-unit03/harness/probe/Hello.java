package probe;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The harness's own route, outside com.tiffinbox: one method, one annotation, and nothing that registers it. It answers a small
 * JSON object - written by whichever message converter Spring MVC picks, never by this class. It joins TiffinBox by
 * --spring.main.sources=probe.Hello.
 */
@RestController
public class Hello {

    @GetMapping("/probe/hello")
    Map<String, String> hello() {
        return Map.of("hello", "from a harness method");
    }
}
