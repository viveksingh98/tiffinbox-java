package probe.u18;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.result.UpdateResult;
import com.tiffinbox.web.MenuDay;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

/**
 * Unit 18's harness JVM (the harness's, never TiffinBox's): MongoDB's Java driver and a MongoTemplate built on it, over the unit's
 * MongoDB on 127.0.0.1 (-Dh18.port), database tiffinbox, and the shipped class com.tiffinbox.web.MenuDay (after/'s jar). No web
 * server, no Spring context, no PostgreSQL connection: the PostgreSQL side is SQL this class prints from the same MenuDay.forDays
 * list, which the receipt hands to psql in the harness's own PostgreSQL container. Steps (one per argument, comma-separated):
 *   days          the shipped menu's facts: ids, items per day, names and prices per meal type, the allergens
 *   read          MongoTemplate.findById("day-19", MenuDay.class), once: the items, their allergens
 *   sql4 / sql3   the INSERTs of the four-table and the three-table schema, from MenuDay.forDays(30)
 *   refill        the harness's refill of the collection menu: remove(new Query()) then insertAll(MenuDay.forDays(30))
 *   rename=A:B    one updateMulti with an array filter: every item's allergen A becomes B (items.$[].allergens.$[x], x = A)
 *   nullid        one MenuDay with its id left null, inserted: the id Java reads back (its length; the value never printed)
 */
public final class H18 {

    public static void main(String[] args) throws Exception {
        int port = Integer.getInteger("h18.port", 20573);
        try (MongoClient client = MongoClients.create("mongodb://127.0.0.1:" + port + "/tiffinbox")) {
            MongoTemplate t = new MongoTemplate(client, "tiffinbox");
            for (String step : args[0].split(",")) {
                run(t, step);
            }
        }
    }

    static void run(MongoTemplate t, String step) {
        List<MenuDay> month = MenuDay.forDays(30);
        if (step.equals("days")) {
            System.out.println("PROBE days: MenuDay.forDays(30) -> " + month.size() + " days, ids " + month.get(0).id() + " ... " + month.get(month.size() - 1).id());
            var turn = new LinkedHashMap<String, TreeSet<String>>();
            var price = new LinkedHashMap<String, TreeSet<Integer>>();
            var all = new TreeSet<String>();
            var each = new LinkedHashMap<String, TreeSet<String>>();
            for (MenuDay d : month) {
                for (MenuDay.MenuItem i : d.items()) {
                    turn.computeIfAbsent(i.mealType(), k -> new TreeSet<>()).add(i.name());
                    price.computeIfAbsent(i.mealType(), k -> new TreeSet<>()).add(i.price());
                    all.addAll(i.allergens());
                }
            }
            for (String mt : turn.keySet()) {
                TreeSet<String> common = null;
                for (MenuDay d : month) for (MenuDay.MenuItem i : d.items()) if (i.mealType().equals(mt)) {
                    if (common == null) common = new TreeSet<>(i.allergens()); else common.retainAll(i.allergens());
                }
                each.put(mt, common);
            }
            System.out.println("PROBE days: items per day " + month.stream().mapToInt(d -> d.items().size()).distinct().boxed().toList());
            turn.forEach((k, v) -> System.out.println("PROBE days: " + k + " dishes " + v + " · price " + price.get(k)));
            System.out.println("PROBE days: allergens on the menu, distinct " + all.size() + " " + all);
            each.forEach((k, v) -> System.out.println("PROBE days: the allergen every " + k + " item carries " + v));
        } else if (step.equals("read")) {
            MenuDay m = t.findById("day-19", MenuDay.class);
            int total = 0;
            var distinct = new TreeSet<String>();
            var names = new ArrayList<String>();
            for (MenuDay.MenuItem i : m.items()) {
                total += i.allergens().size();
                distinct.addAll(i.allergens());
                names.add(i.mealType() + " " + i.name() + " " + i.price() + " " + i.allergens());
            }
            System.out.println("PROBE read: the harness's MongoTemplate.findById(\"day-19\", MenuDay.class), once -> one MenuDay, id " + m.id() + " · items " + m.items().size()
                    + " · allergens on its items " + total + " (distinct " + distinct.size() + ")");
            names.forEach(n -> System.out.println("PROBE read:   " + n));
        } else if (step.equals("sql4") || step.equals("sql3")) {
            boolean four = step.equals("sql4");
            String s = four ? "f4" : "f3";
            var ids = new LinkedHashMap<String, Integer>();
            int item = 0;
            var out = new StringBuilder();
            for (MenuDay d : month) {
                out.append("INSERT INTO ").append(s).append(".menu (id) VALUES ('").append(d.id()).append("');\n");
                for (MenuDay.MenuItem i : d.items()) {
                    item++;
                    out.append("INSERT INTO ").append(s).append(".menu_item (id, menu_id, meal_type, name, price) VALUES (").append(item).append(", '")
                            .append(d.id()).append("', '").append(i.mealType()).append("', '").append(i.name()).append("', ").append(i.price()).append(");\n");
                    for (String a : i.allergens()) {
                        if (four) {
                            if (!ids.containsKey(a)) {
                                ids.put(a, ids.size() + 1);
                                out.append("INSERT INTO f4.allergen (id, name) VALUES (").append(ids.get(a)).append(", '").append(a).append("');\n");
                            }
                            out.append("INSERT INTO f4.item_allergen (item_id, allergen_id) VALUES (").append(item).append(", ").append(ids.get(a)).append(");\n");
                        } else {
                            out.append("INSERT INTO f3.item_allergen (item_id, allergen) VALUES (").append(item).append(", '").append(a).append("');\n");
                        }
                    }
                }
            }
            System.out.print(out);
        } else if (step.equals("refill")) {
            t.remove(new Query(), MenuDay.class);
            t.insertAll(month);
            System.out.println("PROBE refill: the harness's remove(new Query()) then insertAll(MenuDay.forDays(30)) -> count " + t.count(new Query(), MenuDay.class));
        } else if (step.startsWith("rename=")) {
            String[] ab = step.substring(7).split(":");
            UpdateResult r = t.updateMulti(new Query(), new Update().set("items.$[].allergens.$[x]", ab[1]).filterArray(Criteria.where("x").is(ab[0])), MenuDay.class);
            System.out.println("PROBE rename: the harness's updateMulti, items.$[].allergens.$[x] = " + ab[1] + " where x = " + ab[0] + " -> matched " + r.getMatchedCount()
                    + ", modified " + r.getModifiedCount());
        } else if (step.equals("nullid")) {
            MenuDay saved = t.insert(new MenuDay(null, MenuDay.forDays(1).get(0).items()));
            System.out.println("PROBE nullid: the harness's insert of a MenuDay with its id left null -> the id Java reads back: a String of length " + saved.id().length()
                    + ", hex digits only " + saved.id().matches("[0-9a-f]+"));
        } else {
            throw new IllegalArgumentException("no step " + step);
        }
    }
}
