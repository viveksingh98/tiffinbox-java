package probe.u06;

import com.tiffinbox.Customer;
import com.tiffinbox.Dashboard;
import org.springframework.jdbc.core.simple.JdbcClient;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Unit 06's plain-SQL side of the dashboard: the same four answers as the anchor's Dashboard, each one SQL string through the
 * context's JdbcClient - the customers by name, a month's revenue, every pause's days, and each customer's paused days by a left
 * join. It returns the anchor's Dashboard.View, so the three sides are compared on one record.
 */
public final class PlainSql {

    private final JdbcClient client;

    public PlainSql(JdbcClient client) {
        this.client = client;
    }

    public Dashboard.View load() {
        List<Customer> customers = client.sql("select name, meals_per_day, price_per_meal, meal_type from customer order by name")
                .query(Customer.class).list();
        int revenue = Math.toIntExact(client.sql("select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer")
                .query(Long.class).single());
        int paused = Math.toIntExact(client.sql("select coalesce(sum(days), 0) from pause").query(Long.class).single());
        Map<String, Integer> byName = new LinkedHashMap<>();
        client.sql("select c.name, coalesce(sum(p.days), 0) from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name")
                .query((rs, i) -> byName.put(rs.getString(1), rs.getInt(2))).list();
        return new Dashboard.View(customers, revenue, paused, byName);
    }
}
