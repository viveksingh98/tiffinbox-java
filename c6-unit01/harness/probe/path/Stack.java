package probe.path;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * The harness's one route, outside com.tiffinbox: it joins TiffinBox by --spring.main.sources=probe.path.Stack and answers
 * GET /probe/stack on Spring MVC's server with its own call stack - every frame the JDK's stack walker shows, the method
 * itself first, numbered down to 1 at the bottom - and then the thread that ran it, and whether that thread is virtual. The
 * stack walker hides reflection's own frames (Method.invoke and the frames under it), so "frames" here means the frames it
 * shows.
 */
@RestController
public class Stack {

    @GetMapping("/probe/stack")
    String frames() {
        List<String> frames = StackWalker.getInstance().walk(s -> s.map(f -> f.getClassName() + "." + f.getMethodName()).toList());
        StringBuilder out = new StringBuilder();
        out.append("frames the stack walker shows: ").append(frames.size()).append('\n');
        for (int i = 0; i < frames.size(); i++) {
            out.append(String.format("%2d ", frames.size() - i)).append(frames.get(i)).append('\n');
        }
        Thread t = Thread.currentThread();   // last: a thread's name changes length (exec-9, exec-10), the lines above do not
        out.append("thread ").append(t.getName()).append(" · virtual ").append(t.isVirtual()).append('\n');
        return out.toString();
    }
}
