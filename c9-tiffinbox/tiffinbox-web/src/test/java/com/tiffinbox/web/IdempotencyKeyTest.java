package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.jdbc.core.JdbcTemplate;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.UUID;
import java.util.Map;
import tools.jackson.databind.json.JsonMapper;

/**
 * Course 9, unit 04: the Idempotency-Key on the pause route, pinned over a socket - the whole application on H2 in memory, a real
 * Tomcat, java.net.http as the client. The pause route takes no body and no Content-Type, and the filter reads the key before any
 * converter runs: a MockMvc request cannot say what the socket carries, so this test sends real requests. The store's claims are
 * set up by writing the key row directly (a second client, JdbcTemplate on TiffinBox's own DataSource): an in-flight claim is a
 * status 0 row, an abandoned one a status 0 row with an old claimed_at - no hold, no clock in the test.
 *
 * <p>A WebMvcTest slice cannot carry the filter: it needs the DataSource and the transaction manager, which a web slice leaves out.
 * The order test reads the registration's order off this context. The shutdown token is a literal written here, not a secret
 * (TiffinBoxWebTest says why).
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
class IdempotencyKeyTest {

    /** Boot's documented default for Spring Security's filter chain (SecurityFilterProperties.DEFAULT_FILTER_ORDER): not on this class path. */
    static final int SECURITY_FILTER_ORDER = -100;

    @LocalServerPort int port;
    @Autowired JdbcTemplate jdbc;
    @Autowired @Qualifier("idempotencyKeyFilter") FilterRegistrationBean<?> registration;

    final HttpClient http = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();

    HttpResponse<String> pause(String name, int days, String keyHeader) throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + "/api/v1/customers/" + name + "/pauses?days=" + days))
                .POST(HttpRequest.BodyPublishers.noBody());
        if (keyHeader != null) b.header("Idempotency-Key", keyHeader);
        return http.send(b.build(), HttpResponse.BodyHandlers.ofString());
    }

    int pauses() {
        return jdbc.queryForObject("SELECT COUNT(*) FROM pause", Integer.class);
    }

    static String fresh() {
        return "t-" + UUID.randomUUID();
    }

    /** No key on the pause route: 400, typed, and nothing written. */
    @Test
    void theKeyIsRequiredOnThePauseRoute() throws Exception {
        int before = pauses();
        var r = pause("Sunil", 2, null);
        assertThat(r.statusCode()).isEqualTo(400);
        assertThat(r.headers().firstValue("Content-Type")).hasValue("application/problem+json");
        assertThat(r.body()).contains("\"type\":\"tag:tiffinbox.example,2026:idempotency-key-missing\"");
        assertThat(pauses()).isEqualTo(before);
    }

    /** One key, the same request twice: one pause, and the second answer is the first, byte for byte. */
    @Test
    void theSameKeyTwiceIsOnePauseAndTheSameAnswer() throws Exception {
        String key = fresh();
        int before = pauses();
        var first = pause("Sunil", 2, "\"" + key + "\"");
        var again = pause("Sunil", 2, "\"" + key + "\"");
        assertThat(first.statusCode()).isEqualTo(201);
        assertThat(first.headers().firstValue("Location")).isPresent();
        assertThat(again.statusCode()).isEqualTo(201);
        assertThat(again.headers().firstValue("Location")).isEqualTo(first.headers().firstValue("Location"));
        assertThat(again.body()).isEqualTo(first.body());
        assertThat(pauses()).isEqualTo(before + 1);
        assertThat(jdbc.queryForObject("SELECT status FROM idempotency_key WHERE idem_key = ?", Integer.class, key)).isEqualTo(201);
    }

    /** The same key with another request (another query): 422, and nothing written. */
    @Test
    void theKeyWithAnotherRequestIsRefused() throws Exception {
        String key = fresh();
        assertThat(pause("Sunil", 2, "\"" + key + "\"").statusCode()).isEqualTo(201);
        int before = pauses();
        var other = pause("Sunil", 3, "\"" + key + "\"");
        assertThat(other.statusCode()).isEqualTo(422);
        assertThat(other.body()).contains("\"type\":\"tag:tiffinbox.example,2026:idempotency-key-reused\"");
        assertThat(pauses()).isEqualTo(before);
    }

    /** A key that is not one String of TiffinBox's format: 400, typed malformed. */
    @Test
    void aTokenIsNotAString() throws Exception {
        var r = pause("Sunil", 2, "k1");
        assertThat(r.statusCode()).isEqualTo(400);
        assertThat(r.body()).contains("\"type\":\"tag:tiffinbox.example,2026:idempotency-key-malformed\"");
    }

    /** A claim still in flight (a status 0 row, claimed now): 409, typed, and the route does not run. */
    @Test
    void aClaimInFlightIsAConflict() throws Exception {
        String key = fresh();
        assertThat(pause("Sunil", 2, "\"" + key + "\"").statusCode()).isEqualTo(201);
        String hash = jdbc.queryForObject("SELECT request_hash FROM idempotency_key WHERE idem_key = ?", String.class, key);
        String inflight = fresh();
        // the fingerprint is the request's (method, URI, query, body), not the key's: the same request under another key has it too
        jdbc.update("INSERT INTO idempotency_key (idem_key, request_hash, status, claim_token, claimed_at) VALUES (?, ?, 0, ?, CURRENT_TIMESTAMP)",
                inflight, hash, UUID.randomUUID().toString());
        int before = pauses();
        var r = pause("Sunil", 2, "\"" + inflight + "\"");
        assertThat(r.statusCode()).isEqualTo(409);
        assertThat(r.body()).contains("\"type\":\"tag:tiffinbox.example,2026:idempotency-key-outstanding\"");
        assertThat(pauses()).isEqualTo(before);
    }

    /** An abandoned claim (a status 0 row older than the reclaim age): the retry takes it over and runs - one pause, stored. */
    @Test
    void anAbandonedClaimIsReclaimed() throws Exception {
        String probe = fresh();
        assertThat(pause("Sunil", 2, "\"" + probe + "\"").statusCode()).isEqualTo(201);
        String hash = jdbc.queryForObject("SELECT request_hash FROM idempotency_key WHERE idem_key = ?", String.class, probe);
        String key = fresh();
        jdbc.update("INSERT INTO idempotency_key (idem_key, request_hash, status, claim_token, claimed_at)"
                + " VALUES (?, ?, 0, ?, CURRENT_TIMESTAMP - INTERVAL '3600' SECOND)", key, hash, UUID.randomUUID().toString());
        int before = pauses();
        var r = pause("Sunil", 2, "\"" + key + "\"");
        assertThat(r.statusCode()).isEqualTo(201);
        assertThat(pauses()).isEqualTo(before + 1);
        assertThat(jdbc.queryForObject("SELECT status FROM idempotency_key WHERE idem_key = ?", Integer.class, key)).isEqualTo(201);
    }

    /** S9.34: the key filter runs after Spring Security's chain would - a stored answer is never replayed to a request it refuses. */
    @Test
    void theKeyFilterRunsAfterTheSecurityChain() {
        System.out.println("ORDER TEST the key filter's registration order " + registration.getOrder() + " · IdempotencyKeys.ORDER "
                + IdempotencyKeys.ORDER + " · the security chain's " + SECURITY_FILTER_ORDER + " (Boot's documented default)");
        assertThat(registration.getOrder()).isEqualTo(IdempotencyKeys.ORDER);
        assertThat(registration.getOrder()).isGreaterThan(SECURITY_FILTER_ORDER);
    }

    /** Course 9, unit 09: the not-found problem on the keyed pause POST carries its own type (TiffinBoxErrors.CUSTOMER_NOT_FOUND). */
    @Test
    void aNameNobodyHasIsTyped() throws Exception {
        var r = pause("Nobody", 1, "\"" + fresh() + "\"");
        assertThat(r.statusCode()).isEqualTo(404);
        Map<?, ?> problem = JsonMapper.builder().build().readValue(r.body(), Map.class);
        assertThat(problem.get("type")).isEqualTo("tag:tiffinbox.example,2026:customer-not-found");
        assertThat(problem.get("name")).isEqualTo("Nobody");
    }
}
