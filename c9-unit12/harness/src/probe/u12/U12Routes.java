package probe.u12;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Course 9, unit 12 - the harness's ROUTE PAIR, never TiffinBox's: joined by --spring.main.sources on a harness-joined start of a
 * shipped-class mirror only. GET /api/{v}/u12/handler for version 1.0 and for version 2.0 (each answers which handler ran), and
 * GET /u12/plain unversioned - so "both spellings resolve 1.0" is measured on routes that can carry a version, and the document's
 * paths for a versioned route can be read. Every line that uses them is "the harness's route".
 */
@RestController
public class U12Routes {
    static Map<String, Object> answer(String handler) { var m = new LinkedHashMap<String, Object>(); m.put("handler", handler); return m; }
    @GetMapping(path = "/api/{v}/u12/handler", version = "1.0") Map<String, Object> h10() { return answer("1.0 (path)"); }
    @GetMapping(path = "/api/{v}/u12/handler", version = "2.0") Map<String, Object> h20() { return answer("2.0 (path)"); }
    @GetMapping("/u12/plain") Map<String, Object> plain() { return answer("plain"); }
}
