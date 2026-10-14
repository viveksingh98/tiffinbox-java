package probe.bare;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.bare.NoParams. Compiled
 * WITHOUT javac's -parameters, on purpose (receipts.sh, resolvers C): its class file keeps no parameter names, so the path
 * variable below has a type and an annotation, and no name Spring can read.
 */
@RestController
public class NoParams {

    @GetMapping("/probe/bare/{name}")
    public String name(@PathVariable String name) {
        return "name=[" + name + "]";
    }
}
