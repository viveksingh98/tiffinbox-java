package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. Two routes that fail on purpose, because TiffinBox itself has no route that throws an unexpected exception:
 * /probe/boom throws an IllegalStateException with a fixed message; /probe/boom-note throws one whose message quotes the request's
 * X-Order-Note header - the way a real bug puts a client's value into an exception message. The receipts send a planted canary
 * in that header (26 random hexadecimal digits, made per run), never the shutdown token.
 */
@RestController
public class Boom {

    @GetMapping("/probe/boom")
    String boom() {
        throw new IllegalStateException("the kitchen is on fire");
    }

    @GetMapping("/probe/boom-note")
    String boomNote(@RequestHeader(name = "X-Order-Note", required = false) String note) {
        throw new IllegalStateException("the kitchen could not read the note " + note);
    }
}
