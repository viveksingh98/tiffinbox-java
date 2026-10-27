package probe.web;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Locale;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.restclient.RestTemplateBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

/**
 * The course's harness, never TiffinBox's: RestTemplate - the client older Spring code calls out with - beside RestClient, from
 * inside TiffinBox's own JVM. An ApplicationRunner (it runs once the context is up, before readiness answers) that does the cases
 * --probe.cases names, in that order, one "TPL <case> ..." line per result; with no --probe.cases it does nothing. The stub's address
 * is --probe.stub. Every template from Boot's builder is built from the injected RestTemplateBuilder, which never changes: each of its
 * methods returns a new builder. Every RestClient from Boot's builder is built on a clone() of the injected RestClient.Builder.
 */
public class Templates implements ApplicationRunner {

    private final RestTemplateBuilder templates;
    private final RestClient.Builder clients;
    private final ConfigurableApplicationContext ctx;
    private final String stub;
    private final String cases;

    Templates(RestTemplateBuilder templates, RestClient.Builder clients, ConfigurableApplicationContext ctx, Environment env) {
        this.templates = templates;
        this.clients = clients;
        this.ctx = ctx;
        this.stub = env.getProperty("probe.stub", "http://127.0.0.1:19566");
        this.cases = env.getProperty("probe.cases", "");
    }

    static void out(String s) { System.out.println("TPL " + s); }

    /** A field of an object, read by reflection - the request factory a RestClient was built with, its interceptors. */
    static Object field(Object o, String name) {
        try {
            Field f = o.getClass().getDeclaredField(name);
            f.setAccessible(true);
            return f.get(o);
        } catch (ReflectiveOperationException e) {
            return "unreadable: " + e;
        }
    }

    static String names(List<?> l) {
        return l.stream().map(x -> x.getClass().getName()).toList().toString();
    }

    @Override
    public void run(ApplicationArguments args) {
        if (cases.isEmpty()) return;
        out("the JVM's locale: " + Locale.getDefault());
        for (String k : cases.split(",")) {
            try {
                one(k);
            } catch (Exception e) {
                out(k + " threw, unexpected: " + e.getClass().getName() + ": " + e.getMessage());
            }
        }
        out("done");
    }

    /** One GET of a row through a template, and one /redirect: what came back. */
    private void calls(String k, RestTemplate t) {
        out(k + " its request factory: " + t.getRequestFactory().getClass().getName());
        out(k + " getForObject /{f} meera.json -> " + t.getForObject(stub + "/{f}", Row.class, "meera.json"));
        ResponseEntity<Row> r = t.getForEntity(stub + "/redirect", Row.class);
        out(k + " getForEntity /redirect -> " + r.getStatusCode().value() + " " + r.getBody());
    }

    private void one(String k) {
        switch (k) {
            case "beans" -> {
                var bf = ctx.getBeanFactory();
                for (Class<?> c : List.of(RestTemplateBuilder.class, RestTemplate.class, RestClient.Builder.class, RestClient.class)) {
                    String[] names = ctx.getBeanNamesForType(c);
                    String simple = c.getName().substring(c.getName().lastIndexOf('.') + 1).replace('$', '.');
                    if (names.length == 0) out("beans " + simple + ": no bean");
                    for (String n : names) {
                        var d = bf.getBeanDefinition(n);
                        out("beans " + simple + ": " + n + " (scope " + (d.getScope().isEmpty() ? "singleton" : d.getScope()) + ") -> "
                                + ctx.getType(n).getName() + " | made by: " + d.getFactoryBeanName());
                    }
                }
            }
            case "side" -> {
                RestTemplate t = templates.build();
                RestClient c = clients.clone().baseUrl(stub).build();
                Class<?> a = null, b = null;
                try {
                    t.getForObject(stub + "/week-9.json", String.class);
                    out("side the template, getForObject /week-9.json: no exception");
                } catch (RestClientResponseException e) {
                    a = e.getClass();
                    out("side the template, getForObject /week-9.json -> " + e.getClass().getName() + " | status " + e.getStatusCode().value() + " | message: " + e.getMessage());
                }
                try {
                    c.get().uri("/week-9.json").retrieve().body(String.class);
                    out("side RestClient, retrieve /week-9.json: no exception");
                } catch (RestClientResponseException e) {
                    b = e.getClass();
                    out("side RestClient, retrieve /week-9.json -> " + e.getClass().getName() + " | status " + e.getStatusCode().value() + " | message: " + e.getMessage());
                }
                out("side the same exception class: " + (a != null && a == b));
                out("side the template, getForObject /{f} meera.json, Row.class -> " + t.getForObject(stub + "/{f}", Row.class, "meera.json"));
                out("side RestClient, retrieve /{f} meera.json, body(Row.class) -> " + c.get().uri("/{f}", "meera.json").retrieve().body(Row.class));
                out("side the template's message converters: " + t.getMessageConverters().size() + " " + names(t.getMessageConverters()));
            }
            case "boot" -> calls("boot", templates.build());
            case "new" -> calls("new", new RestTemplate());
            case "migrate" -> {
                RestTemplate t = templates.additionalInterceptors(new Via()).build();
                RestClient fromCreate = RestClient.create(t);
                RestClient fromBuilder = RestClient.builder(t).build();
                RestClient plain = RestClient.create();
                out("migrate the template: its interceptors " + names(t.getInterceptors()) + " | its request factory " + t.getRequestFactory().getClass().getName());
                out("migrate the template, getForObject /{f} ravi.json -> " + t.getForObject(stub + "/{f}", Row.class, "ravi.json"));
                for (var e : List.of(java.util.Map.entry("RestClient.create(template)", fromCreate), java.util.Map.entry("RestClient.builder(template).build()", fromBuilder))) {
                    out("migrate " + e.getKey() + ": its interceptors " + names((List<?>) field(e.getValue(), "interceptors"))
                            + " | its request factory " + field(e.getValue(), "clientRequestFactory").getClass().getName());
                    out("migrate " + e.getKey() + ", retrieve /{f} ravi.json -> " + e.getValue().get().uri(stub + "/{f}", "ravi.json").retrieve().body(Row.class));
                }
                Object none = field(plain, "interceptors");
                out("migrate RestClient.create(): its interceptors " + (none == null ? "none" : names((List<?>) none)) + " | its request factory " + field(plain, "clientRequestFactory").getClass().getName());
                out("migrate RestClient.create(), retrieve /{name} ravi.json -> " + plain.get().uri(stub + "/{name}", "ravi.json").retrieve().body(Row.class));
            }
            default -> out("unknown case " + k);
        }
    }
}
