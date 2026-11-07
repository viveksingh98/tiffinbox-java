package probe.q.ex;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.aop.framework.Advised;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * The exercise's application: TiffinBox's core repository, com.tiffinbox.CustomerEntityRepository (after/'s core jar), and one
 * runner that needs it. Like TiffinBoxApp, this class lives outside com.tiffinbox, and it names the entities' package; it does
 * not name the repositories' - the import above is unused as shipped. No web server, no port.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    @Bean
    CommandLineRunner kitchen(CustomerEntityRepository customers) {
        return args -> System.out.println("PROBE ready: the kitchen has its CustomerEntityRepository - target "
                + ((Advised) customers).getTargetSource().getTarget().getClass().getSimpleName());
    }
}
