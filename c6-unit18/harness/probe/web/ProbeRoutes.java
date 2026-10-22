package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * The course's harness, never TiffinBox's: four routes. /probe/ok answers a small JSON map; /probe/big a list of 2,000 strings - long
 * enough that Tomcat has sent part of it before the handler's hooks finish; /probe/oops throws a ProbeOops (ProbeAdvice handles it);
 * /probe/boom an IllegalStateException nobody handles.
 */
@RestController
public class ProbeRoutes {

    @GetMapping("/probe/ok")
    Map<String, String> ok() {
        Trace.log("ProbeRoutes     ok");
        return Map.of("answer", "ok");
    }

    @GetMapping("/probe/big")
    List<String> big() {
        Trace.log("ProbeRoutes     big");
        return Collections.nCopies(2000, "0123456789");
    }

    @GetMapping("/probe/oops")
    Map<String, String> oops() {
        Trace.log("ProbeRoutes     oops (throws a ProbeOops)");
        throw new ProbeOops("the controller says oops");
    }

    @GetMapping("/probe/boom")
    Map<String, String> boom() {
        Trace.log("ProbeRoutes     boom (throws an IllegalStateException)");
        throw new IllegalStateException("the kitchen is on fire");
    }
}
