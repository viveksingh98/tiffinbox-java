package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.head;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;

/**
 * Course 9, unit 24: the retired route's contract (S9.11: the test that pins a route's answer joins the anchor with it) - the whole
 * application on H2 in memory, asked through MockMvc (no socket, no Docker). GET /customers/{name} answers 410 Gone, a problem detail
 * of type TiffinBoxErrors.ROUTE_RETIRED, and a Link naming the successor for the name asked, the name encoded as one path segment;
 * the answer carries no other header but its Content-Type (so no date of the timeline's first step); HEAD answers the same status;
 * the successor still answers. Every header name and status comes from Spring's constants, never a literal.
 *
 * <p>What it does NOT catch: who still calls the old address (the counter on a running server counts that, and only what reached
 * it); how Tomcat frames the header on a socket (the receipts read it with curl); a name that is not one path segment.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class RetiredRouteTest {

    private static final String SUCCESSOR = "successor-version";

    @Autowired WebApplicationContext ctx;

    private MockHttpServletResponse ask(String name) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        return mvc.perform(get("/customers/{name}", name)).andReturn().getResponse();
    }

    @Test
    void theOldAddressAnswersGoneWithItsType() throws Exception {
        MockHttpServletResponse r = ask("Ravi");
        System.out.println("RetiredRouteTest: GET /customers/Ravi -> " + r.getStatus() + " " + r.getContentType());
        assertThat(r.getStatus()).isEqualTo(HttpStatus.GONE.value());
        assertThat(MediaType.parseMediaType(r.getContentType()).isCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON)).isTrue();
        JsonNode body = JsonMapper.builder().build().readTree(r.getContentAsString(StandardCharsets.UTF_8));
        assertThat(body.get("type").asString()).isEqualTo(TiffinBoxErrors.ROUTE_RETIRED.toString());
        assertThat(body.get("status").asInt()).isEqualTo(HttpStatus.GONE.value());
    }

    @Test
    void itsLinkNamesTheSuccessorForTheNameAsked() throws Exception {
        assertThat(ask("Ravi").getHeader(HttpHeaders.LINK)).isEqualTo("</api/v1/customers/Ravi>; rel=\"" + SUCCESSOR + "\"");
        assertThat(ask("Meera Joshi").getHeader(HttpHeaders.LINK)).isEqualTo("</api/v1/customers/Meera%20Joshi>; rel=\"" + SUCCESSOR + "\"");
    }

    @Test
    void itCarriesNoOtherHeader() throws Exception {
        assertThat(ask("Nobody").getHeaderNames()).containsOnly(HttpHeaders.LINK, HttpHeaders.CONTENT_TYPE);
    }

    @Test
    void headAnswersTheSameStatus() throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        assertThat(mvc.perform(head("/customers/{name}", "Ravi")).andReturn().getResponse().getStatus()).isEqualTo(HttpStatus.GONE.value());
    }

    @Test
    void theSuccessorStillAnswers() throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MockHttpServletResponse r = mvc.perform(get("/api/v1/customers/{name}", "Ravi")).andReturn().getResponse();
        assertThat(r.getStatus()).isEqualTo(HttpStatus.OK.value());
        assertThat(JsonMapper.builder().build().readTree(r.getContentAsString(StandardCharsets.UTF_8)).get("name").asString()).isEqualTo("Ravi");
    }
}
