package probe.w;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.NamedEntityGraph;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.Fetch;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.w.ent.BCustomer;
import probe.w.ent.BPause;
import probe.w.ent.TCustomer;
import probe.w.ent.TPause;
import probe.w.repo.FetchRepo;

import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.function.Function;

/**
 * The scenarios, one per JVM (-Ds=...), each after the generator has added -Dn= customers with one pause each: fix (the page's read
 * - every customer by name, her paused days summed - through each fetch plan, in a read-only transaction), dbf (the same read on the
 * anchor's own CustomerEntity, its pauses batched by the run option hibernate.default_batch_fetch_size), paging (a page of ten with
 * a collection fetch), bags (two collections fetched at once). Each step clears the counters first and prints the three witnesses,
 * the rows read and the id lists its statements asked for after it. Every fetch setting in a label is read off the run: the
 * annotation by reflection on the field or the method, the run option off the EntityManagerFactory's properties, the batch size
 * the collection persister holds.
 */
@Component
public class Run implements CommandLineRunner {
    final CustomerEntityRepository repo;
    final FetchRepo fetch;
    final EntityManager em;
    final EntityManagerFactory emf;
    final TransactionTemplate ro;

    Run(CustomerEntityRepository repo, FetchRepo fetch, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm) {
        this.repo = repo; this.fetch = fetch; this.em = em; this.emf = emf;
        this.ro = new TransactionTemplate(tm); this.ro.setReadOnly(true);
        Main.countSql();
    }

    interface Body { Object run() throws Exception; }

    void step(String label, Body b) {
        H.p(">>> " + label);
        H.reset();
        try {
            H.p("result: " + b.run());
        } catch (Throwable e) {
            H.chain("threw", e);
        }
        H.p("counts: " + H.counts());
        H.p("id lists its statements asked for (JDBC proxy): " + H.lists());
        H.p("<<< " + label);
    }

    /** The customers shown: how many, the seeded ones by name with their days, the generated ones counted with their days, each value once. */
    static <T> String shown(Iterable<T> l, Function<T, String> name, Function<T, Integer> days) {
        var seeded = new TreeMap<String, Integer>();
        var gen = new TreeSet<Integer>();
        int g = 0, n = 0;
        for (T e : l) {
            n++;
            if (name.apply(e).startsWith("Customer ")) { g++; gen.add(days.apply(e)); } else seeded.put(name.apply(e), days.apply(e));
        }
        return "customers shown " + n + " · seeded " + seeded + " · generated " + g + ", days each " + gen;
    }

    static int days(CustomerEntity e) { return e.getPauses().stream().mapToInt(PauseEntity::getDays).sum(); }

    String persisterBatch(String role) {
        return String.valueOf(H.sf.unwrap(SessionFactoryImplementor.class).getMappingMetamodel().getCollectionDescriptor(role).getBatchSize());
    }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s");
        int n = Integer.parseInt(System.getProperty("n"));
        H.p("database: " + (H.pg() ? H.rowsOf("select version()").get(0).replaceAll(" on .*$", "") : "H2 " + H.rowsOf("select H2VERSION()").get(0))
            + " | url " + H.shown() + " | JDBC driver " + H.rowsOfDriver());
        H.p("seeded - the second connection reads: customers " + H.rowsOf("select count(*) from customer").get(0) + " · pauses "
            + H.rowsOf("select count(*) from pause").get(0));
        Gen.customers(n);
        switch (s) {
            case "fix" -> fix();
            case "dbf" -> dbf();
            case "paging" -> paging();
            case "bags" -> bags();
            default -> H.p("no scenario " + s);
        }
    }

    void fix() throws Exception {
        H.p("the second connection - customers with no pause: " + H.rowsOf("select c.name from customer c where not exists (select 1 from pause p where p.customer_id = c.id) order by c.name"));
        step("none - findAll(Sort.by(\"name\")) on the anchor's CustomerEntityRepository, then each customer's pauses",
                () -> ro.execute(t -> shown(repo.findAll(Sort.by("name")), CustomerEntity::getName, Run::days)));
        step("left join fetch - select distinct c from CustomerEntity c left join fetch c.pauses order by c.name",
                () -> ro.execute(t -> shown(fetch.leftJoinFetch(), CustomerEntity::getName, Run::days)));
        step("inner join fetch - select distinct c from CustomerEntity c join fetch c.pauses order by c.name",
                () -> ro.execute(t -> shown(fetch.innerJoinFetch(), CustomerEntity::getName, Run::days)));
        var g = CustomerEntityRepository.class.getMethod("findAllByOrderByNameAsc").getAnnotation(EntityGraph.class);
        step("@EntityGraph(attributePaths = \"" + String.join("\", \"", g.attributePaths()) + "\") - on the derived findAllByOrderByNameAsc() of the anchor's CustomerEntityRepository (read off the method)",
                () -> ro.execute(t -> shown(repo.findAllByOrderByNameAsc(), CustomerEntity::getName, Run::days)));
        var ng = BCustomer.class.getAnnotation(NamedEntityGraph.class);
        step("@NamedEntityGraph(name = \"" + ng.name() + "\") as a fetchgraph hint - its attribute node \"" + ng.attributeNodes()[0].value()
             + "\" (read off the class), as jakarta.persistence.fetchgraph on select c from BCustomer c order by c.name",
                () -> ro.execute(t -> shown(em.createQuery("select c from BCustomer c order by c.name", BCustomer.class)
                        .setHint("jakarta.persistence.fetchgraph", em.getEntityGraph(ng.name())).getResultList(),
                        BCustomer::getName, c -> c.getPauses().stream().mapToInt(BPause::getDays).sum())));
        int size = BCustomer.class.getDeclaredField("pauses").getAnnotation(BatchSize.class).size();
        step("@BatchSize(size = " + size + ") - on BCustomer.pauses (read off the field; the collection persister's batch size "
             + persisterBatch("probe.w.ent.BCustomer.pauses") + "), select c from BCustomer c order by c.name, then each customer's pauses",
                () -> ro.execute(t -> shown(em.createQuery("select c from BCustomer c order by c.name", BCustomer.class).getResultList(),
                        BCustomer::getName, c -> c.getPauses().stream().mapToInt(BPause::getDays).sum())));
        var mode = TCustomer.class.getDeclaredField("pauses").getAnnotation(Fetch.class).value();
        step("@Fetch(FetchMode." + mode + ") - on TCustomer.pauses (read off the field), select c from TCustomer c order by c.name, then each customer's pauses",
                () -> ro.execute(t -> shown(em.createQuery("select c from TCustomer c order by c.name", TCustomer.class).getResultList(),
                        TCustomer::getName, c -> c.getPauses().stream().mapToInt(TPause::getDays).sum())));
        step("the DTO group-by projection - select new Row(c.name, coalesce(sum(p.days), 0)) from CustomerEntity c left join c.pauses p group by c.id, c.name order by c.name",
                () -> ro.execute(t -> shown(fetch.pausedDaysPerCustomer(), Row::name, r -> Math.toIntExact(r.days()))));
    }

    void dbf() {
        Object v = emf.getProperties().get("hibernate.default_batch_fetch_size");
        step("default_batch_fetch_size=" + v + " - a run option on the anchor's CustomerEntity, no annotation (read off the EntityManagerFactory's properties; "
             + "the collection persister's batch size " + persisterBatch("com.tiffinbox.CustomerEntity.pauses") + "), findAll(Sort.by(\"name\")), then each customer's pauses",
                () -> ro.execute(t -> shown(repo.findAll(Sort.by("name")), CustomerEntity::getName, Run::days)));
    }

    String page(java.util.List<CustomerEntity> l) {
        return "customers shown " + l.size() + " · first " + l.get(0).getName() + " · last " + l.get(l.size() - 1).getName()
               + " · their pauses " + l.stream().mapToInt(c -> c.getPauses().size()).sum();
    }

    void paging() {
        Body jf = () -> ro.execute(t -> page(em.createQuery("select c from CustomerEntity c left join fetch c.pauses order by c.name", CustomerEntity.class)
                .setFirstResult(0).setMaxResults(10).getResultList()));
        step("left join fetch + setMaxResults(10) - select c from CustomerEntity c left join fetch c.pauses order by c.name, one pause each", jf);
        step("@EntityGraph + PageRequest.of(0, 10, Sort.by(\"name\")) - findAllBy(Pageable) with @EntityGraph(attributePaths = \"pauses\")", () -> ro.execute(t -> {
            var pg = fetch.findAllBy(PageRequest.of(0, 10, Sort.by("name")));
            return page(pg.getContent()) + " · of total " + pg.getTotalElements();
        }));
        step("no fetch + PageRequest.of(0, 10, Sort.by(\"name\")) - findAll(Pageable) on the anchor's CustomerEntityRepository, then each customer's pauses", () -> ro.execute(t -> {
            var pg = repo.findAll(PageRequest.of(0, 10, Sort.by("name")));
            return page(pg.getContent()) + " · of total " + pg.getTotalElements();
        }));
        Gen.more(2);
        step("left join fetch + setMaxResults(10) - select c from CustomerEntity c left join fetch c.pauses order by c.name, three pauses each", jf);
    }

    void bags() {
        Seed.orders();
        H.p("the second connection - each customer's pauses and orders (meal_order, the harness's table): "
            + H.rowsOf("select c.name, (select count(*) from pause p where p.customer_id = c.id), (select count(*) from meal_order o where o.customer_id = c.id) from customer c order by c.name"));
        step("two Lists fetched - BCustomer.pauses and BCustomer.orders: select c from BCustomer c left join fetch c.pauses left join fetch c.orders", () -> ro.execute(t -> {
            var q = em.createQuery("select c from BCustomer c left join fetch c.pauses left join fetch c.orders", BCustomer.class);
            H.p("createQuery returned");
            return q.getResultList().size();
        }));
        step("two Sets fetched, with distinct - TCustomer.pauses and TCustomer.orders: select distinct c from TCustomer c left join fetch c.pauses left join fetch c.orders order by c.name",
                () -> ro.execute(t -> {
                    var l = em.createQuery("select distinct c from TCustomer c left join fetch c.pauses left join fetch c.orders order by c.name", TCustomer.class).getResultList();
                    return "customers shown " + l.size() + " · " + l.stream().map(c -> c.getName() + " pauses " + c.getPauses().size() + " orders " + c.getOrders().size()).toList();
                }));
        step("two Sets fetched, without distinct - select c from TCustomer c left join fetch c.pauses left join fetch c.orders order by c.name",
                () -> ro.execute(t -> {
                    var l = em.createQuery("select c from TCustomer c left join fetch c.pauses left join fetch c.orders order by c.name", TCustomer.class).getResultList();
                    return "customers shown " + l.size() + " · " + l.stream().map(c -> c.getName() + " pauses " + c.getPauses().size() + " orders " + c.getOrders().size()).toList();
                }));
    }
}
