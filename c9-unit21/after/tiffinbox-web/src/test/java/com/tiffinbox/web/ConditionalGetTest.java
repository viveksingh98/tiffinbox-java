package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Course 9, unit 20: the validators and the precondition ({@link ConditionalGets}' shallow filter, CustomerReads' deep tag,
 * CustomerPatches' If-Match) checked through MockMvc over the whole application on H2 in memory - the shape of
 * {@link RateLimitFilterTest}: the filter added to MockMvc at the URL patterns its registration names, the DispatcherServlet
 * answering with no socket and no HTTP client. Each test makes its own customer by POST /customers, so the versions are its own; the names sort after the seed's four
 * (CustomerFieldsTest reads the list from its start).
 *
 * <p>Four tests: the deep tag is {@code "v0"} on a new customer and If-None-Match with it answers 304 with no body; on the merge
 * patch route a stale If-Match answers 412 and the customer reads back unchanged, the current tag 200 (the tag moves), a weak form of
 * the current tag 412, no If-Match 200; the same stale and current pair on the JSON Patch route; and the shallow filter's tag on the
 * list read, with its 304.
 *
 * <p>What it does NOT catch: the bill's chunking (MockMvc does not chunk - the receipts' {@code paths}), the SSE feed, Chrome
 * ({@code chrome}), PostgreSQL's UPDATE ({@code ifmatch}), the statements each answer costs, and the window between the check and
 * the write (named in CustomerPatches, not closed).
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class ConditionalGetTest {

    private static final String MERGE = "application/merge-patch+json";
    private static final String JSON_PATCH = "application/json-patch+json";

    @Autowired WebApplicationContext ctx;
    @Autowired FilterRegistrationBean<ConditionalGets.ApiEtags> apiEtagFilter;

    private MockMvc mvc() {
        return MockMvcBuilders.webAppContextSetup(ctx)
                .addFilter(apiEtagFilter.getFilter(), apiEtagFilter.getUrlPatterns().toArray(String[]::new)).build();
    }

    private static String customer(MockMvc mvc, String name) throws Exception {
        MockHttpServletResponse r = mvc.perform(post("/customers").contentType("application/json")
                .content("{\"name\":\"" + name + "\",\"mealsPerDay\":2,\"pricePerMeal\":100,\"mealType\":\"VEG\"}")).andReturn().getResponse();
        assertThat(r.getStatus()).isEqualTo(201);
        return "/api/v1/customers/" + name;
    }

    private static MockHttpServletResponse merge(MockMvc mvc, String uri, String ifMatch, int meals) throws Exception {
        var req = patch(uri).contentType(MERGE).content("{\"mealsPerDay\":" + meals + "}");
        return mvc.perform(ifMatch == null ? req : req.header("If-Match", ifMatch)).andReturn().getResponse();
    }

    @Test
    void theDeepTagAnswers304() throws Exception {
        MockMvc mvc = mvc();
        assertThat(apiEtagFilter.getUrlPatterns()).containsExactly("/api/v1/*");
        String uri = customer(mvc, "Zz-etag-a");
        MockHttpServletResponse a = mvc.perform(get(uri)).andReturn().getResponse();
        MockHttpServletResponse b = mvc.perform(get(uri).header("If-None-Match", "\"v0\"")).andReturn().getResponse();
        System.out.println("ConditionalGetTest: GET " + uri + " -> " + a.getStatus() + " ETag " + a.getHeader("ETag")
                + " · with If-None-Match \"v0\" -> " + b.getStatus() + " body " + b.getContentAsByteArray().length + " B");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getHeader("ETag")).isEqualTo("\"v0\"");
        assertThat(b.getStatus()).isEqualTo(304);
        assertThat(b.getContentAsByteArray()).isEmpty();
    }

    @Test
    void aStaleIfMatchOnTheMergePatchIs412() throws Exception {
        MockMvc mvc = mvc();
        String uri = customer(mvc, "Zz-etag-b");
        MockHttpServletResponse ok = merge(mvc, uri, "\"v0\"", 3);
        MockHttpServletResponse stale = merge(mvc, uri, "\"v0\"", 1);
        MockHttpServletResponse weak = merge(mvc, uri, "W/\"v1\"", 1);
        String after = mvc.perform(get(uri)).andReturn().getResponse().getContentAsString();
        MockHttpServletResponse none = merge(mvc, uri, null, 1);
        String tag = mvc.perform(get(uri)).andReturn().getResponse().getHeader("ETag");
        System.out.println("ConditionalGetTest: merge patch If-Match \"v0\" -> " + ok.getStatus() + " · again -> " + stale.getStatus()
                + " · W/\"v1\" -> " + weak.getStatus() + " · none -> " + none.getStatus() + " · the tag now " + tag);
        assertThat(ok.getStatus()).isEqualTo(200);
        assertThat(ok.getHeader("ETag")).isNull();
        assertThat(stale.getStatus()).isEqualTo(412);
        assertThat(stale.getContentType()).isEqualTo("application/problem+json");
        assertThat(weak.getStatus()).isEqualTo(412);
        assertThat(after).contains("\"mealsPerDay\":3");
        assertThat(none.getStatus()).isEqualTo(200);
        assertThat(tag).isEqualTo("\"v2\"");
    }

    @Test
    void aStaleIfMatchOnTheJsonPatchIs412() throws Exception {
        MockMvc mvc = mvc();
        String uri = customer(mvc, "Zz-etag-c");
        String op = "[{\"op\":\"replace\",\"path\":\"/mealsPerDay\",\"value\":%d}]";
        MockHttpServletResponse ok = mvc.perform(patch(uri).contentType(JSON_PATCH).content(op.formatted(3)).header("If-Match", "\"v0\""))
                .andReturn().getResponse();
        MockHttpServletResponse stale = mvc.perform(patch(uri).contentType(JSON_PATCH).content(op.formatted(1)).header("If-Match", "\"v0\""))
                .andReturn().getResponse();
        String after = mvc.perform(get(uri)).andReturn().getResponse().getContentAsString();
        System.out.println("ConditionalGetTest: JSON Patch If-Match \"v0\" -> " + ok.getStatus() + " · again -> " + stale.getStatus());
        assertThat(ok.getStatus()).isEqualTo(200);
        assertThat(stale.getStatus()).isEqualTo(412);
        assertThat(after).contains("\"mealsPerDay\":3");
    }

    @Test
    void theShallowTagOnTheListAnswers304() throws Exception {
        MockMvc mvc = mvc();
        MockHttpServletResponse a = mvc.perform(get("/api/v1/customers")).andReturn().getResponse();
        String tag = a.getHeader("ETag");
        MockHttpServletResponse b = mvc.perform(get("/api/v1/customers").header("If-None-Match", tag)).andReturn().getResponse();
        System.out.println("ConditionalGetTest: GET /api/v1/customers -> " + a.getStatus() + " ETag " + tag + " · with it -> " + b.getStatus());
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(tag).startsWith("\"0").endsWith("\"");
        assertThat(b.getStatus()).isEqualTo(304);
        assertThat(b.getContentAsByteArray()).isEmpty();
    }
}
