package com.tiffinbox.web;

import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.filter.OncePerRequestFilter;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Course 9, unit 19: the rate limit on TiffinBox's API - one token bucket (Bucket4j) per client address, on {@code /api/v1/*} only
 * ({@link RateLimiting} registers it there).
 *
 * <p>What it does: every request under {@code /api/v1/} takes one token from the bucket of the address the container gives
 * ({@code getRemoteAddr()}). While the bucket holds a token the request goes on, untouched - the answer gains no header and no byte.
 * When it is empty the filter answers itself, before any route or the Idempotency-Key filter runs: status 429, a problem
 * ({@code tag:tiffinbox.example,2026:rate-limited}) written as UTF-8 bytes with its Content-Length, and Retry-After - the bucket's own
 * wait for its next token, in whole seconds, rounded up, never below one. Each refusal logs one INFO line that names the method and
 * the path, never the address. Where the bucket lives is the profile's choice ({@link RateLimiting}): in this JVM on the default run,
 * in Redis under "dev".
 *
 * <p>What it does NOT do: the address is not an identity - callers behind one address share a bucket, and a caller who can change its
 * address is not stopped. No request header is read for the key, so a header the caller picks never chooses a bucket; a forwarded
 * address is the container's business (server.forward-headers-strategy), not this filter's. There is no per-user or per-customer
 * limit: who a caller is belongs to Spring Security - complete. The JVM's map of buckets is never evicted. It is not a quota: a
 * bucket refills as a whole each period, and nothing is counted across periods.
 */
public final class RateLimitFilter extends OncePerRequestFilter {

    private static final System.Logger LOG = System.getLogger("tiffinbox.ratelimit");
    static final String TYPE = "tag:tiffinbox.example,2026:rate-limited";

    /** Where the buckets live: one per address, made on the first request from it. */
    @FunctionalInterface
    interface Buckets {
        Bucket forAddress(String address);
    }

    private final Buckets buckets;
    private final JsonMapper json;

    RateLimitFilter(Buckets buckets, JsonMapper json) {
        this.buckets = buckets;
        this.json = json;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        ConsumptionProbe probe = buckets.forAddress(request.getRemoteAddr()).tryConsumeAndReturnRemaining(1);
        if (probe.isConsumed()) {
            chain.doFilter(request, response);
            return;
        }
        long retryAfter = Math.max(1, (probe.getNanosToWaitForRefill() + 999_999_999L) / 1_000_000_000L);
        Map<String, Object> problem = new LinkedHashMap<>();
        problem.put("type", TYPE);
        problem.put("title", "Too Many Requests");
        problem.put("status", 429);
        problem.put("detail", "This address has used its requests for now; Retry-After says when to send the next one.");
        problem.put("instance", request.getRequestURI());
        byte[] body = json.writeValueAsBytes(problem);
        LOG.log(System.Logger.Level.INFO, "rate limit: refused {0} {1}", request.getMethod(), request.getRequestURI());
        response.setStatus(429);
        response.setHeader("Retry-After", Long.toString(retryAfter));
        response.setContentType("application/problem+json");
        response.setContentLength(body.length);
        response.getOutputStream().write(body);
    }
}
