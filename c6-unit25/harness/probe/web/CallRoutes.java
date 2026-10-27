package probe.web;

import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;

/**
 * The course's harness, never TiffinBox's: a route on TiffinBox's server that calls the stub, so that a failure on the other
 * side meets TiffinBox's own error handling. GET /probe/remote?path=/x asks the stub for /x with a RestClient built once, from
 * Boot's builder bean, and answers with the stub's body as it came. It catches nothing. It prints the JVM's locale once, when
 * Spring makes it ("ROUTE the JVM's locale: ...").
 */
@RestController
public class CallRoutes {

    private final RestClient stub;

    CallRoutes(RestClient.Builder builder, Environment env) {
        this.stub = builder.baseUrl(env.getProperty("probe.stub", "http://127.0.0.1:19546")).build();
        System.out.println("ROUTE the JVM's locale: " + java.util.Locale.getDefault());
    }

    @GetMapping("/probe/remote")
    String remote(@RequestParam String path) {
        return stub.get().uri(path).retrieve().body(String.class);
    }
}
