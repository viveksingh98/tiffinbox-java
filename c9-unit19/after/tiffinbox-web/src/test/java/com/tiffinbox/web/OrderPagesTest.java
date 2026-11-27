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
import java.util.ArrayList;
import java.util.List;

/**
 * Course 9, unit 13: the order list ({@link OrderPages}, GET /api/v1/orders) checked through MockMvc over the whole application on H2
 * in memory - the shape of {@link ApiVersionTest}: the DispatcherServlet answers, with no socket and no HTTP client. V6's twenty
 * orders are the rows; nothing here writes one.
 *
 * <p>Five requests, each its own test, so a failure names the line that broke: page one newest first (the ids, the tie broken by the
 * id ascending, a next cursor); page two through that cursor; a cursor with one character of its payload changed (refused,
 * cursor-invalid); an unknown sort (refused, sort-unknown); an unknown parameter (refused, parameter-unknown). The ids come from unit
 * 13's first and next captures, measured on the route before this test was written.
 *
 * <p>What it does NOT catch: PostgreSQL (unit 13's receipts send the same requests to a second database, and verify runs the Flyway
 * ITs there); rows that arrive between two pages (the receipts' walk, on the harness's insert); a restart.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class OrderPagesTest {

    @Autowired WebApplicationContext ctx;

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private MockHttpServletResponse ask(String query) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MockHttpServletResponse a = mvc.perform(get("/api/v1/orders" + query)).andReturn().getResponse();
        System.out.println("OrderPagesTest: GET /api/v1/orders" + (query.length() > 60 ? query.substring(0, 60) + "..." : query) + " -> " + a.getStatus());
        return a;
    }

    private static JsonNode body(MockHttpServletResponse a) throws Exception {
        return JSON.readTree(a.getContentAsString(StandardCharsets.UTF_8));
    }

    private static List<Long> ids(JsonNode page) {
        List<Long> ids = new ArrayList<>();
        for (JsonNode o : page.get("items")) ids.add(o.get("id").asLong());
        return ids;
    }

    private void refused(String query, String type) throws Exception {
        MockHttpServletResponse a = ask(query);
        assertThat(a.getStatus()).isEqualTo(400);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        assertThat(body(a).get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:" + type);
    }

    @Test
    void theFirstPageIsNewestFirst() throws Exception {
        MockHttpServletResponse a = ask("?sort=newest&size=5");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("application/json");
        JsonNode page = body(a);
        assertThat(page.propertyNames()).containsExactly("items", "next");
        assertThat(ids(page)).containsExactly(19L, 20L, 17L, 18L, 15L);
        assertThat(page.get("next").isString()).isTrue();
    }

    @Test
    void theCursorReadsPageTwo() throws Exception {
        String next = body(ask("?sort=newest&size=5")).get("next").asString();
        MockHttpServletResponse a = ask("?sort=newest&size=5&cursor=" + next);
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(ids(body(a))).containsExactly(16L, 13L, 14L, 11L, 12L);
    }

    @Test
    void aTamperedCursorIsRefused() throws Exception {
        String next = body(ask("?sort=newest&size=5")).get("next").asString();
        String tampered = next.substring(0, 5) + (next.charAt(5) == 'A' ? 'B' : 'A') + next.substring(6);
        refused("?sort=newest&size=5&cursor=" + tampered, "cursor-invalid");
    }

    @Test
    void anUnknownSortIsRefused() throws Exception {
        refused("?sort=nosuch", "sort-unknown");
    }

    @Test
    void anUnknownParameterIsRefused() throws Exception {
        refused("?colour=red", "parameter-unknown");
    }
}
