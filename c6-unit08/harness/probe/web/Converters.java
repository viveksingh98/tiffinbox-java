package probe.web;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.json.JsonMapper;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox and joins a run by --spring.main.sources, on the
 * extracted jar's class path. One question, answered by the running application: which of Spring MVC's message converters -
 * the objects that turn a request's body into a parameter, and a return value into an answer's bytes - can read a
 * com.tiffinbox.Customer, and write one. Read off the RequestMappingHandlerAdapter, which asks its converters in its own order,
 * the first that can read the type from the request's Content-Type reading it (Spring's AbstractMessageConverterMethodArgumentResolver)
 * - which /probe/converters/text shows: a String from application/json is readable by two, and the one asked first reads it.
 * Then the JSON converter's mapper: its class, whether it is Boot's bean jacksonJsonMapper, and one setting of it read back
 * (isEnabled) beside the same setting of a plain JsonMapper, built with no configuration at all.
 */
@RestController
public class Converters {

    private static final String[] TYPES = {"application/json", "application/x-www-form-urlencoded", "text/plain"};

    private final RequestMappingHandlerAdapter adapter;
    private final JsonMapper boots;

    public Converters(RequestMappingHandlerAdapter adapter, @Qualifier("jacksonJsonMapper") JsonMapper boots) {
        this.adapter = adapter;
        this.boots = boots;
    }

    @GetMapping("/probe/converters")
    public String converters() throws Exception {
        Class<?> customer = Class.forName("com.tiffinbox.Customer");
        List<HttpMessageConverter<?>> all = adapter.getMessageConverters();
        StringBuilder out = new StringBuilder();
        out.append("message converters: ").append(all.size())
           .append(" - RequestMappingHandlerAdapter's, in the order it asks them\n");
        for (int i = 0; i < all.size(); i++) {
            HttpMessageConverter<?> c = all.get(i);
            out.append(String.format("%3d %s %s%n", i + 1, c.getClass().getSimpleName(), c.getSupportedMediaTypes()));
        }
        out.append("asked of each, for a ").append(customer.getName()).append(" - canRead or canWrite, by media type - those that say yes:\n");
        for (String t : TYPES) {
            MediaType m = MediaType.parseMediaType(t);
            List<String> yes = new ArrayList<>();
            for (int i = 0; i < all.size(); i++) {
                HttpMessageConverter<?> c = all.get(i);
                boolean r = c.canRead(customer, m);
                boolean w = c.canWrite(customer, m);
                if (r || w) {
                    yes.add((i + 1) + " " + c.getClass().getSimpleName() + " (read " + (r ? "yes" : "no") + ", write "
                            + (w ? "yes" : "no") + ")");
                }
            }
            out.append("  ").append(t).append(": ").append(yes.size()).append(" of ").append(all.size())
               .append(yes.isEmpty() ? "" : " - " + String.join(" · ", yes)).append('\n');
        }
        List<String> text = new ArrayList<>();
        for (int i = 0; i < all.size(); i++) {
            if (all.get(i).canRead(String.class, MediaType.APPLICATION_JSON)) {
                text.add((i + 1) + " " + all.get(i).getClass().getSimpleName());
            }
        }
        out.append("asked of each, for a java.lang.String from application/json - canRead - those that say yes: ").append(text.size())
           .append(" of ").append(all.size()).append(text.isEmpty() ? "" : " - " + String.join(" · ", text)).append('\n');
        for (int i = 0; i < all.size(); i++) {
            HttpMessageConverter<?> c = all.get(i);
            if (!c.getSupportedMediaTypes().contains(MediaType.APPLICATION_JSON)) {
                continue;
            }
            Method getter = c.getClass().getMethod("getMapper");
            Object mapper = getter.invoke(c);
            out.append("the JSON converter's mapper (").append(i + 1).append(" ").append(c.getClass().getSimpleName()).append("): ")
               .append(mapper.getClass().getName()).append(" · Boot's bean jacksonJsonMapper itself: ")
               .append(mapper == boots ? "yes" : "no").append('\n');
        }
        JsonMapper plain = JsonMapper.builder().build();
        out.append("FAIL_ON_UNKNOWN_PROPERTIES - Boot's mapper: ")
           .append(boots.isEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES))
           .append(" · a plain JsonMapper (JsonMapper.builder().build()): ")
           .append(plain.isEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)).append('\n');
        return out.toString();
    }

    /** A String parameter, read from a JSON body: two converters can read it - the one asked first reads it. */
    @PostMapping("/probe/converters/text")
    public String text(@RequestBody String body) {
        return "the String parameter got: " + body;
    }
}
