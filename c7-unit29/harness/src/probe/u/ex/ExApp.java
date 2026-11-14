package probe.u.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PersistenceContext;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * The exercise's application: two entities of its own, Diner and Break (a diner's paused days; the tables diner and break, which
 * Hibernate creates in this JVM's own H2), and one service, Page. The runner stores four diners and two breaks - Priya 2 days, Sunil 3
 * - in one transaction, then asks Page for each diner's paused days, by name: every diner, and the days of her breaks summed, read
 * through the lazy collection. No web server, no port; open-in-view is a web setting and plays no part here.
 */
@SpringBootApplication
@EntityScan("probe.u.ex")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    @Bean
    CommandLineRunner run(Page page) {
        return args -> {
            page.store();
            try {
                System.out.println("PROBE the page: " + page.pausedDays());
            } catch (RuntimeException e) {
                System.out.println("PROBE the page threw: " + e.getClass().getName() + ": " + e.getMessage());
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

    @Transactional
    public void store() {
        for (String n : List.of("Ravi", "Meera", "Sunil", "Priya")) em.persist(new Diner(n));
        em.flush();
        var byName = em.createQuery("select d from Diner d", Diner.class).getResultList();
        for (Diner d : byName) {
            if (d.name.equals("Priya")) em.persist(new Break(d, 2));
            if (d.name.equals("Sunil")) em.persist(new Break(d, 3));
        }
    }

    public Map<String, Integer> pausedDays() {
        var out = new LinkedHashMap<String, Integer>();
        for (Diner d : em.createQuery("select d from Diner d order by d.name", Diner.class).getResultList()) {
            out.put(d.name, d.breaks.stream().mapToInt(b -> b.days).sum());
        }
        return out;
    }
}
