package probe.web;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.service.registry.ImportHttpServices;

/** The course's harness: MenuApi in a service group named "menu" (spring-web's @ImportHttpServices; Boot builds its client from
 *  spring.http.serviceclient.menu.*), and a runner that calls both methods once, one VER line each. */
@Configuration
@ImportHttpServices(group = "menu", types = MenuApi.class)
public class MenuGroup {
    @Bean
    ApplicationRunner menuCalls(MenuApi api) {
        return (ApplicationArguments a) -> {
            Versions.out("group ravi", () -> api.ravi().length() + " characters");
            Versions.out("group meera", () -> api.meera().length() + " characters");
            System.out.println("VER group done");
        };
    }
}
