package com.tiffinbox.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.InvalidMediaTypeException;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.server.PathContainer;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionTimedOutException;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.filter.ServerHttpObservationFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;
import org.springframework.web.util.pattern.PathPattern;
import org.springframework.web.util.pattern.PathPatternParser;
import tools.jackson.databind.json.JsonMapper;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.Collections;
import java.util.HexFormat;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * Course 9, unit 04: the Idempotency-Key (draft-ietf-httpapi-idempotency-key-header-09) for TiffinBox's two keyed operations - a
 * TWO-PHASE store with a fenced claim.
 *
 * <p>Which requests: a fixed table of method and route. POST /api/v1/customers/{name}/pauses REQUIRES the key (400 without it);
 * POST /customers takes it when it carries one (inert without it), except the dashboard's form (application/x-www-form-urlencoded),
 * which the filter passes untouched - a browser's form never sends the header, and its 200 re-render must never be stored. Every
 * other request passes untouched.
 *
 * <p>The key: one RFC 9651 String, 1 to 255 characters from A-Z a-z 0-9 - . _ ~, no parameters; all its field lines are combined
 * first (RFC 9651 section 4.2), so two lines are one malformed value. Anything else is 400 - RFC 9651 lets a server treat a field it
 * cannot take as a malformed message. The fingerprint: SHA-256 over the method, the request URI and query exactly as sent, and the
 * body's bytes.
 *
 * <p>Phase 1, the claim: the key row (status 0, a random claim token, claimed_at from the database's clock) is inserted and committed
 * alone. A duplicate meets the committed row: another fingerprint is 422, a stored answer is replayed byte for byte (the route does
 * not run), and a claim still in flight is 409 - unless it is older than tiffinbox.idempotency.reclaim-after, when one conditional
 * UPDATE hands it a new token (the reclaim: the request that held it is gone).
 *
 * <p>Phase 2: the route runs inside one transaction with a time limit (tiffinbox.idempotency.phase2-timeout, which must be shorter
 * than the reclaim age); its writes and the stored answer commit together, and the answer's UPDATE is fenced by the claim's token -
 * a claim reclaimed meanwhile updates nothing, and phase 2 rolls back. An error answer, an exception or the time limit rolls phase 2
 * back and deletes the claim (fenced too), so a retry runs again; the client's answer then carries none of the route's headers.
 */
public final class IdempotencyKeyFilter extends OncePerRequestFilter {

    private static final System.Logger LOG = System.getLogger("tiffinbox.idempotency");

    static final String HEADER = "Idempotency-Key";
    static final URI MISSING = URI.create("tag:tiffinbox.example,2026:idempotency-key-missing");
    static final URI MALFORMED = URI.create("tag:tiffinbox.example,2026:idempotency-key-malformed");
    static final URI OUTSTANDING = URI.create("tag:tiffinbox.example,2026:idempotency-key-outstanding");
    static final URI REUSED = URI.create("tag:tiffinbox.example,2026:idempotency-key-reused");
    static final int MAX_BODY = 65_536;
    private static final Pattern KEY = Pattern.compile("[A-Za-z0-9._~-]{1,255}");
    private static final String FORMAT = "one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters";

    /** One keyed operation: its method, its route, whether the key is required, whether the form at the same URL is passed. */
    record Guarded(String method, PathPattern route, boolean required, boolean formPasses) {
    }

    private static final List<Guarded> GUARDED = List.of(
            new Guarded("POST", PathPatternParser.defaultInstance.parse("/customers"), false, true),
            new Guarded("POST", PathPatternParser.defaultInstance.parse("/api/v1/customers/{name}/pauses"), true, false));

    private enum Outcome { STORED, ROUTE_ERROR, FENCE_LOST, ASYNC }

    private record Row(String hash, int status, String location, String contentType, String body) {
    }

    /** An IOException or ServletException from the route, carried out of the transaction's callback. */
    private static final class RouteFailure extends RuntimeException {
        RouteFailure(Exception e) {
            super(e);
        }
    }

    private final JdbcTemplate jdbc;
    private final TransactionTemplate phase2;
    private final JsonMapper json;
    private final long reclaimSeconds;

    IdempotencyKeyFilter(DataSource dataSource, PlatformTransactionManager transactions, JsonMapper json, Duration phase2Limit,
                         Duration reclaimAfter) {
        int limit = (int) Math.max(1, (phase2Limit.toMillis() + 999) / 1000);
        if (reclaimAfter.toSeconds() <= limit) {
            throw new IllegalStateException("tiffinbox.idempotency.reclaim-after (" + reclaimAfter + ") must be longer than "
                    + "tiffinbox.idempotency.phase2-timeout (" + limit + "s): a live request must finish before its claim can be reclaimed");
        }
        this.jdbc = new JdbcTemplate(dataSource);
        this.jdbc.setQueryTimeout(limit);              // phase 1's own statements never wait longer than phase 2 may run
        this.phase2 = new TransactionTemplate(transactions);
        this.phase2.setTimeout(limit);
        this.phase2.setName("idempotency-key phase 2");
        this.json = json;
        this.reclaimSeconds = reclaimAfter.toSeconds();
        LOG.log(System.Logger.Level.INFO, "KEY filter: phase 2's time limit " + limit + "s, an abandoned claim reclaimed after "
                + reclaimSeconds + "s");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        Guarded op = guarded(req);
        if (op == null) {
            chain.doFilter(req, res);
            return;
        }
        List<String> lines = Collections.list(req.getHeaders(HEADER));
        if (lines.isEmpty()) {
            if (op.required()) {
                answer(req, res, op, HttpStatus.BAD_REQUEST, MISSING, "Idempotency-Key is missing",
                        "This operation requires an Idempotency-Key header: " + FORMAT + ".");
                return;
            }
            chain.doFilter(req, res);                   // inert without its header
            return;
        }
        String key = parse(lines);
        if (key == null) {
            log("malformed key (" + lines.size() + " field line(s)) -> 400");
            answer(req, res, op, HttpStatus.BAD_REQUEST, MALFORMED, "Idempotency-Key is malformed",
                    "The Idempotency-Key header must be " + FORMAT + ".");
            return;
        }
        if (req.getContentLengthLong() > MAX_BODY) {
            answer(req, res, op, HttpStatus.CONTENT_TOO_LARGE, null, null, "The request body is larger than " + MAX_BODY + " bytes.");
            return;
        }
        byte[] body = req.getInputStream().readNBytes(MAX_BODY + 1);
        if (body.length > MAX_BODY) {
            answer(req, res, op, HttpStatus.CONTENT_TOO_LARGE, null, null, "The request body is larger than " + MAX_BODY + " bytes.");
            return;
        }
        String hash = fingerprint(req, body);
        String token = UUID.randomUUID().toString();
        if (!claim(req, res, op, key, hash, token)) {
            return;                                     // answered: a replay, 409 or 422
        }
        ContentCachingResponseWrapper out = new ContentCachingResponseWrapper(res);
        Outcome outcome;
        try {
            outcome = phase2.execute(tx -> {
                try {
                    chain.doFilter(new CachedBody(req, body), out);
                } catch (IOException | ServletException e) {
                    throw new RouteFailure(e);
                }
                if (req.isAsyncStarted()) {
                    tx.setRollbackOnly();
                    return Outcome.ASYNC;
                }
                int status = out.getStatus();
                if (status >= 400) {
                    tx.setRollbackOnly();
                    return Outcome.ROUTE_ERROR;
                }
                int n = jdbc.update("UPDATE idempotency_key SET status = ?, location = ?, content_type = ?, body = ?, claim_token = NULL"
                                + " WHERE idem_key = ? AND claim_token = ? AND status = 0",
                        status, out.getHeader("Location"), out.getContentType(),
                        new String(out.getContentAsByteArray(), StandardCharsets.UTF_8), key, token);
                if (n != 1) {
                    tx.setRollbackOnly();
                    return Outcome.FENCE_LOST;
                }
                return Outcome.STORED;
            });
        } catch (RouteFailure f) {
            release(key, token, "an exception from the route");
            res.reset();
            Throwable c = f.getCause();
            if (c instanceof ServletException se) {
                throw se;
            }
            throw (IOException) c;
        } catch (TransactionTimedOutException | TransientDataAccessException e) {
            release(key, token, "phase 2's time limit (" + e.getClass().getSimpleName() + ")");
            res.reset();                                // none of the route's headers: its writes were rolled back
            answer(req, res, op, HttpStatus.SERVICE_UNAVAILABLE, null, null,
                    "The request was not performed: it ran past its time limit. Retry it with the same Idempotency-Key.");
            return;
        } catch (RuntimeException e) {
            release(key, token, "a " + e.getClass().getSimpleName());
            res.reset();
            LOG.log(System.Logger.Level.WARNING, "KEY phase 2 failed and was rolled back", e);
            answer(req, res, op, HttpStatus.INTERNAL_SERVER_ERROR, null, null,
                    "The request was not performed. Retry it with the same Idempotency-Key.");
            return;
        }
        switch (outcome) {
            case STORED -> {
                log("COMMIT: the route's writes and its " + out.getStatus() + " stored together");
                out.copyBodyToResponse();
            }
            case ROUTE_ERROR -> {
                log("ROLLBACK: the route answered " + out.getStatus() + " (an error is not stored)");
                release(key, token, "the route's error answer");
                out.copyBodyToResponse();
            }
            case FENCE_LOST -> {
                log("ROLLBACK: the claim was reclaimed by another request (the fence) - this request's writes are not committed");
                res.reset();
                answer(req, res, op, HttpStatus.CONFLICT, OUTSTANDING, "A request is outstanding for this Idempotency-Key",
                        "A request with this Idempotency-Key is still being processed. Retry it later with the same key.");
            }
            case ASYNC -> {
                LOG.log(System.Logger.Level.ERROR, "KEY a keyed route started async processing: its answer is not stored");
                release(key, token, "an asynchronous route");
            }
        }
    }

    /** Phase 1. True when this request owns the claim (new, or reclaimed); false when the answer is already written. */
    private boolean claim(HttpServletRequest req, HttpServletResponse res, Guarded op, String key, String hash, String token)
            throws IOException {
        try {
            jdbc.update("INSERT INTO idempotency_key (idem_key, request_hash, status, claim_token, claimed_at)"
                    + " VALUES (?, ?, 0, ?, CURRENT_TIMESTAMP)", key, hash, token);
            log("CLAIMED: the key row committed alone (status 0)");
            return true;
        } catch (DataIntegrityViolationException taken) {
            // the key is in the table: decided below
        } catch (TransientDataAccessException busy) {
            log("BUSY: the claim's INSERT could not finish (" + busy.getClass().getSimpleName() + ") -> 409");
            outstanding(req, res, op);
            return false;
        }
        try {
            List<Row> rows = jdbc.query("SELECT request_hash, status, location, content_type, body FROM idempotency_key WHERE idem_key = ?",
                    (rs, i) -> new Row(rs.getString(1), rs.getInt(2), rs.getString(3), rs.getString(4), rs.getString(5)), key);
            if (rows.isEmpty()) {
                log("FREED: the key's first request failed meanwhile -> 409 (a retry runs again)");
                outstanding(req, res, op);
                return false;
            }
            Row row = rows.get(0);
            if (!row.hash().equals(hash)) {
                log("REUSED: the key was first used with another request -> 422");
                answer(req, res, op, HttpStatus.UNPROCESSABLE_CONTENT, REUSED, "Idempotency-Key is already used",
                        "This Idempotency-Key was first used with a different request. Use a new key for a new request.");
                return false;
            }
            if (row.status() != 0) {
                log("REPLAY: the stored " + row.status() + " - the route does not run");
                observe(req, op);
                byte[] b = row.body() == null ? new byte[0] : row.body().getBytes(StandardCharsets.UTF_8);
                res.setStatus(row.status());
                if (row.location() != null) {
                    res.setHeader("Location", row.location());
                }
                if (row.contentType() != null) {
                    res.setContentType(row.contentType());
                }
                res.setContentLength(b.length);
                res.getOutputStream().write(b);
                return false;
            }
            int n = jdbc.update("UPDATE idempotency_key SET claim_token = ?, claimed_at = CURRENT_TIMESTAMP WHERE idem_key = ?"
                    + " AND request_hash = ? AND status = 0 AND claimed_at < CURRENT_TIMESTAMP - INTERVAL '" + reclaimSeconds + "' SECOND",
                    token, key, hash);
            if (n == 1) {
                log("RECLAIMED: the claim was older than " + reclaimSeconds + "s - this request owns it now (a new token)");
                return true;
            }
            log("IN-FLIGHT: the key's first request has not finished -> 409");
            outstanding(req, res, op);
            return false;
        } catch (TransientDataAccessException busy) {
            log("BUSY: the key's row is locked by its first request (" + busy.getClass().getSimpleName() + ") -> 409");
            outstanding(req, res, op);
            return false;
        }
    }

    private void outstanding(HttpServletRequest req, HttpServletResponse res, Guarded op) throws IOException {
        answer(req, res, op, HttpStatus.CONFLICT, OUTSTANDING, "A request is outstanding for this Idempotency-Key",
                "A request with this Idempotency-Key is still being processed. Retry it later with the same key.");
    }

    /** Frees this request's claim - fenced, so a claim another request reclaimed is never deleted; a failure is left to the reclaim. */
    private void release(String key, String token, String why) {
        try {
            int n = jdbc.update("DELETE FROM idempotency_key WHERE idem_key = ? AND claim_token = ? AND status = 0", key, token);
            log("RELEASED after " + why + ": " + n + " key row deleted (a retry with this key runs again)");
        } catch (RuntimeException e) {
            LOG.log(System.Logger.Level.WARNING, "KEY the claim could not be released after " + why + "; the reclaim frees it", e);
        }
    }

    /** A problem detail the filter writes itself, serialized by the application's JSON mapper; type null = about:blank. */
    private void answer(HttpServletRequest req, HttpServletResponse res, Guarded op, HttpStatus status, URI type, String title,
                        String detail) throws IOException {
        observe(req, op);
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        if (type != null) {
            problem.setType(type);
            problem.setTitle(title);
        }
        byte[] b = json.writeValueAsBytes(problem);
        res.setStatus(status.value());
        res.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        res.setContentLength(b.length);
        res.getOutputStream().write(b);
    }

    /** An answer that never reaches Spring MVC still carries its route in http.server.requests. */
    private static void observe(HttpServletRequest req, Guarded op) {
        ServerHttpObservationFilter.findObservationContext(req).ifPresent(c -> c.setPathPattern(op.route().getPatternString()));
    }

    private static Guarded guarded(HttpServletRequest req) {
        PathContainer path = PathContainer.parsePath(req.getRequestURI());
        for (Guarded g : GUARDED) {
            if (g.method().equals(req.getMethod()) && g.route().matches(path)) {
                if (g.formPasses() && isForm(req.getContentType())) {
                    return null;
                }
                return g;
            }
        }
        return null;
    }

    private static boolean isForm(String contentType) {
        if (contentType == null) {
            return false;
        }
        try {
            return MediaType.APPLICATION_FORM_URLENCODED.includes(MediaType.parseMediaType(contentType));
        } catch (InvalidMediaTypeException e) {
            return false;
        }
    }

    /** RFC 9651 section 4.2: every field line combined, then one Item that must be a String in TiffinBox's format; else null. */
    static String parse(List<String> lines) {
        String v = String.join(", ", lines);
        int a = 0;
        int z = v.length();
        while (a < z && v.charAt(a) == ' ') a++;
        while (z > a && v.charAt(z - 1) == ' ') z--;
        if (z - a < 2 || v.charAt(a) != '"' || v.charAt(z - 1) != '"') {
            return null;
        }
        String s = v.substring(a + 1, z - 1);
        return KEY.matcher(s).matches() ? s : null;
    }

    private static String fingerprint(HttpServletRequest req, byte[] body) {
        try {
            MessageDigest sha = MessageDigest.getInstance("SHA-256");
            String q = req.getQueryString();
            sha.update((req.getMethod() + " " + req.getRequestURI() + (q == null ? "" : "?" + q) + "\n").getBytes(StandardCharsets.UTF_8));
            sha.update(body);
            return HexFormat.of().formatHex(sha.digest());
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    private static void log(String s) {
        LOG.log(System.Logger.Level.DEBUG, "KEY " + s);
    }

    /** The request with its body read once, up front, and served again to whoever reads it next. */
    private static final class CachedBody extends HttpServletRequestWrapper {
        private final byte[] body;

        CachedBody(HttpServletRequest r, byte[] body) {
            super(r);
            this.body = body;
        }

        @Override
        public ServletInputStream getInputStream() {
            ByteArrayInputStream in = new ByteArrayInputStream(body);
            return new ServletInputStream() {
                @Override public int read() { return in.read(); }
                @Override public int read(byte[] b, int off, int len) { return in.read(b, off, len); }
                @Override public boolean isFinished() { return in.available() == 0; }
                @Override public boolean isReady() { return true; }
                @Override public void setReadListener(ReadListener l) { throw new UnsupportedOperationException(); }
            };
        }

        @Override
        public BufferedReader getReader() {
            return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
        }

        @Override public int getContentLength() { return body.length; }
        @Override public long getContentLengthLong() { return body.length; }
    }
}
