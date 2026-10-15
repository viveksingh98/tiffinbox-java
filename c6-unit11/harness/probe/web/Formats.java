package probe.web;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.boot.autoconfigure.condition.ConditionEvaluationReport;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.accept.ContentNegotiationManager;
import org.springframework.web.accept.ContentNegotiationStrategy;
import org.springframework.web.accept.FixedContentNegotiationStrategy;
import org.springframework.web.accept.ParameterContentNegotiationStrategy;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox and joins a run by --spring.main.sources, on the
 * extracted jar's class path. It runs unchanged beside the anchor and beside the copy with the XML module: it names no XML
 * class, so it compiles against the anchor's jar.
 *
 * /probe/formats answers three questions off the running application. Which message converters - the objects that turn a
 * return value into an answer's bytes - does Spring MVC's RequestMappingHandlerAdapter hold, in the order it asks them, and for
 * which media types? Which of them can write a com.tiffinbox.Customer, for each of five media types (canWrite)? And what did
 * Boot's own condition report decide for every configuration whose name holds "Xml" - Boot's auto-configuration, which adds a
 * bean only when its conditions match (the last course's lesson)? For an XML converter it also names its mapper's class and the
 * beans of that class.
 *
 * /probe/formats/strategies asks Spring MVC's content negotiation manager (the bean mvcContentNegotiationManager) which
 * strategies it asks, in order, to learn the formats a request wants - the Accept header's, a query parameter's, a fixed default -
 * and the format values it maps to media types (format=xml).
 *
 * /probe/formats/json and /probe/formats/both return one customer, Ravi, through TiffinBox's own CustomerRepository - each
 * route naming, with produces, the media types it can answer in: JSON alone, or JSON and XML.
 */
@RestController
public class Formats {

    private static final String[] TYPES = {"application/json", "application/xml", "application/xhtml+xml", "text/html", "text/plain"};

    private final RequestMappingHandlerAdapter adapter;
    private final ConfigurableListableBeanFactory beans;
    private final CustomerRepository repo;
    private final ContentNegotiationManager manager;

    public Formats(RequestMappingHandlerAdapter adapter, ConfigurableListableBeanFactory beans, CustomerRepository repo,
                   @Qualifier("mvcContentNegotiationManager") ContentNegotiationManager manager) {
        this.adapter = adapter;
        this.beans = beans;
        this.repo = repo;
        this.manager = manager;
    }

    @GetMapping("/probe/formats")
    public String formats() throws Exception {
        List<HttpMessageConverter<?>> all = adapter.getMessageConverters();
        StringBuilder out = new StringBuilder();
        out.append("message converters: ").append(all.size()).append(" - RequestMappingHandlerAdapter's, in the order it asks them\n");
        for (int i = 0; i < all.size(); i++) {
            HttpMessageConverter<?> c = all.get(i);
            out.append(String.format("%3d %s %s%n", i + 1, c.getClass().getSimpleName(), c.getSupportedMediaTypes()));
        }
        out.append("asked of each, for a ").append(Customer.class.getName()).append(" - canWrite, by media type - those that say yes:\n");
        for (String t : TYPES) {
            MediaType m = MediaType.parseMediaType(t);
            List<String> yes = new ArrayList<>();
            for (int i = 0; i < all.size(); i++) {
                if (all.get(i).canWrite(Customer.class, m)) {
                    yes.add((i + 1) + " " + all.get(i).getClass().getSimpleName());
                }
            }
            out.append("  ").append(t).append(": ").append(yes.size()).append(" of ").append(all.size())
               .append(yes.isEmpty() ? "" : " - " + String.join(" · ", yes)).append('\n');
        }
        for (int i = 0; i < all.size(); i++) {
            HttpMessageConverter<?> c = all.get(i);
            if (!c.getClass().getSimpleName().contains("Xml")) {
                continue;
            }
            Method getter = c.getClass().getMethod("getMapper");
            Object mapper = getter.invoke(c);
            String[] names = beans.getBeanNamesForType(mapper.getClass());
            out.append("the XML converter's mapper (").append(i + 1).append("): ").append(mapper.getClass().getName())
               .append(" · beans of that class: ").append(names.length).append(names.length == 0 ? "" : " - " + String.join(" ", names))
               .append('\n');
        }
        ConditionEvaluationReport report = ConditionEvaluationReport.get(beans);
        Map<String, ConditionEvaluationReport.ConditionAndOutcomes> by = new TreeMap<>(report.getConditionAndOutcomesBySource());
        List<String> rows = new ArrayList<>();
        for (var e : by.entrySet()) {
            if (!e.getKey().contains("Xml")) {
                continue;
            }
            rows.add("  " + e.getKey() + ": " + (e.getValue().isFullMatch() ? "matched" : "did not match"));
            for (var co : e.getValue()) {
                rows.add("    " + (co.getOutcome().isMatch() ? "+ " : "- ") + co.getOutcome().getMessage());
            }
        }
        long n = by.keySet().stream().filter(k -> k.contains("Xml")).count();
        out.append("Boot's condition report - the configurations whose name holds Xml: ").append(n).append('\n');
        for (String r : rows) {
            out.append(r).append('\n');
        }
        return out.toString();
    }

    @GetMapping("/probe/formats/strategies")
    public String strategies() {
        List<ContentNegotiationStrategy> all = manager.getStrategies();
        StringBuilder out = new StringBuilder();
        out.append("the content negotiation manager's strategies, in the order it asks them: ").append(all.size()).append('\n');
        for (int i = 0; i < all.size(); i++) {
            ContentNegotiationStrategy s = all.get(i);
            String more = "";
            if (s instanceof ParameterContentNegotiationStrategy p) {
                more = " - its parameter: " + p.getParameterName();
            }
            if (s instanceof FixedContentNegotiationStrategy f) {
                more = " - its content types: " + f.getContentTypes();
            }
            out.append(String.format("%3d %s%s%n", i + 1, s.getClass().getSimpleName(), more));
        }
        Map<String, MediaType> m = new TreeMap<>(manager.getMediaTypeMappings());
        out.append("the format values it maps: ").append(m.isEmpty() ? "none" : m.entrySet().stream()
                .map(e -> e.getKey() + " -> " + e.getValue()).collect(Collectors.joining(" · "))).append('\n');
        return out.toString();
    }

    /** One customer, from a route that answers in JSON alone. */
    @GetMapping(value = "/probe/formats/json", produces = MediaType.APPLICATION_JSON_VALUE)
    public Customer json() throws Exception {
        return repo.findByName("Ravi").orElseThrow();
    }

    /** The same customer, from a route that answers in JSON or XML. */
    @GetMapping(value = "/probe/formats/both", produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    public Customer both() throws Exception {
        return repo.findByName("Ravi").orElseThrow();
    }
}
