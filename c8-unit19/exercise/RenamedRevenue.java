import static org.springframework.data.mongodb.core.aggregation.Aggregation.group;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.newAggregation;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.sort;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.data.annotation.Id;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.query.Query;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 19's exercise: TiffinBox's orders, one per customer per day - the four customers of after/'s V2__seed.sql, their meals times
 * their price, for tiffinbox.days days (after/'s application.yaml) - saved into the collection orders_r of the MongoDB on
 * 127.0.0.1:20589, with the customer stored under another name, cust (@Field). Then the revenue pipeline: group by customer, sum
 * the values, sort by the total. It prints every group it gets back, sorted by total and then by name, and how many there are.
 */
public class RenamedRevenue {

    @Document("orders_r")
    public record OrderRenamed(@Id String id, @Field("cust") String customer, String mealType, int day, int value) {
    }

    public record Total(@Id String customer, int total) {
    }

    public static void main(String[] args) throws Exception {
        String seed = Files.readString(Path.of("after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql"));
        Matcher d = Pattern.compile("(?m)^  days: (\\d+)$").matcher(Files.readString(Path.of("after/tiffinbox-web/src/main/resources/application.yaml")));
        d.find();
        int days = Integer.parseInt(d.group(1));
        var orders = new ArrayList<OrderRenamed>();
        Matcher c = Pattern.compile("VALUES \\('(\\w+)', (\\d+), (\\d+), '(\\w+)'\\)").matcher(seed);
        while (c.find()) {
            for (int day = 1; day <= days; day++) {
                orders.add(new OrderRenamed(c.group(1) + "-" + day, c.group(1), c.group(4), day,
                        Integer.parseInt(c.group(2)) * Integer.parseInt(c.group(3))));
            }
        }
        try (MongoClient client = MongoClients.create("mongodb://127.0.0.1:20589/tiffinbox")) {
            MongoTemplate mongo = new MongoTemplate(client, "tiffinbox");
            mongo.remove(new Query(), OrderRenamed.class);
            mongo.insertAll(orders);
            List<Total> groups = new ArrayList<>(mongo.aggregate(
                    newAggregation(group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total")),
                    "orders_r", Total.class).getMappedResults());
            groups.sort(Comparator.comparing(Total::total).reversed().thenComparing(t -> String.valueOf(t.customer())));
            System.out.println("orders saved: " + mongo.count(new Query(), OrderRenamed.class));
            for (Total t : groups) {
                System.out.println("group " + t.customer() + " " + t.total());
            }
            System.out.println("groups: " + groups.size());
        }
    }
}
