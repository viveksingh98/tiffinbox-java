package probe.ex;

import com.tiffinbox.Customer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import java.util.Map;

/**
 * Unit 05's exercise: TiffinBox (both Spring Data modules) with no web server, on H2 in memory. One lookup - Meera, by her meal
 * type and her name - through the context's JdbcTemplate, with two question marks. The SQL wants the meal type first and the name
 * second; the call passes them the other way round, so the database is asked for a customer named "NON_VEG" who eats "Meera".
 * As shipped the lookup finds no row, the exception ends the program with exit 1.
 */
public final class Ex05 {
    static final String BY_TYPE_AND_NAME = "select name, meals_per_day, price_per_meal, meal_type from customer where meal_type = ? and name = ?";
    static final String BY_TYPE_AND_NAME_NAMED = "select name, meals_per_day, price_per_meal, meal_type from customer where meal_type = :mealType and name = :name";
    static final RowMapper<Customer> BY_HAND = (rs, i) -> new Customer(rs.getString("name"), rs.getInt("meals_per_day"), rs.getInt("price_per_meal"), rs.getString("meal_type"));

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        app.setWebApplicationType(WebApplicationType.NONE);
        var ctx = app.run("--spring.main.banner-mode=off", "--logging.level.root=warn");
        var jdbc = ctx.getBean(JdbcTemplate.class);
        var named = ctx.getBean(NamedParameterJdbcTemplate.class);
        try {
            Customer meera = jdbc.queryForObject(BY_TYPE_AND_NAME, BY_HAND, "Meera", "NON_VEG");
            System.out.println("EX lookup Meera: " + meera);
            System.out.println("EX done: " + ("Meera".equals(meera.name()) ? "yes - Meera's row, whatever the order of the arguments" : "no - another row"));
        } catch (DataAccessException x) {
            System.out.println("EX lookup Meera threw: " + x.getClass().getName() + ": " + x.getMessage());
            System.out.println("EX done: no - the lookup found no row");
            ctx.close();
            System.exit(1);
        }
        ctx.close();
    }
}
