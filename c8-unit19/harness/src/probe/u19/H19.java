package probe.u19;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.group;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.newAggregation;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.sort;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.tiffinbox.web.OrderDocument;
import com.tiffinbox.web.OrderDocuments;
import com.tiffinbox.web.Revenue;
import org.bson.Document;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.repository.support.MongoRepositoryFactory;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.TreeMap;
import java.util.stream.Collectors;

/**
 * Unit 19's harness JVM (the harness's, never TiffinBox's): MongoDB's Java driver and a MongoTemplate built on it, over the unit's
 * MongoDB on 127.0.0.1 (-Dh19.port), database tiffinbox, the shipped classes com.tiffinbox.web.OrderDocument, OrderDocuments and
 * Revenue.Total (after/'s jar) and the harness's copy OrderRenamed. No web server, no Spring context: the repository comes from
 * MongoRepositoryFactory over the template - the factory Spring Data's own bean uses - so the derived finder is the shipped one.
 * Steps (one per argument, comma-separated):
 *   finder     OrderDocuments.findByMealType("VEG"), once: the count, the documents per customer
 *   criteria   MongoTemplate.find(Query.query(Criteria.where("mealType").is("VEG")), OrderDocument.class), once: the count
 *   pipeline   the untyped pipeline on orders: group("customer").sum("value").as("total"), sort(DESC, "total") -> Revenue.Total
 *   shipped    Revenue's own typed pipeline (newAggregation(OrderDocument.class, ...)) on orders
 *   copy       orders read whole (OrderDocument), saved into orders_r as OrderRenamed (the collection emptied first, a delete)
 *   typedr     the typed pipeline on the copy: newAggregation(OrderRenamed.class, group("customer").sum("value")..., sort)
 *   untypedr   the untyped pipeline on the copy: newAggregation(group("customer").sum("value")..., sort) on orders_r
 *   summeal    the untyped pipeline with sum("mealType") on orders - a String summed
 * Every group list is printed sorted by total, then _id (ties are never read in the server's order), and once more in the order the
 * server returned it, labelled; each pipeline is printed as the stages the template sends (toPipeline), beside system.profile's.
 */
public final class H19 {

    public static void main(String[] args) throws Exception {
        int port = Integer.getInteger("h19.port", 20583);
        try (MongoClient client = MongoClients.create("mongodb://127.0.0.1:" + port + "/tiffinbox")) {
            MongoTemplate t = new MongoTemplate(client, "tiffinbox");
            for (String step : args[0].split(",")) {
                run(t, step);
            }
        }
    }

    static Aggregation untyped(String field) {
        return newAggregation(group("customer").sum(field).as("total"), sort(Sort.Direction.DESC, "total"));
    }

    static void groups(String tag, List<Revenue.Total> r) {
        var sorted = new ArrayList<>(r);
        sorted.sort(Comparator.comparing(Revenue.Total::total).reversed().thenComparing(x -> String.valueOf(x.customer())));
        int sum = 0;
        for (Revenue.Total x : r) sum += x.total();
        System.out.println("PROBE " + tag + ": groups " + r.size() + " · sorted by total, then _id: "
                + sorted.stream().map(x -> x.customer() + " " + x.total()).collect(Collectors.joining(" · ")) + " · their sum " + sum);
        System.out.println("PROBE " + tag + ": the order the server returned: " + r.stream().map(x -> String.valueOf(x.customer())).collect(Collectors.joining(" ")));
    }

    static void stages(String tag, List<Document> p) {
        System.out.println("PROBE " + tag + ": the stages the template sends (toPipeline): " + p.stream().map(Document::toJson).collect(Collectors.joining(", ")));
    }

    static void run(MongoTemplate t, String step) {
        switch (step) {
            case "finder" -> {
                OrderDocuments repo = new MongoRepositoryFactory(t).getRepository(OrderDocuments.class);
                List<OrderDocument> veg = repo.findByMealType("VEG");
                var per = new TreeMap<String, Integer>();
                veg.forEach(o -> per.merge(o.customer(), 1, Integer::sum));
                System.out.println("PROBE finder: the harness's OrderDocuments (MongoRepositoryFactory over the template), findByMealType(\"VEG\"), once -> " + veg.size()
                        + " documents · per customer " + per);
            }
            case "criteria" -> {
                List<OrderDocument> veg = t.find(Query.query(Criteria.where("mealType").is("VEG")), OrderDocument.class);
                System.out.println("PROBE criteria: the harness's MongoTemplate.find(Query.query(Criteria.where(\"mealType\").is(\"VEG\")), OrderDocument.class), once -> " + veg.size() + " documents");
            }
            case "pipeline" -> {
                Aggregation a = untyped("value");
                stages("pipeline", a.toPipeline(Aggregation.DEFAULT_CONTEXT));
                groups("pipeline", t.aggregate(a, "orders", Revenue.Total.class).getMappedResults());
            }
            case "shipped" -> groups("shipped", t.aggregate(newAggregation(OrderDocument.class, group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total")),
                    Revenue.Total.class).getMappedResults());
            case "copy" -> {
                t.remove(new Query(), OrderRenamed.class);
                var copy = new ArrayList<OrderRenamed>();
                for (OrderDocument o : t.findAll(OrderDocument.class)) copy.add(new OrderRenamed(o.id(), o.customer(), o.mealType(), o.day(), o.value()));
                t.insertAll(copy);
                System.out.println("PROBE copy: the harness's copy - orders read (findAll, OrderDocument) " + copy.size() + " · saved into orders_r as OrderRenamed (@Field(\"cust\") on customer) -> count "
                        + t.count(new Query(), OrderRenamed.class));
            }
            case "typedr" -> groups("typedr", t.aggregate(newAggregation(OrderRenamed.class, group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total")),
                    Revenue.Total.class).getMappedResults());
            case "untypedr" -> {
                Aggregation a = untyped("value");
                stages("untypedr", a.toPipeline(Aggregation.DEFAULT_CONTEXT));
                groups("untypedr", t.aggregate(a, "orders_r", Revenue.Total.class).getMappedResults());
            }
            case "summeal" -> {
                Aggregation a = untyped("mealType");
                stages("summeal", a.toPipeline(Aggregation.DEFAULT_CONTEXT));
                groups("summeal", t.aggregate(a, "orders", Revenue.Total.class).getMappedResults());
            }
            default -> throw new IllegalArgumentException("no step " + step);
        }
    }
}
