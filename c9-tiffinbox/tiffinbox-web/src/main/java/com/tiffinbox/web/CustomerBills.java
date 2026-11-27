package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import io.swagger.v3.oas.annotations.headers.Header;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * Course 9, unit 18: a customer's bill, as a file, on the public API - and TiffinBox's own signed, expiring link to it.
 *
 * <p>GET /api/v1/customers/{name}/bill streams the bill through TiffinBox: text/csv, a Content-Disposition that names the file
 * ("bill Ravi.csv"), and the rows written after the handler has returned (a StreamingResponseBody; Tomcat sends them chunked, with no
 * Content-Length). The rows are Course 6's bill, byte for byte: a header, one row a day of a thirty-day month, and the month's total -
 * Customer.monthlyBill(), whose thirty they share.
 *
 * <p>GET /api/v1/customers/{name}/bill-link mints a link to the same bill: {"href": "/api/v1/customers/{name}/bill/signed?expires=..&sig=.."}.
 * The link carries its own expiry (expires, a second of the epoch) and its own signature (sig: base64url of an HMAC-SHA256, under this
 * start's key, of the link's path, a newline and expires). GET /api/v1/customers/{name}/bill/signed checks a link before it streams:
 * the signature first, compared in one MessageDigest.isEqual call (a changed name, or a changed expires, is a changed signature), then
 * the expiry, then the customer - each refusal a problem of its own type (link-signature-invalid, link-expired, both four oh three;
 * customer-not-found, the four oh four TiffinBoxErrors answers for every route that reads a customer).
 *
 * <p>The lifetime is the server's: the setting tiffinbox.bill-link-lifetime (application.yaml, its reason beside it). A client does not
 * choose it - a lifetime the mint is sent (ttlSeconds, or any other parameter) is refused as an unknown parameter. The key is the setting
 * tiffinbox.bill-link-key, or, unset, 32 random bytes made at each start, so a link from before a restart is refused; the key is never
 * logged.
 *
 * <p>What it does NOT do: no identity - the mint answers any caller for any customer, and who may mint a link, and whose bill, is Course
 * 10's, The Threat Model First; no revocation of a link before its expiry; no store - this is the pattern a presigned URL follows, and a
 * store is named, never called, here; no list of bills; no Idempotency-Key handling (no write route).
 *
 * <p>final, as BillingRuns is: no proxy is made of it.
 */
@RestController
final class CustomerBills {

    private static final System.Logger LOG = System.getLogger("tiffinbox");
    private static final String TYPE = "tag:tiffinbox.example,2026:";
    private static final MediaType CSV = new MediaType("text", "csv", StandardCharsets.UTF_8);

    /** The days of a bill: Customer.monthlyBill()'s thirty. */
    static final int DAYS = 30;

    /** The query parameters the signed download reads; the bill and the mint read none. */
    static final Set<String> SIGNED_PARAMETERS = Set.of("expires", "sig");

    /** What the mint answers: the link, a path on this server. */
    @Schema(name = "BillLink")
    record BillLink(String href) {
    }

    private final CustomerRepository customers;
    private final Duration lifetime;
    private final byte[] key;

    CustomerBills(CustomerRepository customers, @Value("${tiffinbox.bill-link-lifetime}") Duration lifetime,
                  @Value("${tiffinbox.bill-link-key:}") String linkKey) {
        this.customers = customers;
        this.lifetime = lifetime;
        if (linkKey == null || linkKey.isBlank()) {
            this.key = new byte[32];
            new SecureRandom().nextBytes(this.key);
            LOG.log(System.Logger.Level.INFO, "the bill link's key: defaulted (random, this start only; tiffinbox.bill-link-key unset)");
        } else {
            this.key = linkKey.getBytes(StandardCharsets.UTF_8);
            LOG.log(System.Logger.Level.INFO, "the bill link's key: set (tiffinbox.bill-link-key)");
        }
        LOG.log(System.Logger.Level.INFO, "the bill link's lifetime: " + lifetime + " (tiffinbox.bill-link-lifetime)");
    }

    @ApiResponse(responseCode = "200", description = "OK - the bill, as a CSV file, streamed",
            headers = @Header(name = "Content-Disposition", description = "attachment, and the file's name",
                    schema = @Schema(type = "string")),
            content = @Content(mediaType = "text/csv", schema = @Schema(type = "string")))
    @ApiResponse(responseCode = "400", description = "A query parameter (this route reads none)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "404", description = "No customer has this name",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/customers/{name}/bill")
    ResponseEntity<StreamingResponseBody> bill(@PathVariable String name, HttpServletRequest request) throws SQLException {
        refuseParameters(request, Set.of());
        return csv(customer(name));
    }

    @ApiResponse(responseCode = "200", description = "OK - a link to the bill that carries its own expiry and signature",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = BillLink.class)))
    @ApiResponse(responseCode = "400", description = "A query parameter (this route reads none: the lifetime is the server's)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "404", description = "No customer has this name",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/customers/{name}/bill-link")
    BillLink billLink(@PathVariable String name, HttpServletRequest request) throws SQLException {
        refuseParameters(request, Set.of());
        Customer c = customer(name);
        long expires = Instant.now().plus(lifetime).getEpochSecond();
        String path = signedPath(c.name());
        return new BillLink(path + "?expires=" + expires + "&sig=" + sign(path, expires));
    }

    @ApiResponse(responseCode = "200", description = "OK - the bill, as a CSV file, streamed",
            headers = @Header(name = "Content-Disposition", description = "attachment, and the file's name",
                    schema = @Schema(type = "string")),
            content = @Content(mediaType = "text/csv", schema = @Schema(type = "string")))
    @ApiResponse(responseCode = "400", description = "A parameter missing, malformed or unknown (this route reads expires and sig)",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "403", description = "The signature does not match the link, or the link has expired",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @ApiResponse(responseCode = "404", description = "No customer has this name",
            content = @Content(mediaType = "application/problem+json", schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/customers/{name}/bill/signed")
    ResponseEntity<StreamingResponseBody> signedBill(@PathVariable String name, @RequestParam(required = false) String expires,
                                                     @RequestParam(required = false) String sig, HttpServletRequest request) throws SQLException {
        refuseParameters(request, SIGNED_PARAMETERS);
        if (expires == null || sig == null || !expires.matches("[0-9]{1,18}")) {
            throw refusal(HttpStatus.BAD_REQUEST, "link-malformed", "Malformed link", "a link carries expires (a whole number) and sig");
        }
        long at = Long.parseLong(expires);
        String expected = sign(signedPath(name), at);
        if (!MessageDigest.isEqual(expected.getBytes(StandardCharsets.US_ASCII), sig.getBytes(StandardCharsets.US_ASCII))) {
            throw refusal(HttpStatus.FORBIDDEN, "link-signature-invalid", "Link signature invalid", "the signature does not match this link");
        }
        if (Instant.now().getEpochSecond() > at) {
            throw refusal(HttpStatus.FORBIDDEN, "link-expired", "Link expired", "the link has expired");
        }
        return csv(customer(name));
    }

    /** The bill as a streamed CSV file: both downloads answer through it. */
    private static ResponseEntity<StreamingResponseBody> csv(Customer c) {
        String[] rows = rows(c);
        StreamingResponseBody body = out -> {
            for (String r : rows) {
                out.write((r + "\n").getBytes(StandardCharsets.UTF_8));
            }
        };
        return ResponseEntity.ok().contentType(CSV)
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename("bill " + c.name() + ".csv", StandardCharsets.UTF_8).build().toString())
                .body(body);
    }

    /** Course 6's bill: a header, one row a day, then the month's total - Customer's own monthlyBill(). */
    static String[] rows(Customer c) {
        String[] r = new String[DAYS + 2];
        r[0] = "day,customer,meals,price per meal,amount";
        for (int d = 1; d <= DAYS; d++) {
            r[d] = d + "," + c.name() + "," + c.mealsPerDay() + "," + c.pricePerMeal() + "," + c.mealsPerDay() * c.pricePerMeal();
        }
        r[DAYS + 1] = "month," + c.name() + "," + c.mealsPerDay() * DAYS + "," + c.pricePerMeal() + "," + c.monthlyBill();
        return r;
    }

    private Customer customer(String name) throws SQLException {
        return customers.findByName(name).orElseThrow(() -> new CustomerNotFound(name));
    }

    private static String signedPath(String name) {
        return "/api/v1/customers/" + name + "/bill/signed";
    }

    /** base64url (no padding) of HMAC-SHA256 under this start's key, over the path, a newline and expires. */
    private String sign(String path, long expires) {
        try {
            Mac m = Mac.getInstance("HmacSHA256");
            m.init(new SecretKeySpec(key, "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(m.doFinal((path + "\n" + expires).getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static void refuseParameters(HttpServletRequest request, Set<String> reads) {
        List<String> unknown = new ArrayList<>();
        for (String n : Collections.list(request.getParameterNames())) if (!reads.contains(n)) unknown.add(n);
        if (!unknown.isEmpty()) {
            throw refusal(HttpStatus.BAD_REQUEST, "parameter-unknown", "Unknown parameter", "unknown parameter " + unknown
                    + (reads.isEmpty() ? "; this route reads none" : "; this route reads " + new java.util.TreeSet<>(reads)));
        }
    }

    private static ErrorResponseException refusal(HttpStatus status, String type, String title, String detail) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(status, detail);
        p.setType(URI.create(TYPE + type));
        p.setTitle(title);
        return new ErrorResponseException(status, p, null);
    }
}
