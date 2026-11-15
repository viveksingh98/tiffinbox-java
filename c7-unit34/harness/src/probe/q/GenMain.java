package probe.q;

import java.nio.file.Files;
import java.nio.file.Path;

/**
 * The second connection beside a running TiffinBox (anchor B / A / A'), plain JDBC, no Spring: the run's fresh PostgreSQL database
 * (-Dpg.db, the password from the file -Dpg.pwfile names), after TiffinBox's own Database has dropped, created and seeded it. The
 * generator (-Dn customers, -Dk pauses each), then the indexes on pause from the catalogue, then the plan of the lazy collection's
 * statement (-Dq, read off the ways capture's log, its one "?" bound to the id of 'Customer 0001000', read off this connection).
 */
public final class GenMain {
    public static void main(String[] args) throws Exception {
        String pw = Files.readString(Path.of(System.getProperty("pg.pwfile"))).trim();
        H.url = "jdbc:postgresql://127.0.0.1:20138/" + System.getProperty("pg.db") + "?user=sa&password=" + pw;
        H.p("database: " + H.database());
        H.p("before the generator (TiffinBox's seed): customers " + H.count("select count(*) from customer") + " · pauses " + H.count("select count(*) from pause"));
        Gen.run(Integer.getInteger("n"), Integer.getInteger("k"));
        H.exec("analyze pause");
        H.p("analyze pause: done");
        H.p("indexes on pause (pg_indexes): " + H.indexes());
        String q = System.getProperty("q");
        String id = H.rowsOf("select id from customer where name = 'Customer 0001000'").get(0);
        H.p("the id: select id from customer where name = 'Customer 0001000' -> " + id);
        H.p("the lazy collection's statement (read off the ways capture): " + q);
        for (String l : H.plan(q.replace("?", id))) H.p("plan: " + l);
    }
}
