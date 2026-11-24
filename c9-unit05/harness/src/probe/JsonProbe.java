package probe;

import com.tiffinbox.Customer;
import jakarta.json.Json;
import jakarta.json.spi.JsonProvider;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.ObjectMapper;

import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * LANE 6's probe harness (Course 9 S1), never TiffinBox's: a runner (probe.json=true) that reads four bodies into TiffinBox's
 * Customer record through Boot's own JSON mapper bean and prints what the record holds or which exception; the mapper's class and
 * its DeserializationFeature states; readerForUpdating on a record; Spring MVC's message converters with their media types; the
 * JSON-P provider behind jakarta.json.Json. One "JSON ..." line each.
 */
@Configuration(proxyBeanMethods = false)
public class JsonProbe {

    static String ex(Throwable t) {
        String m = String.valueOf(t.getMessage()).lines().findFirst().orElse("");
        return t.getClass().getName() + ": " + (m.length() > 230 ? m.substring(0, 230) + "..." : m);
    }

    @Bean
    ApplicationRunner jsonProbeRunner(ObjectMapper mapper, RequestMappingHandlerAdapter adapter, Environment env) {
        return (ApplicationArguments a) -> {
            if (!"true".equals(env.getProperty("probe.json"))) return;
            System.out.println("JSON the JVM's locale: " + Locale.getDefault());
            System.out.println("JSON Boot's mapper bean: " + mapper.getClass().getName() + " (" + mapper.version() + ")");
            List<String> on = new ArrayList<>(), off = new ArrayList<>();
            for (DeserializationFeature f : DeserializationFeature.values()) (mapper.isEnabled(f) ? on : off).add(f.name());
            System.out.println("JSON DeserializationFeature enabled: " + on);
            System.out.println("JSON DeserializationFeature disabled: " + off);
            String[][] bodies = {
                    {"mealsPerDay absent", "{\"name\":\"Priya\",\"pricePerMeal\":120,\"mealType\":\"VEGAN\"}"},
                    {"mealsPerDay null", "{\"name\":\"Priya\",\"mealsPerDay\":null,\"pricePerMeal\":120,\"mealType\":\"VEGAN\"}"},
                    {"mealType absent", "{\"name\":\"Priya\",\"mealsPerDay\":1,\"pricePerMeal\":120}"},
                    {"mealType null", "{\"name\":\"Priya\",\"mealsPerDay\":1,\"pricePerMeal\":120,\"mealType\":null}"},
                    {"pricePerMeal 120.5", "{\"name\":\"Priya\",\"mealsPerDay\":1,\"pricePerMeal\":120.5,\"mealType\":\"VEGAN\"}"},
                    {"an unknown field", "{\"name\":\"Priya\",\"mealsPerDay\":1,\"pricePerMeal\":120,\"mealType\":\"VEGAN\",\"vip\":true}"},
            };
            for (String[] b : bodies) {
                try {
                    System.out.println("JSON read [" + b[0] + "] -> " + mapper.readValue(b[1], Customer.class));
                } catch (Exception e) {
                    System.out.println("JSON read [" + b[0] + "] !! " + ex(e));
                }
            }
            try {
                Object r = mapper.readerForUpdating(new Customer("Priya", 1, 120, "VEGAN")).readValue("{\"mealsPerDay\":2}");
                System.out.println("JSON readerForUpdating(record) -> " + r);
            } catch (Exception e) {
                System.out.println("JSON readerForUpdating(record) !! " + ex(e));
            }
            for (HttpMessageConverter<?> c : adapter.getMessageConverters()) {
                System.out.println("JSON converter " + c.getClass().getName() + " " + c.getSupportedMediaTypes());
            }
            System.out.println("JSON JSON-P provider: " + JsonProvider.provider().getClass().getName()
                    + " · createPatch -> " + Json.createPatch(Json.createReader(new StringReader("[]")).readArray()).getClass().getName()
                    + " · createMergePatch -> " + Json.createMergePatch(Json.createReader(new StringReader("{}")).readValue()).getClass().getName());
            System.out.println("JSON done");
        };
    }
}
