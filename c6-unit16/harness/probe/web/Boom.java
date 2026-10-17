package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. One route that fails on purpose, because TiffinBox itself has no route that throws an unexpected exception: /probe/boom
 * throws an IllegalStateException with a fixed message - an error nobody decided on, which no advice handles.
 */
@RestController
public class Boom {

    @GetMapping("/probe/boom")
    String boom() {
        throw new IllegalStateException("the kitchen is on fire");
    }
}
