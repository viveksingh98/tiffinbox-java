package probe;

import net.ttddyy.dsproxy.ExecutionInfo;
import net.ttddyy.dsproxy.QueryInfo;
import net.ttddyy.dsproxy.listener.MethodExecutionContext;
import net.ttddyy.dsproxy.listener.MethodExecutionListener;
import net.ttddyy.dsproxy.listener.QueryExecutionListener;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (copied from the S1 probe's Witness.java, trimmed to what unit 04 needs): the statement witness - Course 8's datasource-proxy 1.11.1 recipe
 * (c8-unit05/harness Witness), a BeanPostProcessor wrapping the DataSource bean. While the window is open it counts
 * Connection.prepareStatement / prepareCall / createStatement (Course 8's "prepares") and every executed query (afterQuery),
 * and keeps the executed SQL; writes = executed INSERT / UPDATE / DELETE / MERGE. One window at a time (requests are sent one
 * by one; the race runs read rows by a second client instead).
 */
@Configuration(proxyBeanMethods = false)
public class Witness {
    static final List<String> SQL = new CopyOnWriteArrayList<>();
    static final AtomicInteger PREPARES = new AtomicInteger();
    static volatile boolean on;

    static void open() {
        SQL.clear();
        PREPARES.set(0);
        on = true;
    }

    /** {executions, writes, prepares} for the window just closed. */
    static int[] close() {
        on = false;
        int writes = 0;
        for (String s : SQL) {
            String u = s.stripLeading().toUpperCase(Locale.ROOT);
            if (u.startsWith("INSERT") || u.startsWith("UPDATE") || u.startsWith("DELETE") || u.startsWith("MERGE")) writes++;
        }
        return new int[] {SQL.size(), writes, PREPARES.get()};
    }

    static List<String> sql() {
        return List.copyOf(SQL);
    }

    @Bean
    static BeanPostProcessor witnessDataSource() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (!(bean instanceof DataSource ds) || bean instanceof ProxyDataSource) return bean;
                return ProxyDataSourceBuilder.create(ds).name("witness")
                        .methodListener(new MethodExecutionListener() {
                            @Override
                            public void beforeMethod(MethodExecutionContext c) {
                            }

                            @Override
                            public void afterMethod(MethodExecutionContext c) {
                                if (!on || !(c.getTarget() instanceof Connection)) return;
                                String m = c.getMethod().getName();
                                if (m.equals("prepareStatement") || m.equals("prepareCall") || m.equals("createStatement")) PREPARES.incrementAndGet();
                            }
                        })
                        .listener(new QueryExecutionListener() {
                            @Override
                            public void beforeQuery(ExecutionInfo e, List<QueryInfo> q) {
                            }

                            @Override
                            public void afterQuery(ExecutionInfo e, List<QueryInfo> q) {
                                if (!on) return;
                                for (QueryInfo i : q) SQL.add(i.getQuery().replaceAll("\\s+", " ").trim());
                            }
                        }).build();
            }
        };
    }
}
