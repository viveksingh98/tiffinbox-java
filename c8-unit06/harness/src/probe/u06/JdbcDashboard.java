package probe.u06;

import com.tiffinbox.Customer;
import com.tiffinbox.Dashboard;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import com.tiffinbox.jdbc.PauseRow;
import org.springframework.data.domain.Sort;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Unit 06's Spring Data JDBC side of the dashboard: the same four answers as the anchor's Dashboard, read through unit 02's
 * CustomerAggregates - the aggregates by name (findAll(Sort.by("name"))), the two @Query sums, and each customer's paused days
 * summed from her aggregate's pauses. It returns the anchor's Dashboard.View, so the three sides are compared on one record.
 */
public final class JdbcDashboard {

    private final CustomerAggregates aggregates;

    public JdbcDashboard(CustomerAggregates aggregates) {
        this.aggregates = aggregates;
    }

    public Dashboard.View load() {
        List<CustomerRow> rows = aggregates.findAll(Sort.by("name"));
        List<Customer> customers = rows.stream()
                .map(c -> new Customer(c.getName(), c.getMealsPerDay(), c.getPricePerMeal(), c.getMealType().name()))
                .toList();
        int revenue = Math.toIntExact(aggregates.monthRevenue());
        int paused = Math.toIntExact(aggregates.pausedDays());
        Map<String, Integer> byName = new LinkedHashMap<>();
        for (CustomerRow c : rows) {
            byName.put(c.getName(), c.getPauses().stream().mapToInt(PauseRow::getDays).sum());
        }
        return new Dashboard.View(customers, revenue, paused, byName);
    }
}
