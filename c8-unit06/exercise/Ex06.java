package probe.ex;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import com.tiffinbox.jdbc.PauseRow;
import net.ttddyy.dsproxy.listener.MethodExecutionContext;
import net.ttddyy.dsproxy.listener.MethodExecutionListener;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.Sort;
import org.springframework.data.relational.core.mapping.RelationalMappingContext;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Unit 06's exercise: TiffinBox (both Spring Data modules) with no web server, from the copy whose JdbcNames switches Spring Data
 * JDBC's single-query loading on. The data line first (36 more customers, one 2-day pause each, by JdbcTemplate), then the
 * dashboard through Spring Data JDBC alone - the customers by name and the repository's two sums - counted by a statement witness
 * (datasource-proxy, on the DataSource bean). It prints the count beside the two sums and whether the name order is the JPA
 * side's list (findAllByOrderByNameAsc(), read outside the window).
 */
public final class Ex06 {
    static final List<String> SQL = new CopyOnWriteArrayList<>();
    static volatile boolean on;

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Witness.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        String[] all = new String[args.length + 2];
        System.arraycopy(args, 0, all, 0, args.length);
        all[args.length] = "--spring.main.banner-mode=off";
        all[args.length + 1] = "--logging.level.root=warn";
        var ctx = app.run(all);
        var ds = ctx.getBean(DataSource.class);
        String db;
        try (var c = ds.getConnection()) {
            db = c.getMetaData().getDatabaseProductName() + " " + c.getMetaData().getDatabaseProductVersion().split(" ")[0];
        }
        var jdbc = new JdbcTemplate(ds);
        for (int i = 1; i <= 36; i++) {
            String n = String.format("Customer %02d", i);
            jdbc.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
            jdbc.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
        }
        System.out.println("EX " + db + ": data " + jdbc.queryForObject("select count(*) from customer", Long.class) + " customers · "
                + jdbc.queryForObject("select count(*) from pause", Long.class) + " pauses · single-query loading "
                + ctx.getBean(RelationalMappingContext.class).isSingleQueryLoadingEnabled());
        var agg = ctx.getBean(CustomerAggregates.class);
        List<String> jpaNames = ctx.getBean(CustomerEntityRepository.class).findAllByOrderByNameAsc().stream().map(CustomerEntity::getName).toList();
        on = true;
        List<CustomerRow> page = agg.findAll(Sort.by("name"));
        long revenue = agg.monthRevenue();
        long paused = agg.pausedDays();
        on = false;
        int days = page.stream().mapToInt(c -> c.getPauses().stream().mapToInt(PauseRow::getDays).sum()).sum();
        boolean order = page.stream().map(CustomerRow::getName).toList().equals(jpaNames);
        System.out.println("EX " + db + ": statements " + SQL.size() + " · revenue " + revenue + " · paused days " + paused + " · days by name " + days
                + " · name order = the JPA side's list: " + (order ? "yes" : "no"));
        System.out.println("EX " + db + ": done " + (SQL.size() == 3 && order ? "yes - three statements, the same sums, the JPA side's order" : "no - the page still sends one SELECT per customer for her pauses"));
        ctx.close();
    }

    /** The witness: every Connection.prepareStatement / prepareCall / createStatement while "on" - the SQL the driver received. */
    @Configuration(proxyBeanMethods = false)
    public static class Witness {
        @Bean
        static BeanPostProcessor exWitness() {
            return new BeanPostProcessor() {
                @Override
                public Object postProcessAfterInitialization(Object bean, String name) {
                    if (!(bean instanceof DataSource ds) || bean instanceof ProxyDataSource) return bean;
                    return ProxyDataSourceBuilder.create(ds).name("ex").methodListener(new MethodExecutionListener() {
                        @Override
                        public void beforeMethod(MethodExecutionContext c) {
                        }

                        @Override
                        public void afterMethod(MethodExecutionContext c) {
                            if (!on || !(c.getTarget() instanceof Connection)) return;
                            String m = c.getMethod().getName();
                            if (m.equals("prepareStatement") || m.equals("prepareCall") || m.equals("createStatement")) {
                                Object[] a = c.getMethodArgs();
                                SQL.add(a != null && a.length > 0 ? String.valueOf(a[0]).replaceAll("\\s+", " ").trim() : "(" + m + ")");
                            }
                        }
                    }).build();
                }
            };
        }
    }

    static final Comparator<CustomerRow> BY_NAME = Comparator.comparing(CustomerRow::getName);
}
