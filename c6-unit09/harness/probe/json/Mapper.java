package probe.json;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.actuate.endpoint.jackson.EndpointJsonMapper;
import org.springframework.context.ApplicationContext;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import tools.jackson.core.StreamReadFeature;
import tools.jackson.core.StreamWriteFeature;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.JacksonModule;
import tools.jackson.databind.MapperFeature;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.PropertyNamingStrategy;
import tools.jackson.databind.SerializationFeature;
import tools.jackson.databind.cfg.DatatypeFeature;
import tools.jackson.databind.cfg.DateTimeFeature;
import tools.jackson.databind.cfg.EnumFeature;
import tools.jackson.databind.cfg.JsonNodeFeature;
import tools.jackson.databind.json.JsonMapper;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox and joins a run by --spring.main.sources, on the
 * extracted jar's class path. One question, answered by the running application: what is the JSON mapper Boot built - the object
 * that reads and writes JSON for Spring MVC - and how is it set? Read off the context: the beans of type JsonMapper (and of
 * Jackson 3's ObjectMapper, which JsonMapper extends); whether the JSON message converter's mapper is that bean; Actuator's own
 * mapper (its EndpointJsonMapper); the modules registered on each; the property naming strategy; and every feature of eight kinds
 * - each enum's every constant, read back with isEnabled - against the same features of a plain JsonMapper, built with no
 * configuration at all (JsonMapper.builder().build()): the features where Boot's mapper differs from Jackson 3's own defaults.
 * /probe/mapper/all lists every feature of Boot's mapper, one per line, so two runs can be compared.
 */
@RestController
public class Mapper {

    static final Class<?>[] KINDS = {MapperFeature.class, DeserializationFeature.class, SerializationFeature.class,
            DateTimeFeature.class, EnumFeature.class, JsonNodeFeature.class, StreamReadFeature.class, StreamWriteFeature.class};
    static final Enum<?>[] NAMED = {MapperFeature.SORT_PROPERTIES_ALPHABETICALLY, MapperFeature.SORT_CREATOR_PROPERTIES_FIRST,
            SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS, DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,
            DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, DeserializationFeature.ACCEPT_FLOAT_AS_INT,
            DeserializationFeature.FAIL_ON_TRAILING_TOKENS, DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS};

    private final ApplicationContext context;
    private final RequestMappingHandlerAdapter adapter;
    private final JsonMapper boots;

    public Mapper(ApplicationContext context, RequestMappingHandlerAdapter adapter, @Qualifier("jacksonJsonMapper") JsonMapper boots) {
        this.context = context;
        this.adapter = adapter;
        this.boots = boots;
    }

    static boolean on(ObjectMapper m, Enum<?> f) {
        if (f instanceof MapperFeature x) return m.isEnabled(x);
        if (f instanceof DeserializationFeature x) return m.isEnabled(x);
        if (f instanceof SerializationFeature x) return m.isEnabled(x);
        if (f instanceof DatatypeFeature x) return m.isEnabled(x);
        if (f instanceof StreamReadFeature x) return m.isEnabled(x);
        if (f instanceof StreamWriteFeature x) return m.isEnabled(x);
        throw new IllegalArgumentException(f.toString());
    }
    static String nm(Enum<?> f) { return f.getDeclaringClass().getSimpleName() + "." + f.name(); }
    static String naming(ObjectMapper m) {
        PropertyNamingStrategy s = m.serializationConfig().getPropertyNamingStrategy();
        return s == null ? "none" : s.getClass().getSimpleName();
    }

    @GetMapping("/probe/mapper")
    public String mapper() throws Exception {
        StringBuilder o = new StringBuilder();
        String[] js = context.getBeanNamesForType(JsonMapper.class), os = context.getBeanNamesForType(ObjectMapper.class);
        o.append("beans of type JsonMapper: ").append(js.length).append(" - ").append(String.join(" ", js)).append(" (")
         .append(boots.getClass().getName()).append(") · of type ObjectMapper, Jackson 3's: ").append(os.length).append(" - ")
         .append(String.join(" ", os)).append('\n');
        for (HttpMessageConverter<?> c : adapter.getMessageConverters()) {
            if (!c.getSupportedMediaTypes().contains(MediaType.APPLICATION_JSON)) continue;
            Method g = c.getClass().getMethod("getMapper");
            o.append("the JSON converter's mapper (").append(c.getClass().getSimpleName()).append("): Boot's bean jacksonJsonMapper itself: ")
             .append(g.invoke(c) == boots ? "yes" : "no").append('\n');
        }
        JsonMapper plain = JsonMapper.builder().build();
        JsonMapper actuator = context.getBean(EndpointJsonMapper.class).get();
        o.append("Actuator's mapper (the bean ").append(String.join(" ", context.getBeanNamesForType(EndpointJsonMapper.class)))
         .append(", an EndpointJsonMapper): Boot's bean itself: ").append(actuator == boots ? "yes" : "no").append('\n');
        List<String> bm = new ArrayList<>(), pm = new ArrayList<>();
        for (JacksonModule m : boots.registeredModules()) bm.add(m.getModuleName().replaceAll("^.*\\.", ""));
        for (JacksonModule m : plain.registeredModules()) pm.add(m.getModuleName().replaceAll("^.*\\.", ""));
        bm.sort(null);
        o.append("modules registered - Boot's mapper: ").append(bm.size()).append(bm.isEmpty() ? "" : " (" + String.join(", ", bm) + ")")
         .append(" · a plain JsonMapper (JsonMapper.builder().build()): ").append(pm.size()).append('\n');
        o.append("property naming - Boot's mapper: ").append(naming(boots)).append(" · Actuator's: ").append(naming(actuator))
         .append(" · a plain one: ").append(naming(plain)).append('\n');
        int n = 0;
        List<String> diff = new ArrayList<>();
        StringBuilder kinds = new StringBuilder();
        for (Class<?> k : KINDS) {
            Object[] all = k.getEnumConstants();
            kinds.append(kinds.length() == 0 ? "" : ", ").append(k.getSimpleName()).append(' ').append(all.length);
            for (Object c : all) {
                Enum<?> f = (Enum<?>) c; n++;
                if (on(boots, f) != on(plain, f)) diff.add("  " + nm(f) + " - Boot's mapper: " + on(boots, f) + " · a plain one: " + on(plain, f));
            }
        }
        o.append("features read: ").append(n).append(" - every constant of ").append(KINDS.length).append(" kinds (").append(kinds)
         .append(") · Boot's mapper and a plain one differ in: ").append(diff.size()).append('\n');
        for (String d : diff) o.append(d).append('\n');
        o.append("the ").append(NAMED.length).append(" this lesson names - Boot's mapper · a plain one · Actuator's:\n");
        for (Enum<?> f : NAMED) o.append("  ").append(nm(f)).append(": ").append(on(boots, f)).append(" · ").append(on(plain, f))
                                  .append(" · ").append(on(actuator, f)).append('\n');
        return o.toString();
    }

    @GetMapping("/probe/mapper/all")
    public String all() {
        StringBuilder o = new StringBuilder();
        for (Class<?> k : KINDS) for (Object c : k.getEnumConstants()) o.append(nm((Enum<?>) c)).append(' ').append(on(boots, (Enum<?>) c)).append('\n');
        return o.toString();
    }
}
