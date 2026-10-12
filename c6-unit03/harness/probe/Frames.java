package probe;

import java.util.List;
import java.util.Set;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The harness's own, outside com.tiffinbox: a route that answers the frames above it on its own thread, as the stack walker shows
 * them with reflection frames shown (SHOW_REFLECT_FRAMES: without it, Method.invoke's frames are hidden), from this method down to
 * the DispatcherServlet's doDispatch - and how many lie below that. It joins TiffinBox by --spring.main.sources=probe.Frames.
 */
@RestController
public class Frames {

    @GetMapping(path = "/probe/frames", produces = "text/plain")
    String frames() {
        List<String> all = StackWalker.getInstance(Set.of(StackWalker.Option.SHOW_REFLECT_FRAMES))
                .walk(s -> s.map(f -> f.getClassName() + "." + f.getMethodName()).toList());
        var out = new StringBuilder();
        int i = 0;
        for (String f : all) {
            out.append(++i).append(' ').append(f).append('\n');
            if (f.equals("org.springframework.web.servlet.DispatcherServlet.doDispatch")) break;
        }
        out.append("below it: ").append(all.size() - i).append(" more frames · ").append(all.size()).append(" in all\n");
        return out.toString();
    }
}
