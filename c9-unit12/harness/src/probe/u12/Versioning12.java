package probe.u12;

import java.net.URI;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.http.server.RequestPath;
import org.springframework.web.accept.StandardApiVersionDeprecationHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.ApiVersionConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Course 9, unit 12 - the harness's CARRIER mirror class, never TiffinBox's (the S2 probe's Versioning2, adapted: package probe.u12,
 * class Versioning12, VER12, the HE variant removed - HE stays a probe number, 1 run). From the probe: Framework 7.0.11's four strategies on one harness route pair (/vapi/customers 1.0 and 2.0; the
 * path variant /vapi/{v}/customers), ONE ApiVersionConfigurer per JVM by probe.ver:
 *   H header API-Version (required) · HD header, default 1.0 · Q query ?version= · M media-type parameter application/json;version=
 *   P path segment 1 only under /vapi/, not required · HE header + 1.0 deprecated (Course 6 U29's dates, a loopback link)
 *   HR header, supported = 2.0 only (detectSupportedVersions(false)) - 1.0 retired while its handler still exists
 *   HN header, not required, no default (Course 6 S6 trap 2's shape)
 * The /api/v1/ literal routes (U04-U06) and every set-up route are left as they are: the seven's md5 says whether they moved.
 */
@Configuration(proxyBeanMethods = false)
public class Versioning12 implements WebMvcConfigurer {
    private final Environment env;

    Versioning12(Environment env) { this.env = env; }

    static StandardApiVersionDeprecationHandler deprecations() {
        StandardApiVersionDeprecationHandler h = new StandardApiVersionDeprecationHandler();
        h.configureVersion("1.0")
         .setDeprecationDate(ZonedDateTime.of(2026, 10, 1, 0, 0, 0, 0, ZoneOffset.UTC))
         .setSunsetDate(ZonedDateTime.of(2027, 4, 1, 0, 0, 0, 0, ZoneOffset.UTC))
         .setDeprecationLink(URI.create("http://127.0.0.1/docs/customers-1.0"));
        return h;
    }

    static boolean underVapi(RequestPath p) { return p.pathWithinApplication().value().startsWith("/vapi/"); }

    @Override
    public void configureApiVersioning(ApiVersionConfigurer c) {
        String v = env.getProperty("probe.ver", "");
        System.out.println("VER12 variant " + v);
        switch (v) {
            case "H" -> c.useRequestHeader("API-Version");
            case "HD" -> c.useRequestHeader("API-Version").setDefaultVersion("1.0");
            case "Q" -> c.useQueryParam("version");
            case "M" -> c.useMediaTypeParameter(MediaType.APPLICATION_JSON, "version");
            case "P" -> c.usePathSegment(1, Versioning12::underVapi).setVersionRequired(false);
            case "HR" -> c.useRequestHeader("API-Version").detectSupportedVersions(false).addSupportedVersions("2.0");
            case "HN" -> c.useRequestHeader("API-Version").setVersionRequired(false);
            default -> throw new IllegalArgumentException("probe.ver must name a variant, got '" + v + "'");
        }
    }

    @RestController
    static class Routes {
        static Map<String, Object> answer(String handler) { var m = new LinkedHashMap<String, Object>(); m.put("handler", handler); return m; }
        @GetMapping(path = "/vapi/customers", version = "1.0") Map<String, Object> v10() { return answer("1.0"); }
        @GetMapping(path = "/vapi/customers", version = "2.0") Map<String, Object> v20() { return answer("2.0"); }
        @GetMapping(path = "/vapi/{v}/customers", version = "1.0") Map<String, Object> p10() { return answer("1.0 (path)"); }
        @GetMapping(path = "/vapi/{v}/customers", version = "2.0") Map<String, Object> p20() { return answer("2.0 (path)"); }
    }
}
