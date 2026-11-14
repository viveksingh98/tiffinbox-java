package probe.v.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PersistenceContext;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * The exercise's application: two entities of its own, Diner and Break (a diner's paused days; the tables diner and break, which
 * Hibernate creates in this JVM's own H2), and one service, Page. The runner stores four diners - Priya with a break of 2 days, Sunil
 * 3 - and 6 more, reads the page (every diner by name, her breaks summed, read through the lazy collection, in a read-only
 * transaction), and prints how many diners it read and the page's count; then it stores diners up to 36 more and does the same.
 * Hibernate's statistics are on (generate_statistics, a run option) and cleared before each read. No web server, no port.
 */
@SpringBootApplication
@EntityScan("probe.v.ex")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    /** The page's count, from Hibernate's statistics. */
    static long count(Statistics s) {
        return s.getQueryExecutionCount();
    }

    @Bean
    CommandLineRunner run(Page page, EntityManagerFactory emf) {
        return args -> {
            Statistics s = emf.unwrap(SessionFactory.class).getStatistics();
            page.seed();
            for (int more : new int[]{6, 36}) {
                page.topUp(more);
                s.clear();
                int diners = page.pausedDays().size();
                System.out.println("PROBE diners " + diners + " · the page's count: " + count(s));
            }
        };
    }
}

@Entity
class Diner {
    @Id @GeneratedValue Long id;
    String name;
    @OneToMany(mappedBy = "diner") List<Break> breaks = new ArrayList<>();

    Diner() {}
    Diner(String name) { this.name = name; }
}

@Entity
class Break {
    @Id @GeneratedValue Long id;
    int days;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "diner_id") Diner diner;

    Break() {}
    Break(Diner diner, int days) { this.diner = diner; this.days = days; }
}

@Service
class Page {
    @PersistenceContext EntityManager em;
    int made;

    @Transactional
    public void seed() {
        for (String n : List.of("Ravi", "Meera", "Sunil", "Priya")) {
            var d = new Diner(n);
            em.persist(d);
            if (n.equals("Priya")) em.persist(new Break(d, 2));
            if (n.equals("Sunil")) em.persist(new Break(d, 3));
        }
    }

    /** More diners, "Diner 0000001" ..., until this many have been made. */
    @Transactional
    public void topUp(int upTo) {
        while (made < upTo) em.persist(new Diner(String.format("Diner %07d", ++made)));
    }

    @Transactional(readOnly = true)
    public Map<String, Integer> pausedDays() {
        var out = new TreeMap<String, Integer>();
        for (Diner d : em.createQuery("select d from Diner d order by d.name", Diner.class).getResultList()) {
            out.put(d.name, d.breaks.stream().mapToInt(b -> b.days).sum());
        }
        return out;
    }
}
