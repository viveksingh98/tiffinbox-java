package probe.json;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's (outside com.tiffinbox, joined by --spring.main.sources). A record of its own whose
 * component mealsPerDay carries @JsonProperty("meals") - the annotation Core Java II's Jackson lesson put on a record, from the
 * annotations jar both Jacksons read (com.fasterxml.jackson.annotation): written by Boot's mapper (GET), and read back from a
 * request's body (POST, the record returned as it was read).
 */
@RestController
public class Rename {

    public record Meals(String name, @JsonProperty("meals") int mealsPerDay) { }

    @GetMapping("/probe/rename")
    public Meals one() {
        return new Meals("Ravi", 2);
    }

    @PostMapping("/probe/rename")
    public Meals echo(@RequestBody Meals meals) {
        return meals;
    }
}
