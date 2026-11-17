package probe.u02;

import net.ttddyy.dsproxy.listener.MethodExecutionContext;
import net.ttddyy.dsproxy.listener.MethodExecutionListener;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * The one statement witness for both modules: the DataSource bean wrapped by datasource-proxy (a BeanPostProcessor, so Flyway,
 * Hibernate, Spring Data JDBC and JdbcTemplate all reach the database through it). While a labelled window is open it keeps the
 * text of every Connection.prepareStatement / prepareCall / createStatement call - the SQL the driver received - and counts them.
 */
@Configuration(proxyBeanMethods = false)
public class Witness {
    static final List<String> SQL = new CopyOnWriteArrayList<>();
    static volatile boolean on;

    static void open() {
        SQL.clear();
        on = true;
    }

    static List<String> close() {
        on = false;
        return List.copyOf(SQL);
    }

    @Bean
    static BeanPostProcessor witnessDataSource() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (!(bean instanceof DataSource ds) || bean instanceof ProxyDataSource) return bean;
                return ProxyDataSourceBuilder.create(ds).name("witness").methodListener(new MethodExecutionListener() {
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
