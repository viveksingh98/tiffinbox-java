package probe.count;

import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * The harness's split of Course 4's "fifty" - the course's, never TiffinBox's. It starts Course 4's nine-line Boot app
 * (com.tiffinbox.boot.BoxApp, its @SpringBootApplication class, from the app's own jar on the class path) exactly as its main
 * does - SpringApplication.run(BoxApp.class, args) - then prints the same count its main prints, split by package (Count.line),
 * and closes the context. No port: the app has no web server.
 */
public class BoxCount {
    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext context = SpringApplication.run(Class.forName("com.tiffinbox.boot.BoxApp"), args);
        System.out.println(Count.line("BoxApp", context.getBeanFactory()));
        context.close();
    }
}
