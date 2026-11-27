package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.accept.ApiVersionHolder;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.servlet.HandlerMapping;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;

/**
 * Course 9, unit 12: TiffinBox's versioning ({@link TiffinBoxApiVersioning}) checked through MockMvc over the whole application on H2
 * in memory - the shape of {@link OpenApiSpecTest}: the DispatcherServlet answers, with no socket and no HTTP client.
 *
 * <p>Two requests, each its own test, so a failure names the half that broke: the old address {@code /api/v1/customers/Ravi} answers
 * as before (two hundred, Ravi's four members key for key) AND the resolver read its second segment {@code v1} as the version
 * {@code 1.0.0} (the request attribute Spring MVC stores it under - null without the configurer, so removing the configurer fails this
 * test), and the unversioned old address {@code /customers/Ravi} answers the same body (a required version would refuse it: dropping
 * {@code setVersionRequired(false)} fails this test); and a version no route carries, {@code /api/v3/customers/Ravi}, is not found: the
 * five routes are literal strings, so no mapping matches that path, and the holder Spring MVC stores carries no version and no error
 * (measured by unit 12's {@code choose} capture: a four oh four from the static handler, not a four hundred that names the version).
 *
 * <p>What it does NOT catch: everything else - the other routes, the other spellings and carriers, the seven and the old surface.
 * Unit 12's receipts ({@code choose}, {@code moved}) send those over a real socket.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class ApiVersionTest {

    @Autowired WebApplicationContext ctx;

    @Test
    void theOldAddressAnswersAsBefore() throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MvcResult r = mvc.perform(get("/api/v1/customers/Ravi")).andReturn();
        MockHttpServletResponse a = r.getResponse();
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("application/json");
        JsonNode body = JsonMapper.builder().build().readTree(a.getContentAsString(StandardCharsets.UTF_8));
        assertThat(body.propertyNames()).containsExactly("name", "mealsPerDay", "pricePerMeal", "mealType");
        assertThat(body.get("name").asString()).isEqualTo("Ravi");
        assertThat(body.get("mealsPerDay").asInt()).isEqualTo(2);
        assertThat(body.get("pricePerMeal").asInt()).isEqualTo(120);
        assertThat(body.get("mealType").asString()).isEqualTo("VEG");
        ApiVersionHolder v = (ApiVersionHolder) r.getRequest().getAttribute(HandlerMapping.API_VERSION_ATTRIBUTE);
        System.out.println("ApiVersionTest: GET /api/v1/customers/Ravi -> " + a.getStatus() + " · the resolved version "
                + (v == null ? "none" : v.getVersionIfPresent() + " (error " + (v.hasError() ? v.getError().getMessage() : "none") + ")"));
        assertThat(v).isNotNull();
        assertThat(v.hasError()).isFalse();
        assertThat(String.valueOf(v.getVersionIfPresent())).isEqualTo("1.0.0");
        MockHttpServletResponse old = mvc.perform(get("/customers/Ravi")).andReturn().getResponse();
        System.out.println("ApiVersionTest: GET /customers/Ravi -> " + old.getStatus() + " (the unversioned old route)");
        assertThat(old.getStatus()).isEqualTo(200);
        assertThat(JsonMapper.builder().build().readTree(old.getContentAsString(StandardCharsets.UTF_8))).isEqualTo(body);
    }

    @Test
    void aVersionNoRouteCarriesIsNotFound() throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MvcResult r = mvc.perform(get("/api/v3/customers/Ravi")).andReturn();
        MockHttpServletResponse a = r.getResponse();
        JsonNode body = JsonMapper.builder().build().readTree(a.getContentAsString(StandardCharsets.UTF_8));
        ApiVersionHolder v = (ApiVersionHolder) r.getRequest().getAttribute(HandlerMapping.API_VERSION_ATTRIBUTE);
        System.out.println("ApiVersionTest: GET /api/v3/customers/Ravi -> " + a.getStatus() + " · " + body.get("detail").asString()
                + " · the resolved version " + (v == null ? "none" : v.getVersionIfPresent() + " (error "
                + (v.hasError() ? v.getError().getClass().getSimpleName() + ": " + v.getError().getMessage() : "none") + ")"));
        assertThat(a.getStatus()).isEqualTo(404);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        assertThat(body.get("detail").asString()).isEqualTo("No static resource api/v3/customers/Ravi.");
        assertThat(v).isNotNull();
        assertThat(v.hasVersion()).isFalse();
        assertThat(v.hasError()).isFalse();
    }
}
