package probe.s;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.hibernate.annotations.SoftDelete;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.support.TransactionTemplate;
import probe.u.U;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Unit 38, soft deletes, on the harness's own tables (create-drop on a throwaway database): Hibernate 7.4's @SoftDelete on s_customer,
 * a pause that must have a customer (s_pause: LAZY, optional = false - the anchor's own PauseEntity shape), the same pause table read
 * by an EAGER optional mapping (read only), and the older pair @SQLDelete + @SQLRestriction on o_customer. Every statement kind is a
 * labelled step; after the two removes the JVM pauses and the receipt reads the rows by a second connection. Entities carry explicit
 * names (nested classes), and every association is read through its getter - a proxy's field read directly bypasses its loading.
 */
@SpringBootApplication
@EntityScan("probe.s")
@EnableJpaRepositories(basePackageClasses = SMain.class, considerNestedRepositories = true)
public class SMain {

    @Entity(name = "SCustomer")
    @Table(name = "s_customer")
    @SoftDelete
    public static class SCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
        @OneToMany(mappedBy = "customer") List<SPause> pauses = new ArrayList<>();
        protected SCustomer() {}
        SCustomer(String n) { name = n; }
        public Long getId() { return id; }
        public String getName() { return name; }
        public List<SPause> getPauses() { return pauses; }
    }

    @Entity(name = "SPause")
    @Table(name = "s_pause")
    public static class SPause {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "customer_id") SCustomer customer;
        int days;
        protected SPause() {}
        SPause(SCustomer c, int d) { customer = c; days = d; }
        public Long getId() { return id; }
        public SCustomer getCustomer() { return customer; }
    }

    /** The same pause table, its customer EAGER and optional (the default) - read only. */
    @Entity(name = "SPauseEager")
    @Table(name = "s_pause")
    @Immutable
    public static class SPauseEager {
        @Id Long id;
        @ManyToOne @JoinColumn(name = "customer_id", insertable = false, updatable = false) SCustomer customer;
        int days;
        protected SPauseEager() {}
        public SCustomer getCustomer() { return customer; }
    }

    @Entity(name = "OCustomer")
    @Table(name = "o_customer")
    @SQLDelete(sql = "update o_customer set deleted = true where id = ?")
    @SQLRestriction("deleted = false")
    public static class OCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
        boolean deleted;
        protected OCustomer() {}
        OCustomer(String n) { name = n; }
        public String getName() { return name; }
    }

    public interface SRepo extends JpaRepository<SCustomer, Long> {
        Optional<SCustomer> findByName(String name);
        @Query("select c from SCustomer c order by c.name") List<SCustomer> jpql();
        @Query(value = "select * from s_customer order by name", nativeQuery = true) List<SCustomer> nativeAll();
    }
    public interface PRepo extends JpaRepository<SPause, Long> {
        @Query("select p from SPause p join fetch p.customer order by p.id") List<SPause> withCustomer();
    }
    public interface ERepo extends JpaRepository<SPauseEager, Long> {}
    public interface ORepo extends JpaRepository<OCustomer, Long> {}

    static List<String> names(List<SCustomer> l) {
        return l.stream().map(SCustomer::getName).toList();
    }

    public static void main(String[] args) throws Exception {
        U.run(SMain.class, args, ctx -> {
            var tx = ctx.getBean(TransactionTemplate.class);
            var s = ctx.getBean(SRepo.class);
            var p = ctx.getBean(PRepo.class);
            var e = ctx.getBean(ERepo.class);
            var o = ctx.getBean(ORepo.class);
            U.step("seed - Ravi, Meera, Sunil in both tables; a pause for Meera, then one for Sunil", c -> tx.executeWithoutResult(st -> {
                var ravi = s.save(new SCustomer("Ravi"));
                var meera = s.save(new SCustomer("Meera"));
                var sunil = s.save(new SCustomer("Sunil"));
                var pm = p.save(new SPause(meera, 2));
                var ps = p.save(new SPause(sunil, 3));
                System.out.println("PROBE ids: Ravi " + ravi.getId() + ", Meera " + meera.getId() + ", Sunil " + sunil.getId() + " · Meera's pause " + pm.getId() + ", Sunil's " + ps.getId());
                o.save(new OCustomer("Ravi"));
                o.save(new OCustomer("Meera"));
                o.save(new OCustomer("Sunil"));
            }), ctx);
            U.step("remove - Meera, @SoftDelete", c -> tx.executeWithoutResult(st -> s.delete(s.findByName("Meera").orElseThrow())), ctx);
            U.step("remove - Meera, @SQLDelete + @SQLRestriction", c -> tx.executeWithoutResult(st ->
                    o.delete(o.findAll().stream().filter(x -> x.getName().equals("Meera")).findFirst().orElseThrow())), ctx);
            U.pause("removed");
            U.step("kind findAll", c -> System.out.println("PROBE result: " + tx.execute(st -> names(s.findAll(Sort.by("name"))))), ctx);
            U.step("kind findById", c -> System.out.println("PROBE result: findById(Meera's id) present " + tx.execute(st -> s.findById(2L).isPresent())), ctx);
            U.step("kind findByName", c -> System.out.println("PROBE result: findByName(Meera) present " + tx.execute(st -> s.findByName("Meera").isPresent())), ctx);
            U.step("kind jpql", c -> System.out.println("PROBE result: " + tx.execute(st -> names(s.jpql()))), ctx);
            U.step("kind count", c -> System.out.println("PROBE result: " + s.count()), ctx);
            U.step("kind page", c -> System.out.println("PROBE result: " + tx.execute(st -> {
                var pg = s.findAll(PageRequest.of(0, 2, Sort.by("name")));
                return "content " + names(pg.getContent()) + " · total " + pg.getTotalElements();
            })), ctx);
            U.step("kind joinFetch", c -> System.out.println("PROBE result: " + tx.execute(st ->
                    p.withCustomer().stream().map(x -> x.getId() + ":" + x.getCustomer().getName()).toList())), ctx);
            U.step("kind oldPair", c -> System.out.println("PROBE result: " + tx.execute(st -> o.findAll(Sort.by("name")).stream().map(OCustomer::getName).toList())), ctx);
            U.step("bypass - a native query", c -> System.out.println("PROBE result: " + tx.execute(st -> names(s.nativeAll()))), ctx);
            U.step("leak 2 - the pause of the removed customer: findById(1)", c -> System.out.println("PROBE result: " + tx.execute(st -> p.findById(1L))), ctx);
            U.step("leak 2 - the pauses: findAll, count", c -> System.out.println("PROBE result: findAll ids "
                    + tx.execute(st -> p.findAll(Sort.by("id")).stream().map(SPause::getId).toList()) + " · count() " + p.count()), ctx);
            U.step("leak 2 - the first pause from findAll, its customer's name", c -> System.out.println("PROBE result: "
                    + tx.execute(st -> p.findAll(Sort.by("id")).get(0).getCustomer().getName())), ctx);
            U.step("eager - the same pause through an EAGER optional mapping: findById(1)", c -> System.out.println("PROBE result: "
                    + tx.execute(st -> e.findById(1L).map(x -> "present, its customer " + x.getCustomer()).orElse("absent"))), ctx);
            U.step("collection - Sunil's pauses", c -> System.out.println("PROBE result: " + tx.execute(st -> s.findByName("Sunil").orElseThrow().getPauses().size())), ctx);
            U.step("leak 1 - a new Meera saved", c -> tx.executeWithoutResult(st -> s.saveAndFlush(new SCustomer("Meera"))), ctx);
        });
    }
}
