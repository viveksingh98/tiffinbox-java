package probe.ex;

import com.tiffinbox.Customer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.simple.JdbcClient;

import java.util.Optional;

/**
 * Unit 04's exercise: TiffinBox (both Spring Data modules) with no web server, on H2 in memory. The lookup a customer route makes
 * - one customer by name, through the context's JdbcClient - runs for Meera, who exists, then for Nobody, who does not. As
 * shipped the second lookup throws, and the exception ends the program with exit 1, as it would end the route's request.
 */
public final class Ex04 {
    static final String BY_NAME = "select name, meals_per_day, price_per_meal, meal_type from customer where name = :name";

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        app.setWebApplicationType(WebApplicationType.NONE);
        var ctx = app.run("--spring.main.banner-mode=off", "--logging.level.root=warn");
        var client = ctx.getBean(JdbcClient.class);
        System.out.println("EX lookup Meera: " + client.sql(BY_NAME).param("name", "Meera").query(Customer.class).single());
        try {
            var nobody = client.sql(BY_NAME).param("name", "Nobody").query(Customer.class).single();
            System.out.println("EX lookup Nobody: " + nobody);
            boolean empty = ((Object) nobody) instanceof Optional<?> o && o.isEmpty();
            System.out.println("EX done: " + (empty ? "yes - an empty result, no exception" : "no - the result is not empty"));
        } catch (DataAccessException x) {
            System.out.println("EX lookup Nobody threw: " + x.getClass().getName() + ": " + x.getMessage());
            System.out.println("EX done: no - the lookup crashed");
            ctx.close();
            System.exit(1);
        }
        ctx.close();
    }
}
