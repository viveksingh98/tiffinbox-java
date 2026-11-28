package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * Course 9, unit 22: the public merge patch's strict read (CustomerPatches.readBack), pinned with the route (S9.11) - a MockMvc test over
 * the whole application on H2 in memory, no socket and no HTTP client (ConditionalGetTest's shape). Each test makes its own customer by
 * POST /customers under a name that sorts after the seed's four.
 *
 * <p>Three tests: a merge patch naming a member the Customer record does not have ({@code admin}, then {@code version}) answers 422
 * "Invalid customer" with the member named in its detail, and the customer reads back unchanged; a merge patch of the record's own
 * members still answers 200; and Course 6's old POST /customers keeps its answer to a misspelt member ({@code mealTyp}): 400, the
 * missing {@code mealType} named by its rule - the shared mapper still ignores unknown members, so this test is green before the change
 * too.
 *
 * <p>What it does NOT catch: the harness's entity-bound route and its overwrite (no shipped route reads a body onto an entity - the
 * receipts' {@code bind}), PostgreSQL ({@code bind}, {@code strict}), and a member the record has but a client should not send.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class InputHardeningTest {

    private static final String MERGE = "application/merge-patch+json";
    private static final String JSON = "application/json";
    private static final int CREATED = 201;
    private static final int OK = 200;
    private static final int BAD_REQUEST = 400;
    private static final int UNPROCESSABLE = 422;

    @Autowired WebApplicationContext ctx;
    @Autowired JsonMapper json;

    private MockMvc mvc() {
        return MockMvcBuilders.webAppContextSetup(ctx).build();
    }

    private static String customer(MockMvc mvc, String name) throws Exception {
        MockHttpServletResponse r = mvc.perform(post("/customers").contentType(JSON)
                .content("{\"name\":\"" + name + "\",\"mealsPerDay\":2,\"pricePerMeal\":100,\"mealType\":\"VEG\"}")).andReturn().getResponse();
        assertThat(r.getStatus()).isEqualTo(CREATED);
        return "/api/v1/customers/" + name;
    }

    private static MockHttpServletResponse merge(MockMvc mvc, String uri, String body) throws Exception {
        return mvc.perform(patch(uri).contentType(MERGE).content(body)).andReturn().getResponse();
    }

    @Test
    void aMergePatchNamingAMemberTheRecordLacksIs422() throws Exception {
        MockMvc mvc = mvc();
        String uri = customer(mvc, "Zz-strict-a");
        MockHttpServletResponse admin = merge(mvc, uri, "{\"admin\":true}");
        MockHttpServletResponse version = merge(mvc, uri, "{\"version\":99}");
        JsonNode a = json.readTree(admin.getContentAsString());
        JsonNode v = json.readTree(version.getContentAsString());
        System.out.println("InputHardeningTest: PATCH " + uri + " {admin:true} -> " + admin.getStatus() + " " + a.path("detail").asString()
                + " · {version:99} -> " + version.getStatus() + " " + v.path("detail").asString());
        assertThat(admin.getStatus()).isEqualTo(UNPROCESSABLE);
        assertThat(a.path("title").asString()).isEqualTo("Invalid customer");
        assertThat(a.path("detail").asString()).isEqualTo("the patched customer cannot be read at admin");
        assertThat(version.getStatus()).isEqualTo(UNPROCESSABLE);
        assertThat(v.path("detail").asString()).isEqualTo("the patched customer cannot be read at version");
        JsonNode back = json.readTree(mvc.perform(get(uri)).andReturn().getResponse().getContentAsString());
        assertThat(back.path("mealsPerDay").asInt()).isEqualTo(2);
    }

    @Test
    void aMergePatchOfTheRecordsOwnMembersStillWrites() throws Exception {
        MockMvc mvc = mvc();
        String uri = customer(mvc, "Zz-strict-b");
        MockHttpServletResponse r = merge(mvc, uri, "{\"mealsPerDay\":3}");
        assertThat(r.getStatus()).isEqualTo(OK);
        assertThat(json.readTree(r.getContentAsString()).path("mealsPerDay").asInt()).isEqualTo(3);
    }

    @Test
    void theOldPostStillNamesTheMissingMemberOfAMisspeltOne() throws Exception {
        MockMvc mvc = mvc();
        MockHttpServletResponse r = mvc.perform(post("/customers").contentType(JSON)
                .content("{\"name\":\"Zz-strict-c\",\"mealsPerDay\":1,\"pricePerMeal\":110,\"mealTyp\":\"VEG\"}")).andReturn().getResponse();
        JsonNode p = json.readTree(r.getContentAsString());
        System.out.println("InputHardeningTest: POST /customers {mealTyp} -> " + r.getStatus() + " " + p.path("errors"));
        assertThat(r.getStatus()).isEqualTo(BAD_REQUEST);
        assertThat(p.path("errors").path("mealType").asString()).isEqualTo("must not be null");
    }
}
