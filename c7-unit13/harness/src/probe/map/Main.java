package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.PauseEntity;

import jakarta.persistence.EntityManagerFactory;

import java.lang.reflect.Field;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TimeZone;

import org.hibernate.engine.spi.SessionFactoryImplementor;

import probe.map.log.OrderLog;

/**
 * The dates-and-zones lesson's harness: java ... probe.map.Main SCENARIO ARGS (-Ddb=h2, the default; -Ddb=h2file - H2 in the file
 * db/NAME under the JVM's working directory, for two JVMs; -Ddb=pg with -Dpg.port= and -Dpg.passfile=; -Ddb.keep=true - the reader:
 * the writer's database opened as it is). The JVM's zone comes from -Duser.timezone on its java line and is printed first, with the
 * two Hibernate settings a run may pass: -Dtzs= (hibernate.timezone.default_storage) and -Djtz= (hibernate.jdbc.time_zone); after a
 * factory is built, Hibernate's own reading of both (SessionFactoryOptions). Every scenario prints Hibernate's version first (R.222),
 * then its database line, then PROBE lines. An exception ends the run: its first line and its distinct causes are printed, and the
 * JVM exits 1. The moment is Course 2's literal, 2026-09-14T18:30:00Z, never now(); a gap is printed with Course 2's own label.
 *   ddl NAME FILE      Hibernate's DDL for probe.map.log.OrderLog written to FILE and run on the database NAME (a fresh one)
 *   write NAME         one OrderLog written to the database NAME (a fresh one): the moment as each of its five fields holds it
 *   read NAME          the writer's database opened as it is (no schema step): the row by a second connection, then by a new
 *                      EntityManager - each field read back, as an instant, and how far it is from the moment written
 *   offset NAME        write, then read in a new EntityManager of the same JVM: the OffsetDateTime and ZonedDateTime read back
 *   ex write|read NAME the exercise's probe.map.ex.OrderLog (compiled by the exercise): its placedAt written, or read back
 *   xcheck FILE        Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    static final Instant PLACED = Instant.parse("2026-09-14T18:30:00Z");       // Course 2's literal, never now()
    static final String STORED = "stored instant                   : ";       // Course 2's labels, as its Connect.java prints them
    static final String OFFBY = "off by                           : ";
    static final ZoneOffset KOLKATA_OFFSET = ZoneOffset.ofHoursMinutes(5, 30);

    public static void main(String[] a) {
        boolean failed = false;
        try {
            version();
            p("JVM zone (TimeZone.getDefault().getID()): " + TimeZone.getDefault().getID() + " | -Dtzs (hibernate.timezone.default_storage): "
                    + System.getProperty("tzs", "(not set)") + " | -Djtz (hibernate.jdbc.time_zone): " + System.getProperty("jtz", "(not set)"));
            switch (a[0]) {
                case "ddl" -> ddl(a[1], a[2]);
                case "write" -> write(a[1]);
                case "read" -> read(a[1]);
                case "offset" -> offset(a[1]);
                case "ex" -> ex(a[1], a[2]);
                case "xcheck" -> xcheck(a[1]);
                default -> throw new IllegalArgumentException("no scenario " + a[0]);
            }
        } catch (Throwable e) {
            err(e instanceof java.lang.reflect.InvocationTargetException i ? i.getCause() : e);
            failed = true;
        }
        System.out.flush();
        System.exit(failed ? 1 : 0);
    }

    /** The two settings a run passes (a missing one is left out: Hibernate's default). */
    static Map<String, Object> settings(Object... more) {
        var m = new LinkedHashMap<String, Object>(props("hibernate.timezone.default_storage", System.getProperty("tzs"),
                "hibernate.jdbc.time_zone", System.getProperty("jtz")));
        m.putAll(props(more));
        return m;
    }

    /** Hibernate's own reading of the two settings, off the built factory. */
    static void options(EntityManagerFactory emf) {
        var o = emf.unwrap(SessionFactoryImplementor.class).getSessionFactoryOptions();
        p("Hibernate's reading (SessionFactoryOptions): getDefaultTimeZoneStorageStrategy() " + o.getDefaultTimeZoneStorageStrategy()
                + " | getJdbcTimeZone() " + (o.getJdbcTimeZone() == null ? "null" : o.getJdbcTimeZone().getID()));
    }

    static void ddl(String name, String file) throws Exception {
        var emf = emf(name, settings("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), OrderLog.class);
        p("the EntityManagerFactory was built over probe.map.log.OrderLog; its script written, and run on this database");
        options(emf);
        emf.close();
    }

    static OrderLog placed() {
        var o = OrderLog.empty();
        o.wall = LocalDateTime.ofInstant(PLACED, ZoneId.systemDefault());
        o.moment = PLACED;
        o.momentNoZone = PLACED;
        o.offsetAt = PLACED.atOffset(KOLKATA_OFFSET);
        o.zonedAt = PLACED.atZone(ZoneId.of("Asia/Kolkata"));
        return o;
    }

    static void persist(EntityManagerFactory emf) {
        reset(emf);
        var o = placed();
        p(STORED + PLACED);
        tx(emf, em -> em.persist(o));
        p("written by this JVM: wall " + o.wall + " (this JVM's clock face for that instant) | moment " + o.moment + " | momentNoZone "
                + o.momentNoZone + " | offsetAt " + o.offsetAt + " | zonedAt " + o.zonedAt);
        p(counted(emf));
        p(counts());
    }

    static void write(String name) throws Exception {
        var emf = emf(name, settings(), OrderLog.class);
        options(emf);
        persist(emf);
        emf.close();
    }

    /** The row as the database holds it, by a second connection (Postgres: its session zone set to UTC first, said). */
    static void raw() throws Exception {
        String cols = "wall | moment | moment_no_zone | offset_at | zoned_at";
        if (DB.equals("pg")) p("the row by a second connection (PostgreSQL, set time zone 'UTC' on it first; each column ::text) - " + cols + ": "
                + H.sql("set time zone 'UTC'", "select wall::text, moment::text, moment_no_zone::text, offset_at::text, zoned_at::text from order_log"));
        else p("the row by a second connection (H2, each column cast as varchar) - " + cols + ": "
                + H.sql("select cast(wall as varchar), cast(moment as varchar), cast(moment_no_zone as varchar), cast(offset_at as varchar), cast(zoned_at as varchar) from order_log"));
    }

    static void readBack(EntityManagerFactory emf) {
        reset(emf);
        var em = emf.createEntityManager();
        var o = em.createQuery("select o from OrderLog o", OrderLog.class).getSingleResult();
        p("read back by a new EntityManager in this JVM (" + TimeZone.getDefault().getID() + "):");
        Instant w = o.wall.atZone(ZoneId.systemDefault()).toInstant();
        p("wall (LocalDateTime) read back: " + o.wall + " - as an instant in this JVM's zone: " + w);
        p(OFFBY + Duration.between(w, PLACED));
        p("moment (Instant) read back: " + o.moment);
        p(OFFBY + Duration.between(o.moment, PLACED));
        p("momentNoZone (Instant on a timestamp column) read back: " + o.momentNoZone);
        p(OFFBY + Duration.between(o.momentNoZone, PLACED));
        p("offsetAt (OffsetDateTime) read back: " + o.offsetAt + " - its instant: " + o.offsetAt.toInstant());
        p(OFFBY + Duration.between(o.offsetAt.toInstant(), PLACED));
        p("zonedAt (ZonedDateTime) read back: " + o.zonedAt + " - its instant: " + o.zonedAt.toInstant());
        p(OFFBY + Duration.between(o.zonedAt.toInstant(), PLACED));
        p(counted(emf));
        p(counts());
        em.close();
    }

    static void read(String name) throws Exception {
        var emf = emf(name, settings("jakarta.persistence.schema-generation.database.action", "none"), OrderLog.class);
        options(emf);
        p(STORED + PLACED + " (what the writer was given)");
        raw();
        readBack(emf);
        emf.close();
    }

    static void offset(String name) throws Exception {
        var emf = emf(name, settings(), OrderLog.class);
        options(emf);
        persist(emf);
        raw();
        readBack(emf);
        emf.close();
    }

    /** The exercise: probe.map.ex.OrderLog's placedAt, whatever its type - LocalDateTime as shipped, or the solution's. */
    static void ex(String what, String name) throws Exception {
        Class<?> k = Class.forName("probe.map.ex.OrderLog");
        Field f = k.getDeclaredField("placedAt");
        f.setAccessible(true);
        String t = f.getType().getSimpleName();
        boolean wall = f.getType() == LocalDateTime.class;
        if (what.equals("write")) {
            var emf = emf(name, settings(), k);
            var c = k.getDeclaredConstructor();
            c.setAccessible(true);
            Object o = c.newInstance();
            f.set(o, wall ? LocalDateTime.ofInstant(PLACED, ZoneId.systemDefault()) : PLACED);
            p(STORED + PLACED);
            tx(emf, em -> em.persist(o));
            p("placedAt (" + t + ") written by this JVM: " + f.get(o));
            emf.close();
        } else {
            var emf = emf(name, settings("jakarta.persistence.schema-generation.database.action", "none"), k);
            var em = emf.createEntityManager();
            Object v = f.get(em.createQuery("select o from OrderLog o", k).getSingleResult());
            Instant i = wall ? ((LocalDateTime) v).atZone(ZoneId.systemDefault()).toInstant() : (Instant) v;
            p("placedAt (" + t + ") read back: " + v + (wall ? " - as an instant in this JVM's zone: " + i : ""));
            p(OFFBY + Duration.between(i, PLACED));
            em.close();
            emf.close();
        }
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u13xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
