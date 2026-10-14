package probe.web;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox and joins a run by --spring.main.sources. One
 * question, answered by the running application: which of Spring MVC's message converters - the objects that turn a return
 * value into the bytes of an answer - write application/json, and with which JSON library's mapper. Read off the adapter that
 * calls Spring's own controllers (Boot's error controller among them).
 */
@RestController
public class Converters {

    private final RequestMappingHandlerAdapter adapter;

    public Converters(RequestMappingHandlerAdapter adapter) {
        this.adapter = adapter;
    }

    /** How many converters the adapter holds; then each one that writes application/json: its class, and its mapper's class. */
    @GetMapping("/probe/converters")
    public String converters() throws Exception {
        List<String> json = new ArrayList<>();
        List<HttpMessageConverter<?>> all = adapter.getMessageConverters();
        for (HttpMessageConverter<?> c : all) {
            if (!c.getSupportedMediaTypes().contains(MediaType.APPLICATION_JSON)) {
                continue;
            }
            String mapper = " · its mapper: none found";
            for (String getter : new String[] {"getMapper", "getObjectMapper"}) {
                try {
                    Method m = c.getClass().getMethod(getter);
                    mapper = " · its mapper: " + m.invoke(c).getClass().getName();
                    break;
                } catch (NoSuchMethodException e) {
                    // not this getter: try the next
                }
            }
            json.add(c.getClass().getName() + mapper);
        }
        return "converters: " + all.size() + " · for application/json: " + json.size() + "\n" + String.join("\n", json) + "\n";
    }
}
