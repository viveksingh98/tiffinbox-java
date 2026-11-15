package probe.b.ex;

import com.zaxxer.hikari.HikariDataSource;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * The exercise's application: a Spring Boot application with no web server, in its own package, probe.b.ex, with two entities of its
 * own - Diner (a name) and Break (a diner's days off), both on SEQUENCE ids, fifty per call - on tables Hibernate creates in this JVM's
 * own H2 database (ddl-auto=create, never TiffinBox's tables). The runner saves 100 diners in one transaction, each persisted with one
 * break right after it, and prints the rows a second connection reads back and how many times Hibernate called executeBatch: Boot's
 * pool is wrapped in a small counting proxy, as the lesson's harness is. The batch size and the other keys come from the arguments.
 */
@SpringBootApplication
public class ExApp {
    static final AtomicInteger executeBatch = new AtomicInteger();

    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    static void p(Object o) { System.out.println("PROBE " + o); }

    static Object call(Object target, java.lang.reflect.Method m, Object[] a) throws Throwable {
        try { return m.invoke(target, a); } catch (InvocationTargetException e) { throw e.getCause(); }
    }

    @Bean
    static BeanPostProcessor countBatches() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (!(bean instanceof HikariDataSource d)) return bean;
                return Proxy.newProxyInstance(ExApp.class.getClassLoader(), new Class<?>[]{DataSource.class}, (x, m, a) -> {
                    Object r = call(d, m, a);
                    if (!(r instanceof Connection c)) return r;
                    return Proxy.newProxyInstance(ExApp.class.getClassLoader(), new Class<?>[]{Connection.class}, (y, cm, ca) -> {
                        Object s = call(c, cm, ca);
                        if (!cm.getName().equals("prepareStatement")) return s;
                        return Proxy.newProxyInstance(ExApp.class.getClassLoader(), new Class<?>[]{PreparedStatement.class}, (z, sm, sa) -> {
                            if (sm.getName().equals("executeBatch")) executeBatch.incrementAndGet();
                            return call(s, sm, sa);
                        });
                    });
                });
            }
        };
    }

    @Bean
    CommandLineRunner runner(EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm, @Value("${spring.datasource.url}") String url) {
        return args -> {
            p("hibernate.jdbc.batch_size " + emf.getProperties().get("hibernate.jdbc.batch_size") + " · hibernate.order_inserts "
              + emf.getProperties().get("hibernate.order_inserts"));
            executeBatch.set(0);
            new TransactionTemplate(tm).executeWithoutResult(t -> {
                for (int i = 1; i <= 100; i++) {
                    var d = new Diner(String.format("Diner %03d", i));
                    em.persist(d);
                    em.persist(new Break(d, 1 + i % 3));
                }
            });
            try (var c = DriverManager.getConnection(url, "sa", ""); var s = c.createStatement();
                 var r = s.executeQuery("select (select count(*) from diner), (select count(*) from break_day)")) {
                r.next();
                p("rows read back: diner " + r.getInt(1) + " · break_day " + r.getInt(2));
            }
            p("executeBatch " + executeBatch.get());
        };
    }
}

/** The exercise's diner: SEQUENCE ids from diner_seq, fifty per call, known before the INSERT. */
@Entity
@Table(name = "diner")
class Diner {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "diner_seq")
    @SequenceGenerator(name = "diner_seq", sequenceName = "diner_seq", allocationSize = 50)
    Long id;
    String name;

    protected Diner() { }

    Diner(String name) { this.name = name; }
}

/** A diner's break: its own table and its own sequence; the diner is the owning side's foreign key. */
@Entity
@Table(name = "break_day")
class Break {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "break_seq")
    @SequenceGenerator(name = "break_seq", sequenceName = "break_seq", allocationSize = 50)
    Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "diner_id")
    Diner diner;
    int days;

    protected Break() { }

    Break(Diner diner, int days) { this.diner = diner; this.days = days; }
}
