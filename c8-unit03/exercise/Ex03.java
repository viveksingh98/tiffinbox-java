package probe.ex;

import com.tiffinbox.jdbc.CustomerAggregates;
import net.ttddyy.dsproxy.listener.MethodExecutionContext;
import net.ttddyy.dsproxy.listener.MethodExecutionListener;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Unit 03's exercise: TiffinBox (both Spring Data modules) with no web server, on H2 in memory. Sunil's aggregate is loaded
 * through Spring Data JDBC and saved unchanged; a statement witness (datasource-proxy, on the DataSource bean) keeps the text of
 * every statement the driver received during that save. The test prints each statement, then the count it was asked for, then
 * Sunil's pause ids and version read back by JdbcTemplate - a second client - before and after.
 */
public final class Ex03 {
    static final List<String> SQL = new CopyOnWriteArrayList<>();
    static volatile boolean on;

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Witness.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        var ctx = app.run("--spring.main.banner-mode=off", "--logging.level.root=warn");
        var jdbc = new JdbcTemplate(ctx.getBean(DataSource.class));
        var agg = ctx.getBean(CustomerAggregates.class);
        System.out.println("EX before, read back by JdbcTemplate (a second client): " + row(jdbc));
        var sunil = agg.findByName("Sunil").orElseThrow();
        System.out.println("EX Sunil loaded: pauses " + sunil.getPauses().size() + " · nothing changed in Java");
        on = true;
        agg.save(sunil);
        on = false;
        SQL.stream().sorted().forEach(q -> System.out.println("EX statement: " + q));
        long count = SQL.stream().filter(q -> q.startsWith("SELECT")).count();
        System.out.println("EX statement count: " + count);
        System.out.println("EX after, read back by JdbcTemplate (a second client): " + row(jdbc));
        System.out.println("EX done: " + (count == SQL.size() && count > 0 ? "yes - the count is every statement of the save" : "no - the count misses statements the save sent"));
        ctx.close();
    }

    static String row(JdbcTemplate jdbc) {
        return "Sunil pauses " + String.join(" ", jdbc.query("select p.id, p.days from pause p join customer c on c.id = p.customer_id where c.name = 'Sunil' order by p.id",
                (rs, i) -> rs.getLong(1) + ":" + rs.getInt(2))) + " · version " + jdbc.queryForObject("select version from customer where name = 'Sunil'", Long.class);
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
}
