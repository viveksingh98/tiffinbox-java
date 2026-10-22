package probe.web;

import jakarta.servlet.SessionTrackingMode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * The course's harness, never TiffinBox's: a session read from the inside. GET /probe/visits takes the request's session - Tomcat
 * makes one when the request brought none - counts this visit in it (the attribute "visits", a number), and answers what Tomcat
 * says about it: the count, whether the session is new (made by this request: its client has not sent its cookie back yet), how
 * long it may sit unused, in seconds, before Tomcat drops it, and the servlet context's session tracking modes - the ones in
 * effect and the container's default - sorted by name. The session's id is never printed.
 */
@RestController
public class Visits {

    @GetMapping("/probe/visits")
    Map<String, Object> visits(HttpServletRequest request) {
        HttpSession s = request.getSession();
        Integer n = (Integer) s.getAttribute("visits");
        n = n == null ? 1 : n + 1;
        s.setAttribute("visits", n);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("visits", n);
        m.put("new", s.isNew());
        m.put("maxInactiveSeconds", s.getMaxInactiveInterval());
        m.put("trackingModes", names(request.getServletContext().getEffectiveSessionTrackingModes()));
        m.put("defaultTrackingModes", names(request.getServletContext().getDefaultSessionTrackingModes()));
        return m;
    }

    private static Set<String> names(Set<SessionTrackingMode> modes) {
        Set<String> out = new TreeSet<>();
        modes.forEach(x -> out.add(x.name()));
        return out;
    }
}
