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
 * Course 9, unit 14: the customer list ({@link CustomerFields}, GET /api/v1/customers) checked through MockMvc over the whole
 * application on H2 in memory - the shape of {@link OrderPagesTest}: the DispatcherServlet answers, with no socket and no HTTP client.
 * The seed's four customers are the first rows; nothing here writes one, but the context is shared with the classes that do, so each
 * test reads the seed's four at the head of the list and checks every element's members, never the list's length.
 *
 * <p>Five requests, each its own test, so a failure names the line that broke: the full list (its bytes); ?fields=name;
 * ?fields=mealType,name (the members in the record's order, not the request's); an unknown field (refused, field-unknown); an unknown
 * parameter (refused, parameter-unknown). The bodies come from unit 14's full and fields captures, measured on the route before this
 * test was written.
 *
 * <p>What it does NOT catch: the wire's compression and what a client hands back (the receipts' floor, grown and clients captures, on
 * a socket); PostgreSQL (verify runs the anchor's ITs there).
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class CustomerFieldsTest {

    @Autowired WebApplicationContext ctx;

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private MockHttpServletResponse ask(String query) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MockHttpServletResponse a = mvc.perform(get("/api/v1/customers" + query)).andReturn().getResponse();
        System.out.println("CustomerFieldsTest: GET /api/v1/customers" + query + " -> " + a.getStatus());
        return a;
    }

    private static String text(MockHttpServletResponse a) throws Exception {
        return a.getContentAsString(StandardCharsets.UTF_8);
    }

    /** The answer starts with the seed's four, as measured, and every element holds exactly these members, in this order. */
    private static void seedFirst(MockHttpServletResponse a, String seed, String... members) throws Exception {
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("application/json");
        assertThat(text(a)).startsWith(seed.substring(0, seed.length() - 1));
        for (JsonNode o : JSON.readTree(text(a))) assertThat(o.propertyNames()).containsExactly(members);
    }

    private void refused(String query, String type) throws Exception {
        MockHttpServletResponse a = ask(query);
        assertThat(a.getStatus()).isEqualTo(400);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        JsonNode p = JSON.readTree(text(a));
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:" + type);
    }

    @Test
    void theFullListHoldsEveryField() throws Exception {
        seedFirst(ask(""), "[{\"name\":\"Meera\",\"mealsPerDay\":1,\"pricePerMeal\":150,\"mealType\":\"NON_VEG\"},"
                + "{\"name\":\"Priya\",\"mealsPerDay\":1,\"pricePerMeal\":120,\"mealType\":\"VEGAN\"},"
                + "{\"name\":\"Ravi\",\"mealsPerDay\":2,\"pricePerMeal\":120,\"mealType\":\"VEG\"},"
                + "{\"name\":\"Sunil\",\"mealsPerDay\":3,\"pricePerMeal\":100,\"mealType\":\"VEG\"}]",
                "name", "mealsPerDay", "pricePerMeal", "mealType");
    }

    @Test
    void namesOnly() throws Exception {
        seedFirst(ask("?fields=name"), "[{\"name\":\"Meera\"},{\"name\":\"Priya\"},{\"name\":\"Ravi\"},{\"name\":\"Sunil\"}]", "name");
    }

    @Test
    void namesAndMealTypes() throws Exception {
        seedFirst(ask("?fields=mealType,name"), "[{\"name\":\"Meera\",\"mealType\":\"NON_VEG\"},{\"name\":\"Priya\",\"mealType\":\"VEGAN\"},"
                + "{\"name\":\"Ravi\",\"mealType\":\"VEG\"},{\"name\":\"Sunil\",\"mealType\":\"VEG\"}]",
                "name", "mealType");
    }

    @Test
    void anUnknownFieldIsRefused() throws Exception {
        refused("?fields=nickname", "field-unknown");
    }

    @Test
    void anUnknownParameterIsRefused() throws Exception {
        refused("?colour=red", "parameter-unknown");
    }
}
