package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;

/**
 * Course 9, unit 16: one order as HAL ({@link OrderResources}, GET /api/v1/orders/{id}) checked through MockMvc over the whole
 * application on H2 in memory - the shape of {@link CustomerFieldsTest}: the DispatcherServlet answers, with no socket and no HTTP
 * client. MockMvc's request host is localhost, so the links here start http://localhost/ - the wire's links carry the host the client
 * used (the receipts' hal capture, on a socket).
 *
 * <p>Five requests, each its own test, so a failure names the line that broke: order 1 as application/hal+json (its body, self and
 * customer); the same order under Accept: application/json (the same body, the type application/json); an id no order has (refused,
 * order-unknown); a query parameter (refused, parameter-unknown); an id that is not a number (Framework's four hundred, with no type of
 * TiffinBox's). The bodies come from unit 16's hal, accept and refuse captures, measured on the route before this test was written.
 *
 * <p>What it does NOT catch: the wire's host and bytes (hal, accept); the forwarded headers (forwarded); the served document against the
 * wire (specwire); PostgreSQL (verify runs the anchor's ITs there).
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class OrderResourcesTest {

    @Autowired WebApplicationContext ctx;

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private static final String ORDER_ONE = "{\"_links\":{\"self\":{\"href\":\"http://localhost/api/v1/orders/1\"},"
            + "\"customer\":{\"href\":\"http://localhost/api/v1/customers/Ravi\"}},"
            + "\"id\":1,\"customer\":\"Ravi\",\"mealType\":\"VEG\",\"amount\":240,\"placedAt\":\"2026-11-01T08:00:00Z\"}";

    private MockHttpServletResponse ask(String path, String accept) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MockHttpServletResponse a = mvc.perform(get(path).header("Accept", accept)).andReturn().getResponse();
        System.out.println("OrderResourcesTest: GET " + path + " (Accept " + accept + ") -> " + a.getStatus());
        return a;
    }

    private static String text(MockHttpServletResponse a) throws Exception {
        return a.getContentAsString(StandardCharsets.UTF_8);
    }

    private static JsonNode problem(MockHttpServletResponse a, int status) throws Exception {
        assertThat(a.getStatus()).isEqualTo(status);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        return JSON.readTree(text(a));
    }

    @Test
    void orderOneIsHalWithItsTwoLinks() throws Exception {
        MockHttpServletResponse a = ask("/api/v1/orders/1", "application/hal+json");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("application/hal+json");
        assertThat(text(a)).isEqualTo(ORDER_ONE);
        JsonNode o = JSON.readTree(text(a));
        assertThat(o.get("_links").propertyNames()).containsExactly("self", "customer");
    }

    @Test
    void underApplicationJsonTheSameBody() throws Exception {
        MockHttpServletResponse a = ask("/api/v1/orders/1", "application/json");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("application/json");
        assertThat(text(a)).isEqualTo(ORDER_ONE);
    }

    @Test
    void anUnknownIdIsRefused() throws Exception {
        JsonNode p = problem(ask("/api/v1/orders/21", "application/hal+json"), 404);
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:order-unknown");
        assertThat(p.get("detail").asString()).isEqualTo("no order with id 21");
    }

    @Test
    void aQueryParameterIsRefused() throws Exception {
        JsonNode p = problem(ask("/api/v1/orders/1?x=1", "application/hal+json"), 400);
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:parameter-unknown");
    }

    @Test
    void aNonNumericIdIsFrameworksRefusalWithNoType() throws Exception {
        JsonNode p = problem(ask("/api/v1/orders/abc", "application/hal+json"), 400);
        assertThat(p.has("type")).isFalse();
        assertThat(p.get("title").asString()).isEqualTo("Bad Request");
    }
}
