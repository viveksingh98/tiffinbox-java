package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;

/**
 * Course 9, unit 19: the rate limit ({@link RateLimitFilter}, registered by {@link RateLimiting}) checked through MockMvc over the
 * whole application on H2 in memory - the shape of {@link ApiVersionTest}, with the filter added to MockMvc at the URL patterns its
 * registration names: the DispatcherServlet answers, with no socket and no HTTP client. This class's own capacity is a test setting,
 * 3, so the refusal comes on the fourth request; each test sends from an address of its own (MockMvc's remote address), so the
 * tests share no bucket.
 *
 * <p>Three tests: the request after the capacity is refused (429, the problem's members, Retry-After a whole number of seconds no
 * larger than the period, no charset but UTF-8); a forged X-Api-Key and a forged X-Forwarded-For are counted under the address (429
 * still: the filter reads no header); and a route outside {@code /api/v1/*} is never refused.
 *
 * <p>What it does NOT catch: the refill (a wait - unit 19's receipts, {@code refill}), the buckets in Redis under "dev" and two JVMs
 * on one bucket ({@code twojvm}), and the default capacity against the whole suite ({@code defaults}).
 */
@SpringBootTest(classes = TiffinBoxApp.class,
        properties = {"tiffinbox.shutdown-token=not-the-real-token", "tiffinbox.rate-limit.capacity=3"})
class RateLimitFilterTest {

    @Autowired WebApplicationContext ctx;
    @Autowired FilterRegistrationBean<RateLimitFilter> rateLimitFilter;

    private MockMvc mvc() {
        return MockMvcBuilders.webAppContextSetup(ctx)
                .addFilter(rateLimitFilter.getFilter(), rateLimitFilter.getUrlPatterns().toArray(String[]::new)).build();
    }

    private static MockHttpServletRequestBuilder from(String address, String uri) {
        return get(uri).with(r -> { r.setRemoteAddr(address); return r; });
    }

    private static void spend(MockMvc mvc, String address) throws Exception {
        for (int i = 1; i <= 3; i++) {
            assertThat(mvc.perform(from(address, "/api/v1/customers/Ravi")).andReturn().getResponse().getStatus()).isEqualTo(200);
        }
    }

    @Test
    void theRequestAfterTheCapacityIsRefused() throws Exception {
        MockMvc mvc = mvc();
        assertThat(rateLimitFilter.getUrlPatterns()).containsExactly("/api/v1/*");
        spend(mvc, "192.0.2.1");
        MockHttpServletResponse a = mvc.perform(from("192.0.2.1", "/api/v1/customers/Ravi")).andReturn().getResponse();
        System.out.println("RateLimitFilterTest: the fourth GET /api/v1/customers/Ravi -> " + a.getStatus() + " " + a.getContentType());
        assertThat(a.getStatus()).isEqualTo(429);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        assertThat(a.getHeader("Content-Type")).doesNotContain("charset");
        long retryAfter = Long.parseLong(a.getHeader("Retry-After"));
        assertThat(retryAfter).isBetween(1L, 60L);
        byte[] bytes = a.getContentAsByteArray();
        assertThat(a.getContentLength()).isEqualTo(bytes.length);
        JsonNode body = JsonMapper.builder().build().readTree(new String(bytes, StandardCharsets.UTF_8));
        assertThat(body.propertyNames()).containsExactly("type", "title", "status", "detail", "instance");
        assertThat(body.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:rate-limited");
        assertThat(body.get("status").asInt()).isEqualTo(429);
        assertThat(body.get("instance").asString()).isEqualTo("/api/v1/customers/Ravi");
    }

    @Test
    void forgedHeadersAreCountedUnderTheAddress() throws Exception {
        MockMvc mvc = mvc();
        spend(mvc, "192.0.2.2");
        MockHttpServletResponse key = mvc.perform(from("192.0.2.2", "/api/v1/customers/Ravi").header("X-Api-Key", "forged-1"))
                .andReturn().getResponse();
        MockHttpServletResponse xff = mvc.perform(from("192.0.2.2", "/api/v1/customers/Ravi").header("X-Forwarded-For", "10.0.0.1"))
                .andReturn().getResponse();
        System.out.println("RateLimitFilterTest: a forged X-Api-Key -> " + key.getStatus() + " · a forged X-Forwarded-For -> " + xff.getStatus());
        assertThat(key.getStatus()).isEqualTo(429);
        assertThat(xff.getStatus()).isEqualTo(429);
        assertThat(key.getHeader("Retry-After")).isNotNull();
    }

    @Test
    void aRouteOutsideTheApiIsNeverRefused() throws Exception {
        MockMvc mvc = mvc();
        spend(mvc, "192.0.2.3");
        assertThat(mvc.perform(from("192.0.2.3", "/api/v1/customers/Ravi")).andReturn().getResponse().getStatus()).isEqualTo(429);
        MockHttpServletResponse old = mvc.perform(from("192.0.2.3", "/customers/Ravi")).andReturn().getResponse();
        System.out.println("RateLimitFilterTest: GET /customers/Ravi after the address's refusal -> " + old.getStatus());
        assertThat(old.getStatus()).isEqualTo(HttpStatus.GONE.value());   // Course 9, unit 24: retired, and still never refused (not 429)
    }
}
