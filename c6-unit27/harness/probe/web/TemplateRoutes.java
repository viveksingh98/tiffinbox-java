package probe.web;

import org.springframework.boot.restclient.RestTemplateBuilder;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestTemplate;

/**
 * The course's harness, never TiffinBox's: two routes on TiffinBox's server, the old call and the moved one. GET /probe/old reads
 * Ravi's row from the stub through a template - Boot's builder, with the interceptor that says X-Via - as older code would. GET
 * /probe/moved reads the same row through the RestClient the call was moved to. Neither catches anything. It prints the JVM's locale
 * once, when Spring makes it ("ROUTE the JVM's locale: ...").
 */
@RestController
public class TemplateRoutes {

    private final RestTemplate template;
    private final RestClient moved;
    private final String stub;

    TemplateRoutes(RestTemplateBuilder builder, Environment env) {
        this.stub = env.getProperty("probe.stub", "http://127.0.0.1:19566");
        this.template = builder.additionalInterceptors(new Via()).build();
        this.moved = RestClient.create();
        System.out.println("ROUTE the JVM's locale: " + java.util.Locale.getDefault());
    }

    @GetMapping("/probe/old")
    Row old() {
        return template.getForObject(stub + "/{f}", Row.class, "ravi.json");
    }

    @GetMapping("/probe/moved")
    Row moved() {
        return moved.get().uri(stub + "/{f}", "ravi.json").retrieve().body(Row.class);
    }
}
