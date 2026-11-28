package com.tiffinbox.web;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

import java.util.regex.Pattern;

/**
 * Course 9, unit 20: a validator on every answer of the public API's reads - Spring Web's ShallowEtagHeaderFilter, registered on
 * {@code /api/v1/*} and nothing else, at order -80: after the rate limit (-95, {@link RateLimiting}) and the Idempotency-Key filter
 * (-90, {@link IdempotencyKeys}), so a refused request is never buffered or tagged. The SSE feed, the old surface, the pages,
 * /actuator and /v3/api-docs never meet it.
 *
 * <p>What it does: the answer of a GET that ends 2xx is buffered, its body hashed (MD5) into a strong tag - {@code ETag: "0..."},
 * no W/ - and sent with a Content-Length; when the request's If-None-Match names that tag the answer is 304 with no body. What it
 * does NOT do: the handler still runs on every 304, and the route still reads what it reads (a cached route reads nothing when
 * warm; an uncached one reads its rows every time) - the 304 saves the body's bytes on the wire, nothing else. It sets no
 * Cache-Control and writes no weak tag. A body that carries a per-start value (the order list's signed cursor, the bill link's
 * expiry) gets a tag that moves per start. A handler that sets its own tag keeps it (CustomerReads' deep tag): the filter hashes
 * only when no ETag is set.
 *
 * <p>The exclusion: U18's two streamed bill routes, {@code /api/v1/customers/{name}/bill} and its signed address
 * {@code /api/v1/customers/{name}/bill/signed}, are not filtered - buffering them would turn their chunked answer into one
 * Content-Length answer. {@link ApiEtags#shouldNotFilter} names those two shapes and nothing else.
 */
@Configuration(proxyBeanMethods = false)
class ConditionalGets {

    static final int ORDER = -80;

    /** The two streamed bill routes (CustomerBills): the path after the context path, exactly one of these two shapes. */
    static final Pattern STREAMED = Pattern.compile("/api/v1/customers/[^/]+/bill(/signed)?");

    @Bean
    FilterRegistrationBean<ApiEtags> apiEtagFilter() {
        FilterRegistrationBean<ApiEtags> registration = new FilterRegistrationBean<>(new ApiEtags());
        registration.setOrder(ORDER);
        registration.addUrlPatterns("/api/v1/*");
        registration.setName("apiEtagFilter");
        return registration;
    }

    /** Spring's shallow filter, minus the two streamed routes. */
    static final class ApiEtags extends ShallowEtagHeaderFilter {

        @Override
        protected boolean shouldNotFilter(HttpServletRequest request) {
            String path = request.getRequestURI().substring(request.getContextPath().length());
            return STREAMED.matcher(path).matches();
        }
    }
}
