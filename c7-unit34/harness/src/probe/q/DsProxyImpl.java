package probe.q;

import net.ttddyy.dsproxy.listener.logging.SLF4JLogLevel;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;

import javax.sql.DataSource;

/** datasource-proxy 1.11.1 around Boot's pool: every query with its parameters, logged through SLF4J at INFO, under the name tiffinbox.
 *  Loaded by name (Seed) only in the JVM whose class path holds the jar (-Ddsp=true). */
public final class DsProxyImpl {
    public static DataSource wrap(DataSource d) {
        return ProxyDataSourceBuilder.create(d).name("tiffinbox").logQueryBySlf4j(SLF4JLogLevel.INFO).build();
    }
}
