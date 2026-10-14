package probe.json;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.json.JsonMapper;

/**
 * The course's harness, never TiffinBox's (outside com.tiffinbox, joined by --spring.main.sources). java.time, with no module
 * registered: a record holding a LocalDate, a LocalDateTime and a Duration - fixed values, never the clock - written by Boot's
 * mapper (Spring MVC's JSON converter, GET /probe/dates), then by a plain JsonMapper, built with no configuration, with the
 * number of modules registered on it (GET /probe/dates/plain). Core Java II's Jackson 2 refused a LocalDate without a module.
 */
@RestController
public class Dates {

    public record When(LocalDate day, LocalDateTime at, Duration took) { }

    static final When LUNCH = new When(LocalDate.of(2026, 10, 14), LocalDateTime.of(2026, 10, 14, 12, 30), Duration.ofMinutes(25));

    @GetMapping("/probe/dates")
    public When boots() {
        return LUNCH;
    }

    @GetMapping("/probe/dates/plain")
    public String plain() {
        JsonMapper plain = JsonMapper.builder().build();
        return plain.writeValueAsString(LUNCH) + " · modules registered on it: " + plain.registeredModules().size() + "\n";
    }
}
