package probe.u06;

import net.ttddyy.dsproxy.listener.MethodExecutionContext;
import net.ttddyy.dsproxy.listener.MethodExecutionListener;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

/**
 * The one statement witness for both modules: the DataSource bean wrapped by datasource-proxy (a BeanPostProcessor, so Flyway,
 * Hibernate, Spring Data JDBC and JdbcTemplate all reach the database through it). While a labelled window is open it keeps the
 * text of every Connection.prepareStatement / prepareCall / createStatement call - the SQL the driver received - and counts them.
 * Unit 06: unit 02's witness with two additions - the result sets proxied too, and every ResultSet.next() that returned true
 * while the window is open counted (the rows the driver handed over); and the plant's switch, -Du06.unwired=true, under which
 * the witness skips prepareStatement (S8.15's guard: its count must then differ from Hibernate's).
 */
@Configuration(proxyBeanMethods = false)
public class Witness {
    static final List<String> SQL = new CopyOnWriteArrayList<>();
    static final AtomicLong ROWS = new AtomicLong();
    static volatile boolean on;

    static void open() {
        SQL.clear();
        ROWS.set(0);
        on = true;
    }

    static List<String> close() {
        on = false;
        return List.copyOf(SQL);
    }

    static long rows() {
        return ROWS.get();
    }

    @Bean
    static BeanPostProcessor witnessDataSource() {
        final boolean unwired = Boolean.getBoolean("u06.unwired");
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (!(bean instanceof DataSource ds) || bean instanceof ProxyDataSource) return bean;
                return ProxyDataSourceBuilder.create(ds).name("witness").proxyResultSet().methodListener(new MethodExecutionListener() {
                    @Override
                    public void beforeMethod(MethodExecutionContext c) {
                    }

                    @Override
                    public void afterMethod(MethodExecutionContext c) {
                        if (!on) return;
                        if (c.getTarget() instanceof ResultSet && c.getMethod().getName().equals("next") && Boolean.TRUE.equals(c.getResult())) {
                            ROWS.incrementAndGet();
                            return;
                        }
                        if (!(c.getTarget() instanceof Connection)) return;
                        String m = c.getMethod().getName();
                        if (unwired && m.equals("prepareStatement")) return;
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
