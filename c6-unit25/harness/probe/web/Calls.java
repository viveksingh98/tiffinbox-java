package probe.web;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Locale;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

/**
 * The course's harness, never TiffinBox's: Spring's RestClient calling the stub from inside TiffinBox's own JVM. An
 * ApplicationRunner - it runs once the context is up, before readiness answers - that does the cases --probe.cases names, in
 * that order, and prints one "CALL <case> ..." line per result; with no --probe.cases it does nothing. The stub's address is
 * --probe.stub. Every case that configures Boot's builder configures a clone() of it, never the injected object itself -
 * except "leak", which shows why.
 */
public class Calls implements ApplicationRunner {

    /** An exception of the harness's own, thrown by a status handler. */
    static class MenuMissing extends RuntimeException {
        MenuMissing(String message) { super(message); }
    }

    private final RestClient.Builder first;
    private final RestClient.Builder second;
    private final ConfigurableApplicationContext ctx;
    private final String stub;
    private final String cases;

    Calls(RestClient.Builder first, RestClient.Builder second, ConfigurableApplicationContext ctx, Environment env) {
        this.first = first;
        this.second = second;
        this.ctx = ctx;
        this.stub = env.getProperty("probe.stub", "http://127.0.0.1:19546");
        this.cases = env.getProperty("probe.cases", "");
    }

    static void out(String s) { System.out.println("CALL " + s); }

    /** The request factory a RestClient was built with, read off the client (its field clientRequestFactory). */
    static String factoryOf(RestClient c) {
        try {
            Field f = c.getClass().getDeclaredField("clientRequestFactory");
            f.setAccessible(true);
            return f.get(c).getClass().getName();
        } catch (ReflectiveOperationException e) {
            return "unreadable: " + e;
        }
    }

    /** An exception as its class, its message and its cause - each as it is. */
    static String ex(Throwable t) {
        Throwable c = t.getCause();
        return t.getClass().getName() + " | message: " + t.getMessage()
                + " | cause: " + (c == null ? "none" : c.getClass().getName() + ": " + c.getMessage());
    }

    @Override
    public void run(ApplicationArguments args) {
        if (cases.isEmpty()) return;
        out("the JVM's locale: " + Locale.getDefault());
        for (String k : cases.split(",")) {
            try {
                one(k);
            } catch (Exception e) {
                out(k + " threw, unexpected: " + ex(e));
            }
        }
        out("done");
    }

    private void one(String k) {
        switch (k) {
            case "beans" -> {
                var bf = ctx.getBeanFactory();
                for (String type : List.of("org.springframework.web.client.RestClient$Builder",
                        "org.springframework.boot.restclient.RestTemplateBuilder",
                        "org.springframework.boot.http.client.ClientHttpRequestFactoryBuilder",
                        "org.springframework.boot.http.client.HttpClientSettings",
                        "org.springframework.web.client.RestClient",
                        "org.springframework.web.client.RestTemplate")) {
                    String simple = type.substring(type.lastIndexOf('.') + 1).replace('$', '.');
                    Class<?> c;
                    try {
                        c = Class.forName(type);
                    } catch (ClassNotFoundException e) {
                        out("beans " + simple + ": the class is not on the class path");
                        continue;
                    }
                    String[] names = ctx.getBeanNamesForType(c);
                    if (names.length == 0) out("beans " + simple + ": no bean");
                    for (String n : names) {
                        String scope = bf.getBeanDefinition(n).getScope();
                        out("beans " + simple + ": " + n + " (scope " + (scope.isEmpty() ? "singleton" : scope) + ") -> "
                                + ctx.getType(n).getName());
                    }
                }
                out("beans two injection points, one builder object: " + (first == second));
            }
            case "factory" -> {
                out("factory Boot's builder bean: " + factoryOf(first.clone().build()));
                out("factory RestClient.create(): " + factoryOf(RestClient.create()));
                out("factory RestClient.builder(): " + factoryOf(RestClient.builder().build()));
            }
            case "same" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                List<Row> rows = c.get().uri("/customers.json").retrieve().body(new ParameterizedTypeReference<List<Row>>() { });
                int total = 0;
                for (Row r : rows) {
                    int bill = r.mealsPerDay() * r.pricePerMeal() * 30;
                    total += bill;
                    out("same " + r + " - a month: " + bill);
                }
                out("same rows: " + rows.size() + " - month total: " + total);
                out("same one file, body(Row.class): " + c.get().uri("/{f}", "meera.json").retrieve().body(Row.class));
            }
            case "404" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                try {
                    c.get().uri("/week-9.json").retrieve().body(String.class);
                    out("404 no exception");
                } catch (RestClientResponseException e) {
                    out("404 " + e.getClass().getName() + " - status " + e.getStatusCode().value() + " - message: " + e.getMessage());
                    StringBuilder chain = new StringBuilder(e.getClass().getSimpleName());
                    for (Class<?> s = e.getClass().getSuperclass(); s != RuntimeException.class; s = s.getSuperclass()) {
                        chain.append(" > ").append(s.getSimpleName());
                    }
                    out("404 its classes, up: " + chain + " - a RestClientException: " + (e instanceof RestClientException));
                }
            }
            case "exchange" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                HttpStatusCode code = c.get().uri("/week-9.json").exchange((req, res) -> res.getStatusCode());
                out("exchange /week-9.json -> " + code + " - no exception");
            }
            case "onstatus" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                try {
                    c.get().uri("/week-9.json").retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, (req, res) -> {
                                throw new MenuMissing("no menu at " + req.getURI().getPath() + ", the stub said " + res.getStatusCode().value());
                            })
                            .body(String.class);
                    out("onstatus no exception");
                } catch (MenuMissing e) {
                    out("onstatus " + ex(e));
                }
            }
            case "default" -> {
                RestClient handled = first.clone().baseUrl(stub)
                        .defaultStatusHandler(HttpStatusCode::isError, (req, res) -> {
                            throw new MenuMissing("the stub said " + res.getStatusCode().value() + " for " + req.getURI().getPath());
                        })
                        .build();
                for (String u : List.of("/week-9.json", "/status/500")) {
                    try {
                        handled.get().uri(u).retrieve().body(String.class);
                        out("default " + u + " no exception");
                    } catch (RuntimeException e) {
                        out("default " + u + " " + ex(e));
                    }
                }
                RestClient later = first.clone().baseUrl(stub).build();
                try {
                    later.get().uri("/week-9.json").retrieve().body(String.class);
                    out("default a later client, another clone: no exception");
                } catch (RuntimeException e) {
                    out("default a later client, another clone: " + e.getClass().getName());
                }
            }
            case "leak" -> {
                second.baseUrl(stub).defaultStatusHandler(HttpStatusCode::isError, (req, res) -> {
                    throw new MenuMissing("the stub said " + res.getStatusCode().value());
                });
                RestClient handled = second.build();
                RestClient later = second.baseUrl(stub).build();
                for (var e : List.of(java.util.Map.entry("the client it was configured for", handled), java.util.Map.entry("a later client, the same builder", later))) {
                    try {
                        e.getValue().get().uri("/week-9.json").retrieve().body(String.class);
                        out("leak " + e.getKey() + ": no exception");
                    } catch (RuntimeException x) {
                        out("leak " + e.getKey() + ": " + x.getClass().getName());
                    }
                }
            }
            case "5xx" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                for (String u : List.of("/status/500", "/status/503")) {
                    try {
                        c.get().uri(u).retrieve().body(String.class);
                        out("5xx " + u + " no exception");
                    } catch (RestClientResponseException e) {
                        out("5xx " + u + " " + e.getClass().getName() + " - status " + e.getStatusCode().value() + " - message: " + e.getMessage());
                    }
                }
            }
            case "slow" -> {
                RestClient c = first.clone().baseUrl(stub).build();
                try {
                    out("slow /slow?ms=3000 answered: " + c.get().uri("/slow?ms=3000").retrieve().body(String.class));
                } catch (RestClientException e) {
                    out("slow /slow?ms=3000 cancelled: " + ex(e));
                }
            }
            case "redirect" -> {
                for (var e : List.of(java.util.Map.entry("Boot's builder", first.clone().baseUrl(stub).build()),
                        java.util.Map.entry("RestClient.create()", RestClient.create(stub)))) {
                    ResponseEntity<String> r = e.getValue().get().uri("/redirect").retrieve().toEntity(String.class);
                    out("redirect " + e.getKey() + ": /redirect -> " + r.getStatusCode().value() + " " + r.getBody().strip());
                }
            }
            case "metrics" -> {
                RestClient viaBuilder = first.clone().baseUrl(stub).build();
                RestClient viaCreate = RestClient.create(stub);
                for (int i = 0; i < 2; i++) viaBuilder.get().uri("/{f}", "ravi.json").retrieve().body(Row.class);
                for (int i = 0; i < 3; i++) viaCreate.get().uri("/{name}", "priya.json").retrieve().body(Row.class);
                out("metrics Boot's builder: 2 calls, uri template /{f} - RestClient.create(): 3 calls, uri template /{name}");
            }
            case "down" -> {
                RestClient c = first.clone().baseUrl("http://127.0.0.1:19549").build();
                try {
                    c.get().uri("/customers.json").retrieve().body(String.class);
                    out("down no exception");
                } catch (RestClientException e) {
                    out("down " + ex(e));
                }
            }
            default -> out("unknown case " + k);
        }
    }
}
