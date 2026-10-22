package probe.web;

import java.util.Map;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: three routes that answer GET and PUT with a small map naming themselves. The first carries
 * its own CORS rule, @CrossOrigin, for one origin - http://127.0.0.1:19486, the page this unit's harness serves on that port. The
 * second and third carry none: GlobalCors gives /probe/global/** a rule through Spring MVC's CORS registry, and FilterCors gives
 * /probe/filter/** one through a CorsFilter. Each prints a line when it runs (Trace).
 */
@RestController
public class CorsRoutes {

    @CrossOrigin(origins = "http://127.0.0.1:19486")
    @RequestMapping(path = "/probe/cors/menu", method = {RequestMethod.GET, RequestMethod.PUT})
    public Map<String, String> annotated() {
        Trace.log("CorsRoutes      annotated");
        return Map.of("menu", "annotated");
    }

    @RequestMapping(path = "/probe/global/menu", method = {RequestMethod.GET, RequestMethod.PUT})
    public Map<String, String> global() {
        Trace.log("CorsRoutes      global");
        return Map.of("menu", "global");
    }

    @RequestMapping(path = "/probe/filter/menu", method = {RequestMethod.GET, RequestMethod.PUT})
    public Map<String, String> filtered() {
        Trace.log("CorsRoutes      filtered");
        return Map.of("menu", "filter");
    }
}
