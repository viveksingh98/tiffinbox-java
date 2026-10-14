package probe.web;

import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources. One question: how does a JSON
 * body become a record? A record has no setters and no constructor without arguments - only its canonical constructor, the
 * one whose parameters are its components. Plate's compact constructor - the canonical constructor's body, written without
 * its parameter list - counts each call, and the route answers with the record it was handed and the count, on one line.
 */
@RestController
public class Body {

    static final AtomicInteger CALLS = new AtomicInteger();

    /** A record of the harness's own, with a compact constructor: it runs on every call of the canonical constructor. */
    public record Plate(String name, int count) {
        public Plate {
            CALLS.incrementAndGet();
        }
    }

    @PostMapping("/probe/body/plate")
    public String plate(@RequestBody Plate plate) {
        return plate + " · canonical constructor calls so far: " + CALLS.get();
    }
}
