package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.PauseEntity;
import probe.map.many.ListFan;
import probe.map.many.Meal;
import probe.map.many.OrderedFan;
import probe.map.many.SetFan;
import probe.map.middle.SubCustomer;
import probe.map.middle.Subscription;
import probe.map.one.Wallet;
import probe.map.one.WalletCustomer;

import jakarta.persistence.EntityManagerFactory;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

/**
 * The one-to-one and many-to-many lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version
 * first (R.222), then its database line, then PROBE lines; an exception ends the run with its first line and its distinct causes, exit 1.
 *   one SIDE FILE    WalletCustomer (the owning side, wallet_id) and Wallet (mappedBy), both LAZY: Hibernate's DDL written to FILE and
 *                    run on this throwaway database; Ravi and his wallet persisted; then, in a new EntityManager, SIDE owner (A: find
 *                    the customer) or inverse (B: find the wallet) - the SQL, the counters, isLoaded and the class of the other side
 *   many KIND FILE   KIND list (ListFan), set (SetFan) or ordered (OrderedFan, @OrderColumn): Hibernate's DDL written to FILE and run;
 *                    Ravi with three favourite meals - Platter, Salad, Soup; then, in a new transaction, Salad removed - the SQL,
 *                    the counters, what each executeUpdate returned, the join table before and after by a second connection
 *   middle FILE      Subscription (customer, meal, mealsPerDay, since): Hibernate's DDL written to FILE and run; a meal, a customer
 *                    and one subscription persisted; the row by a second connection
 *   ex CLASS         the exercise: CLASS (probe.map.ex.ExFan, compiled by the exercise) - Kavya with three favourite meals, then
 *                    Salad removed; what each executeUpdate returned; the join table by a second connection
 *   xcheck FILE      Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "one" -> one(a[1], a[2]);
                case "many" -> many(a[1], a[2]);
                case "middle" -> middle(a[1]);
                case "ex" -> ex(a[1]);
                case "xcheck" -> xcheck(a[1]);
                default -> throw new IllegalArgumentException("no scenario " + a[0]);
            }
        } catch (Throwable e) {
            err(e instanceof java.lang.reflect.InvocationTargetException i ? i.getCause() : e);
            System.out.flush();
            System.exit(1);
        }
        System.out.flush();
        System.exit(0);
    }

    static Map<String, Object> script(String file) {
        return props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file);
    }

    static void one(String side, String file) throws Exception {
        var emf = emf("u10one", script(file), WalletCustomer.class, Wallet.class);
        p("the EntityManagerFactory was built; the script written, and run on this database");
        Long[] ids = new Long[2];
        tx(emf, em -> {
            var w = new Wallet(500);
            var c = new WalletCustomer("Ravi", w);
            em.persist(c);
            p("persisted: Ravi and his wallet of 500 (cascade PERSIST)");
            ids[0] = c.getId();
            ids[1] = w.getId();
        });
        p("wallet_customer, read by a second connection (id | name | wallet_id): " + sql("select id, name, wallet_id from wallet_customer order by id")
                + " | wallet (id | balance): " + sql("select id, balance from wallet order by id"));
        reset(emf);
        var em = emf.createEntityManager();
        if (side.equals("owner")) {
            p("A - the owning side: find(WalletCustomer.class, " + ids[0] + ") in a new EntityManager");
            var c = em.find(WalletCustomer.class, ids[0]);
            p("after find()");
            p(counted(emf));
            p(counts());
            p("isLoaded(customer, \"wallet\") (emf.getPersistenceUnitUtil()): " + loaded(emf, c, "wallet"));
            p("the wallet's class: " + c.getWallet().getClass().getName());
        } else {
            p("B - the inverse side: find(Wallet.class, " + ids[1] + ") in a new EntityManager (mappedBy, fetch = LAZY written)");
            var w = em.find(Wallet.class, ids[1]);
            p("after find()");
            p(counted(emf));
            p(counts());
            p("isLoaded(wallet, \"customer\") (emf.getPersistenceUnitUtil()): " + loaded(emf, w, "customer"));
            p("the customer's class: " + w.getCustomer().getClass().getName());
        }
        em.close();
        emf.close();
    }

    static void many(String kind, String file) throws Exception {
        Class<?> k = switch (kind) {
            case "list" -> ListFan.class;
            case "set" -> SetFan.class;
            case "ordered" -> OrderedFan.class;
            default -> throw new IllegalArgumentException("no kind " + kind);
        };
        var emf = emf("u10" + kind, script(file), k, Meal.class);
        p("the EntityManagerFactory was built; the script written, and run on this database");
        String t = kind + "_fan_favourites";
        Object[] ids = new Object[2];
        tx(emf, em -> {
            var platter = new Meal("Platter");
            var salad = new Meal("Salad");
            var soup = new Meal("Soup");
            em.persist(platter); em.persist(salad); em.persist(soup);
            Object fan = fan(kind, "Ravi");
            favourites(fan).add(platter); favourites(fan).add(salad); favourites(fan).add(soup);
            em.persist(fan);
            p("persisted: Platter, Salad, Soup, and Ravi with all three as favourites");
            ids[0] = emf.getPersistenceUnitUtil().getIdentifier(fan);
            ids[1] = salad.getId();
        });
        p(t + ", read by a second connection (" + sql("select count(*) from " + t).get(0) + " rows): " + sql("select * from " + t + " order by 1, 2"));
        reset(emf);
        tx(emf, em -> {
            Object fan = em.find(k, ids[0]);
            var favs = favourites(fan);
            p("Ravi's favourites: " + names(favs));
            var salad = em.find(Meal.class, ids[1]);
            p("before remove(Salad)");
            favs.remove(salad);
            p("after remove(Salad): " + names(favs));
        });
        p(counted(emf));
        p(counts());
        written();
        p(t + ", read by a second connection (" + sql("select count(*) from " + t).get(0) + " rows): " + sql("select * from " + t + " order by 1, 2"));
        var em = emf.createEntityManager();
        p("read in a new EntityManager: Ravi's favourites " + names(favourites(em.find(k, ids[0]))));
        em.close();
        emf.close();
    }

    static Object fan(String kind, String name) {
        return switch (kind) {
            case "list" -> new ListFan(name);
            case "set" -> new SetFan(name);
            default -> new OrderedFan(name);
        };
    }

    @SuppressWarnings("unchecked")
    static Collection<Meal> favourites(Object fan) {
        try { return (Collection<Meal>) fan.getClass().getMethod("getFavourites").invoke(fan); }
        catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
    }

    static String names(Collection<?> meals) {
        var out = new ArrayList<String>();
        for (var m : meals) {
            try { out.add((String) m.getClass().getMethod("getName").invoke(m)); }
            catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
        }
        if (!(meals instanceof java.util.List)) java.util.Collections.sort(out);
        return out.toString();
    }

    static void middle(String file) throws Exception {
        var emf = emf("u10middle", script(file), Subscription.class, SubCustomer.class, Meal.class);
        p("the EntityManagerFactory was built; the script written, and run on this database");
        reset(emf);
        tx(emf, em -> {
            var platter = new Meal("Platter");
            var ravi = new SubCustomer("Ravi");
            em.persist(platter); em.persist(ravi);
            em.persist(new Subscription(ravi, platter, 2, LocalDate.of(2026, 11, 4)));
            p("persisted: Platter, Ravi, and Ravi's subscription - 2 meals a day of Platter, since 2026-11-04");
        });
        p(counted(emf));
        p(counts());
        p("subscription, read by a second connection (id | customer_id | meal_id | meals_per_day | since): "
                + sql("select id, customer_id, meal_id, meals_per_day, since from subscription order by id"));
        emf.close();
    }

    static void ex(String cls) throws Exception {
        var k = Class.forName("probe.map." + cls);
        var mk = Class.forName("probe.map.ex.ExMeal");
        var emf = emf("u10ex", Map.of(), k, mk);
        Object[] ids = new Object[2];
        tx(emf, em -> {
            try {
                Object fan = k.getConstructor(String.class).newInstance("Kavya");
                @SuppressWarnings("unchecked") var favs = (Collection<Object>) k.getMethod("getFavourites").invoke(fan);
                Object salad = null;
                for (var n : new String[]{"Platter", "Salad", "Soup"}) {
                    Object m = mk.getConstructor(String.class).newInstance(n);
                    em.persist(m); favs.add(m);
                    if (n.equals("Salad")) salad = m;
                }
                em.persist(fan);
                ids[0] = emf.getPersistenceUnitUtil().getIdentifier(fan);
                ids[1] = emf.getPersistenceUnitUtil().getIdentifier(salad);
            } catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
        });
        reset(emf);
        tx(emf, em -> {
            try {
                Object fan = em.find(k, ids[0]);
                var favs = (Collection<?>) k.getMethod("getFavourites").invoke(fan);
                favs.size();
                favs.remove(em.find(mk, ids[1]));
            } catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
        });
        p("Salad removed from Kavya's favourites - executeUpdate calls: " + execUpdate);
        written();
        p("ex_fan_favourites, read by a second connection: " + sql("select count(*) from ex_fan_favourites").get(0) + " rows");
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u10xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
