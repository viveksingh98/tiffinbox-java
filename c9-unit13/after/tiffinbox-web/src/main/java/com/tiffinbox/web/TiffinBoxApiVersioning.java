package com.tiffinbox.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.http.server.RequestPath;
import org.springframework.web.servlet.config.annotation.ApiVersionConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Course 9, unit 12: switches on Spring Framework 7's API versioning for TiffinBox's public routes, and nothing else. Under
 * {@code /api/} the path's second segment is the version: {@code /api/v1/customers/Ravi} carries the version {@code v1}, which the
 * resolver reads as {@code 1.0}. Version {@code 1.0} is the one supported version, so the five literal {@code /api/v1/...} routes keep
 * their strings and answer as before. A version no route carries under {@code /api/} is not found: the routes are literal strings,
 * so no mapping matches such a path and the version is never checked (unit 12's receipts measured it).
 * Routes outside {@code /api/} (the set-up's {@code /customers}, {@code /dashboard}, {@code /kitchen} and the rest) are not versioned:
 * the predicate leaves them alone, and a request to them needs no version.
 *
 * <p>What this class does NOT do: it sets no default version, no deprecation handler and no {@code detectSupportedVersions(false)};
 * no version is deprecated or retired in the anchor - there is no version two to move to. Retirement and deprecation are measured on
 * scratch mirrors of this class under {@code c9-unit12/harness/mirror/}, never shipped here.
 */
@Configuration(proxyBeanMethods = false)
class TiffinBoxApiVersioning implements WebMvcConfigurer {

    /** Course 9, unit 12: only a path under /api/ carries a version (its second segment); every other path is unversioned. */
    static boolean underApi(RequestPath p) {
        return p.pathWithinApplication().value().startsWith("/api/");
    }

    @Override
    public void configureApiVersioning(ApiVersionConfigurer c) {
        // Course 9, unit 12: the path carrier, restricted to /api/; not required; 1.0 supported (the literal /api/v1/ routes' version)
        c.usePathSegment(1, TiffinBoxApiVersioning::underApi).setVersionRequired(false).addSupportedVersions("1.0");
    }
}
