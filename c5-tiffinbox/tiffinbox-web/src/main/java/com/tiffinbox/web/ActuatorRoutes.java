package com.tiffinbox.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.actuate.autoconfigure.endpoint.condition.ConditionalOnAvailableEndpoint;
import org.springframework.boot.actuate.autoconfigure.endpoint.expose.IncludeExcludeEndpointFilter;
import org.springframework.boot.actuate.endpoint.EndpointAccessResolver;
import org.springframework.boot.actuate.endpoint.InvocationContext;
import org.springframework.boot.actuate.endpoint.OperationArgumentResolver;
import org.springframework.boot.actuate.endpoint.OperationFilter;
import org.springframework.boot.actuate.endpoint.ProducibleOperationArgumentResolver;
import org.springframework.boot.actuate.endpoint.SecurityContext;
import org.springframework.boot.actuate.endpoint.invoke.OperationInvokerAdvisor;
import org.springframework.boot.actuate.endpoint.invoke.ParameterValueMapper;
import org.springframework.boot.actuate.endpoint.web.EndpointMediaTypes;
import org.springframework.boot.actuate.endpoint.web.ExposableWebEndpoint;
import org.springframework.boot.actuate.endpoint.web.WebEndpointResponse;
import org.springframework.boot.actuate.endpoint.web.WebEndpointsSupplier;
import org.springframework.boot.actuate.endpoint.web.WebOperation;
import org.springframework.boot.actuate.endpoint.web.WebServerNamespace;
import org.springframework.boot.actuate.endpoint.web.annotation.WebEndpointDiscoverer;
import org.springframework.boot.health.actuate.endpoint.HealthEndpoint;
import org.springframework.boot.health.actuate.endpoint.HealthEndpointGroups;
import org.springframework.boot.health.actuate.endpoint.HealthEndpointWebExtension;
import org.springframework.boot.health.registry.HealthContributorRegistry;
import org.springframework.boot.health.registry.ReactiveHealthContributorRegistry;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.io.Resource;

/**
 * Boot's Actuator endpoints, served by TiffinBox's own server under /actuator.
 *
 * <p>Course 5: Boot's HTTP side of Actuator waits for a web application it knows - Spring MVC or WebFlux on Tomcat,
 * Jetty or Netty (Course 6). TiffinBox's server is the JDK's, so to Boot it is no web application, and the starter
 * alone answers nothing over HTTP. In a Spring MVC application Boot writes this adapter for you; here TiffinBox writes
 * it, from Boot's own parts. An endpoint is a bean with operations, HTTP is one adapter, and exposure is a filter.
 */
@Configuration(proxyBeanMethods = false)
public class ActuatorRoutes {

    /** TiffinBox's own Jackson, version 2: the JSON library its routes already write with. */
    private static final ObjectMapper JSON = new ObjectMapper();

    /**
     * Boot's own discovery of each endpoint's web operations, through two filters: exposure
     * (management.endpoints.web.exposure.*, health unless told otherwise) and access (management.endpoint.ID.access).
     * A bean, so that Spring's ahead-of-time step reads the hints its class declares: the native binary needs them.
     */
    @Bean
    WebEndpointDiscoverer webEndpointDiscoverer(ApplicationContext context, ParameterValueMapper mapper,
            ObjectProvider<OperationInvokerAdvisor> advisors, EndpointAccessResolver access, Environment env) {
        var exposure = new IncludeExcludeEndpointFilter<>(ExposableWebEndpoint.class, env,
                "management.endpoints.web.exposure", "health");
        return new WebEndpointDiscoverer(context, mapper, EndpointMediaTypes.DEFAULT, List.of(), List.of(),
                advisors.orderedStream().toList(), List.of(exposure), List.of(OperationFilter.byAccess(access)));
    }

    /** Health over HTTP: 503 when DOWN or OUT_OF_SERVICE, and no details unless asked for. Only while health is exposed. */
    @Bean
    @ConditionalOnAvailableEndpoint(endpoint = HealthEndpoint.class)
    HealthEndpointWebExtension healthEndpointWebExtension(HealthContributorRegistry registry,
            ObjectProvider<ReactiveHealthContributorRegistry> reactive, HealthEndpointGroups groups) {
        return new HealthEndpointWebExtension(registry, reactive.getIfAvailable(), groups, Duration.ofSeconds(10));
    }

    /** The handler TiffinBoxServer gives the context /actuator. */
    @Bean
    HttpHandler actuatorHandler(WebEndpointsSupplier endpoints) {
        return exchange -> handle(exchange, endpoints);
    }

    /** One request: the operation whose path and verb match it, invoked, and what it returns, written. */
    private static void handle(HttpExchange exchange, WebEndpointsSupplier endpoints) throws IOException {
        String path = exchange.getRequestURI().getPath().replaceFirst("^/actuator/?", "");
        boolean pathFound = false;
        try {
            for (ExposableWebEndpoint endpoint : endpoints.getEndpoints()) {
                for (WebOperation operation : endpoint.getOperations()) {
                    var predicate = operation.getRequestPredicate();
                    Map<String, Object> arguments = match(predicate.getPath(), path);
                    if (arguments == null) continue;
                    pathFound = true;
                    if (!predicate.getHttpMethod().name().equals(exchange.getRequestMethod())) continue;
                    byte[] body = exchange.getRequestBody().readAllBytes();
                    if (body.length > 0) arguments.putAll(JSON.readValue(body, Map.class));
                    Object result = operation.invoke(new InvocationContext(SecurityContext.NONE, arguments,
                            OperationArgumentResolver.of(WebServerNamespace.class, () -> WebServerNamespace.SERVER),
                            new ProducibleOperationArgumentResolver(() -> exchange.getRequestHeaders().get("Accept"))));
                    int status = result != null ? 200 : exchange.getRequestMethod().equals("GET") ? 404 : 204;
                    String type = predicate.getProduces().stream().findFirst().orElse("application/json");
                    if (result instanceof WebEndpointResponse<?> response) {
                        status = response.getStatus();
                        type = response.getContentType() != null ? response.getContentType().toString() : type;
                        result = response.getBody();
                    }
                    respond(exchange, status, type, result);
                    return;
                }
            }
            respond(exchange, pathFound ? 405 : 404, "application/json",
                    Map.of("error", pathFound ? "method not allowed" : "not found"));
        } catch (Exception | LinkageError e) {      // a LinkageError: a class, or a native binary's hint, is missing
            System.Logger log = System.getLogger("tiffinbox");     // TiffinBox's own logger: every 500 here is logged, at ERROR
            if (e instanceof LinkageError) {         // TiffinBox's own fault: the error and its trace
                log.log(System.Logger.Level.ERROR, "an actuator request failed", e);
            } else {                                 // its message can quote what the client sent - a body, a level: the class alone
                log.log(System.Logger.Level.ERROR, "an actuator request failed: {0}", e.getClass().getName());
            }
            respond(exchange, 500, "application/json", Map.of("error", e.getClass().getSimpleName()));
        }
    }

    /** "health/{*path}" or "loggers/{name}" against the request's path: the path's variables, or null when it differs. */
    private static Map<String, Object> match(String pattern, String path) {
        String[] want = pattern.split("/"), got = path.isEmpty() ? new String[0] : path.split("/");
        Map<String, Object> variables = new HashMap<>();
        for (int i = 0; i < want.length; i++) {
            if (want[i].startsWith("{*")) {                         // every segment that is left
                variables.put(want[i].substring(2, want[i].length() - 1), Arrays.copyOfRange(got, Math.min(i, got.length), got.length));
                return variables;
            }
            if (i >= got.length) return null;
            if (want[i].startsWith("{")) variables.put(want[i].substring(1, want[i].length() - 1), got[i]);
            else if (!want[i].equals(got[i])) return null;
        }
        return want.length == got.length ? variables : null;
    }

    /** A Resource (a heap dump's file) is streamed; bytes (a scrape) and a String (text) are written as they are; anything
     *  else is JSON. */
    private static void respond(HttpExchange exchange, int status, String type, Object value) throws IOException {
        exchange.getResponseHeaders().add("Content-Type", type);
        if (value instanceof Resource file) {
            exchange.sendResponseHeaders(status, file.contentLength());
            try (var in = file.getInputStream(); var out = exchange.getResponseBody()) { in.transferTo(out); }
            return;
        }
        byte[] body = value == null ? new byte[0] : value instanceof byte[] bytes ? bytes
                : value instanceof String text ? text.getBytes(StandardCharsets.UTF_8) : JSON.writeValueAsBytes(value);
        exchange.sendResponseHeaders(status, body.length == 0 ? -1 : body.length);
        try (var out = exchange.getResponseBody()) { out.write(body); }
    }
}
