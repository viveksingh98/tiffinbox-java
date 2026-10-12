package probe;

import java.util.List;

import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;

/**
 * The harness's own, outside com.tiffinbox: the message converters of the adapter that calls an annotated method
 * (RequestMappingHandlerAdapter's public getMessageConverters()), in the order it asks them. It joins TiffinBox by
 * --spring.main.sources=probe.Converters.
 */
@RestController
public class Converters {

    private final RequestMappingHandlerAdapter adapter;

    Converters(RequestMappingHandlerAdapter adapter) {
        this.adapter = adapter;
    }

    @GetMapping(path = "/probe/converters", produces = "text/plain")
    String converters() {
        List<HttpMessageConverter<?>> c = adapter.getMessageConverters();
        var out = new StringBuilder("message converters, the request mapping adapter's: " + c.size() + "\n");
        int i = 0;
        for (HttpMessageConverter<?> k : c) {
            out.append(++i).append(' ').append(k.getClass().getName()).append('\n');
        }
        return out.toString();
    }
}
