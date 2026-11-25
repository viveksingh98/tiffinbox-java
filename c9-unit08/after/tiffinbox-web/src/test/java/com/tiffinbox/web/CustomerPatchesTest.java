package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.UUID;

/**
 * Course 9, unit 05: the PATCH route's contract, pinned with the route (S9.11) - on the whole application, H2 in memory, over HTTP
 * (IdempotencyKeyTest's shape). Each test adds its own customer under a fresh name, so the seeded four and the other tests' rows are
 * never touched: what an absent member keeps, the 422 of a patched document that is not a valid customer, the 400 of a patch that
 * is not one, the 415 with Accept-Patch, the 409 of a failed test and of a taken name, the rename's eviction, and that PATCH is not
 * keyed.
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
class CustomerPatchesTest {

    @LocalServerPort int port;
    @Autowired JdbcTemplate jdbc;

    final HttpClient http = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();

    URI uri(String path) {
        return URI.create("http://127.0.0.1:" + port + path);
    }

    HttpResponse<String> send(String method, String path, String type, String body, String... headers) throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder(uri(path))
                .method(method, body == null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(body));
        if (type != null) b.header("Content-Type", type);
        for (int i = 0; i < headers.length; i += 2) b.header(headers[i], headers[i + 1]);
        return http.send(b.build(), HttpResponse.BodyHandlers.ofString());
    }

    HttpResponse<String> merge(String name, String body) throws Exception {
        return send("PATCH", "/api/v1/customers/" + name, "application/merge-patch+json", body);
    }

    HttpResponse<String> jsonPatch(String name, String body) throws Exception {
        return send("PATCH", "/api/v1/customers/" + name, "application/json-patch+json", body);
    }

    String fresh() throws Exception {
        String name = "p-" + UUID.randomUUID().toString().substring(0, 8);
        var r = send("POST", "/customers", "application/json",
                "{\"name\":\"" + name + "\",\"mealsPerDay\":1,\"pricePerMeal\":150,\"mealType\":\"NON_VEG\"}");
        assertThat(r.statusCode()).isEqualTo(201);
        return name;
    }

    String row(String name) {
        return jdbc.queryForObject("SELECT meals_per_day || ' ' || price_per_meal || ' ' || meal_type FROM customer WHERE name = ?",
                String.class, name);
    }

    @Test
    void aMergePatchKeepsWhatItDoesNotName() throws Exception {
        String n = fresh();
        var r = merge(n, "{\"mealsPerDay\":2}");
        assertThat(r.statusCode()).isEqualTo(200);
        assertThat(r.body()).contains("\"mealsPerDay\":2", "\"pricePerMeal\":150", "\"mealType\":\"NON_VEG\"");
        assertThat(row(n)).isEqualTo("2 150 NON_VEG");
    }

    @Test
    void aNullOnARequiredMemberIsUnprocessable() throws Exception {
        String n = fresh();
        var r = merge(n, "{\"mealType\":null}");
        assertThat(r.statusCode()).isEqualTo(422);
        assertThat(r.headers().firstValue("Content-Type")).hasValue("application/problem+json");
        assertThat(r.body()).contains("\"mealType\":\"must not be null\"").doesNotContain("jakarta.", "tools.jackson", "Exception");
        assertThat(merge(n, "{\"pricePerMeal\":null}").statusCode()).isEqualTo(422);
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aBrokenRuleIsUnprocessable() throws Exception {
        String n = fresh();
        assertThat(merge(n, "{\"mealsPerDay\":9}").statusCode()).isEqualTo(422);
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aMergePatchThatIsNotJsonIsABadRequest() throws Exception {
        String n = fresh();
        assertThat(merge(n, "{\"mealsPerDay\":").statusCode()).isEqualTo(400);
    }

    @Test
    void plainJsonIsUnsupportedAndNamesBothPatchTypes() throws Exception {
        String n = fresh();
        var r = send("PATCH", "/api/v1/customers/" + n, "application/json", "{\"mealsPerDay\":2}");
        assertThat(r.statusCode()).isEqualTo(415);
        assertThat(r.headers().firstValue("Accept-Patch").orElse(""))
                .contains("application/merge-patch+json", "application/json-patch+json");
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aJsonPatchReplaceChangesOneMember() throws Exception {
        String n = fresh();
        assertThat(jsonPatch(n, "[{\"op\":\"replace\",\"path\":\"/mealsPerDay\",\"value\":2}]").statusCode()).isEqualTo(200);
        assertThat(row(n)).isEqualTo("2 150 NON_VEG");
    }

    @Test
    void aFailedTestIsAConflictAndWritesNothing() throws Exception {
        String n = fresh();
        var r = jsonPatch(n, "[{\"op\":\"test\",\"path\":\"/mealsPerDay\",\"value\":9},{\"op\":\"replace\",\"path\":\"/mealsPerDay\",\"value\":2}]");
        assertThat(r.statusCode()).isEqualTo(409);
        assertThat(r.body()).doesNotContain("jakarta.", "parsson", "Exception");
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aJsonPatchOfTheWrongShapeIsABadRequest() throws Exception {
        String n = fresh();
        assertThat(jsonPatch(n, "[{\"op\":\"frobnicate\",\"path\":\"/mealsPerDay\",\"value\":2}]").statusCode()).isEqualTo(400);
        assertThat(jsonPatch(n, "[{\"op\":\"replace\",\"path\":\"/mealsPerDay\"}]").statusCode()).isEqualTo(400);
        assertThat(jsonPatch(n, "[{\"op\":\"replace\",\"path\":\"/colour\",\"value\":2}]").statusCode()).isEqualTo(400);
        assertThat(jsonPatch(n, "{\"op\":\"replace\",\"path\":\"/mealsPerDay\",\"value\":2}").statusCode()).isEqualTo(400);
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aRenameLeavesNothingAtTheOldAddress() throws Exception {
        String n = fresh();
        String m = n + "-x";
        assertThat(send("GET", "/customers/" + n, null, null).statusCode()).isEqualTo(200);   // warm the "customer" entry
        assertThat(send("GET", "/customers", null, null).body()).contains(n);                // and the list
        assertThat(merge(n, "{\"name\":\"" + m + "\"}").statusCode()).isEqualTo(200);
        assertThat(send("GET", "/customers/" + n, null, null).statusCode()).isEqualTo(404);
        assertThat(send("GET", "/customers/" + m, null, null).statusCode()).isEqualTo(200);
        assertThat(send("GET", "/customers", null, null).body()).contains("\"" + m + "\"").doesNotContain("\"" + n + "\"");
    }

    @Test
    void aRenameToATakenNameIsAConflict() throws Exception {
        String n = fresh();
        String taken = fresh();
        assertThat(merge(n, "{\"name\":\"" + taken + "\"}").statusCode()).isEqualTo(409);
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM customer WHERE name = ?", Integer.class, taken)).isEqualTo(1);
        assertThat(row(n)).isEqualTo("1 150 NON_VEG");
    }

    @Test
    void aNameNobodyHasIsNotFound() throws Exception {
        assertThat(merge("nobody-" + UUID.randomUUID(), "{\"mealsPerDay\":2}").statusCode()).isEqualTo(404);
    }

    @Test
    void aPatchIsNotKeyed() throws Exception {
        String n = fresh();
        String key = "patch-" + UUID.randomUUID();
        var r = send("PATCH", "/api/v1/customers/" + n, "application/merge-patch+json", "{\"mealsPerDay\":3}",
                "Idempotency-Key", "\"" + key + "\"");
        assertThat(r.statusCode()).isEqualTo(200);
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key WHERE idem_key = ?", Integer.class, key)).isZero();
    }
}
