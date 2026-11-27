// THE PROBE'S COPY (Course 9 S4 probe): does resilience4j-spring-boot4 2.4.0 start on Boot 4.1.3? Never shipped.
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.annotation.Configuration;
@Configuration(proxyBeanMethods = false) @EnableAutoConfiguration
public class R4 { public static void main(String[] a) {
  try (var ctx = new SpringApplicationBuilder(R4.class).web(WebApplicationType.NONE).logStartupInfo(false).run(a)) {
    for (String n : ctx.getBeanDefinitionNames()) if (n.toLowerCase().contains("retry") || n.toLowerCase().contains("resilience")) System.out.println("R4 bean " + n + " -> " + ctx.getBean(n).getClass().getName());
    System.out.println("R4 started: Boot " + org.springframework.boot.SpringBootVersion.getVersion());
  } } }
