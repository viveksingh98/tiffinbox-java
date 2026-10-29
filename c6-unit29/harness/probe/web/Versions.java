package probe.web;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Callable;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ApiVersionInserter;
import org.springframework.web.client.RestClient;

/** The course's harness: an ApplicationRunner that prints the JVM's locale, then runs the cases --probe.cases names, one VER
 *  line each, then "VER done". Every client is spring-web's RestClient.builder() - a new builder per client, built once (R.141) -
 *  with one ApiVersionInserter: the client side of API versioning. probe.stub is the stub's address, probe.self TiffinBox's own. */
@Component
public class Versions implements ApplicationRunner {
    private final Environment env;

    Versions(Environment env) { this.env = env; }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println("VER the JVM's locale: " + Locale.getDefault());
        String stub = env.getProperty("probe.stub"), self = env.getProperty("probe.self");
        List<String> cases = Arrays.asList(env.getProperty("probe.cases", "").split(","));
        for (String c : cases) {
            switch (c) {
                case "" -> { }
                case "header" -> get(c, ApiVersionInserter.useHeader("API-Version"), stub + "/customers.json");
                case "query" -> get(c, ApiVersionInserter.useQueryParam("version"), stub + "/customers.json");
                case "path" -> get(c, ApiVersionInserter.usePathSegment(0), stub + "/customers.json");
                case "media" -> get(c, ApiVersionInserter.useMediaTypeParam("v"), stub + "/customers.json");
                case "mediapost" -> {
                    RestClient m = RestClient.builder().apiVersionInserter(ApiVersionInserter.useMediaTypeParam("v")).build();
                    out(c, () -> m.post().uri(stub + "/payments").contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                            .apiVersion("1.1").body("{\"customer\":\"Ravi\",\"amount\":7200}").retrieve().toEntity(String.class).getStatusCode());
                }
                case "none" -> {
                    RestClient n = RestClient.builder().build();
                    out(c, () -> n.get().uri(stub + "/ravi.json").apiVersion("1.1").retrieve().toEntity(String.class).getStatusCode());
                }
                case "selfheader" -> {
                    RestClient s = RestClient.builder().apiVersionInserter(ApiVersionInserter.useHeader("API-Version")).build();
                    out(c, () -> s.get().uri(self + "/menu").apiVersion("1.1").retrieve().body(String.class));
                }
                case "selfmedia" -> {
                    RestClient s = RestClient.builder().apiVersionInserter(ApiVersionInserter.useMediaTypeParam("v")).build();
                    out(c, () -> s.get().uri(self + "/menu").accept(MediaType.APPLICATION_JSON).apiVersion("1.1").retrieve().body(String.class));
                }
                default -> throw new IllegalArgumentException("no such case: " + c);
            }
        }
        System.out.println("VER done");
    }

    private static void get(String name, ApiVersionInserter inserter, String url) {
        RestClient c = RestClient.builder().apiVersionInserter(inserter).build();
        out(name, () -> c.get().uri(url).accept(MediaType.APPLICATION_JSON).apiVersion("1.1").retrieve().toEntity(String.class).getStatusCode());
    }

    static void out(String name, Callable<Object> call) {
        try {
            System.out.println("VER " + name + " -> " + call.call());
        } catch (Exception e) {
            System.out.println("VER " + name + " !! " + e.getClass().getName() + ": " + e.getMessage());
        }
    }
}
