package probe.ex;

import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.jdbc.CustomerAggregates;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.data.domain.Sort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.orm.jpa.EntityManagerFactoryUtils;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;

/**
 * Unit 01's exercise: TiffinBox (both Spring Data modules) with no web server, on H2 in memory. The data line first (36 more
 * customers, one 2-day pause each, by JdbcTemplate), then ONE transaction: the dashboard's customer read, Ravi's meals changed in
 * Java - no save() - and the commit. The check is the row, read back by JdbcTemplate (a second client) after the commit, and
 * Hibernate's entityUpdateCount; never which API did the read.
 */
public final class Ex01 {
    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        app.setWebApplicationType(WebApplicationType.NONE);
        var ctx = app.run("--spring.main.banner-mode=off", "--logging.level.root=warn", "--spring.jpa.properties.hibernate.generate_statistics=true");
        var jdbc = new JdbcTemplate(ctx.getBean(DataSource.class));
        var jpa = ctx.getBean(CustomerEntityRepository.class);
        var agg = ctx.getBean(CustomerAggregates.class);
        var emf = ctx.getBean(EntityManagerFactory.class);
        var st = emf.unwrap(SessionFactory.class).getStatistics();
        for (int i = 1; i <= 36; i++) {
            String n = String.format("Customer %02d", i);
            jdbc.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
            jdbc.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
        }
        System.out.println("EX data (JdbcTemplate): customers " + jdbc.queryForObject("select count(*) from customer", Long.class)
                + " · pauses " + jdbc.queryForObject("select count(*) from pause", Long.class));
        System.out.println("EX before: " + row(jdbc));
        st.clear();
        var tx = new TransactionTemplate(ctx.getBean(PlatformTransactionManager.class));
        tx.setReadOnly(false);
        tx.executeWithoutResult(s -> {
            var all = jpa.findAllByOrderByNameAsc();
            var held = EntityManagerFactoryUtils.getTransactionalEntityManager(emf).unwrap(Session.class).getStatistics().getEntityCount();
            System.out.println("EX the read: customers " + all.size() + " · the persistence context holds entities " + held);
            var ravi = all.stream().filter(c -> c.getName().equals("Ravi")).findFirst().orElseThrow();
            ravi.setMealsPerDay(ravi.getMealsPerDay() + 1);
            System.out.println("EX changed in Java, no save(): Ravi meals " + ravi.getMealsPerDay());
        });
        System.out.println("EX the commit: flushCount " + st.getFlushCount() + " · entityUpdateCount " + st.getEntityUpdateCount());
        String after = row(jdbc);
        System.out.println("EX after, read back by JdbcTemplate (a second client): " + after);
        System.out.println("EX done: " + (st.getEntityUpdateCount() == 0 && after.equals(row0) ? "yes - the commit wrote nothing" : "no - the commit wrote the row"));
        ctx.close();
    }

    static String row0;

    static String row(JdbcTemplate jdbc) {
        String r = "Ravi meals " + jdbc.queryForObject("select meals_per_day from customer where name = 'Ravi'", Integer.class)
                + " · version " + jdbc.queryForObject("select version from customer where name = 'Ravi'", Long.class);
        if (row0 == null) row0 = r;
        return r;
    }
}
