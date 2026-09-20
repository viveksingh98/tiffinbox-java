package com.tiffinbox;

import javax.sql.DataSource;
import org.h2.jdbcx.JdbcDataSource;

/**
 * A connection pool is the right object for this lesson because two of them is a REAL cost,
 * not a philosophical one: two pools, two sets of connections, two things to close.
 *
 * <p>JdbcDataSource is a third-party class. You cannot put @Component on it. That is the
 * reason @Bean exists, and this unit says so with this class on screen.
 */
public final class Pool {
    private Pool() { }

    public static DataSource newDataSource(String url) {
        JdbcDataSource ds = new JdbcDataSource();
        ds.setURL(url);
        return ds;
    }
}
