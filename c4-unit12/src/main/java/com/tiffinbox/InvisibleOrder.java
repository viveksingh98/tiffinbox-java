package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;

/**
 * The order the container CANNOT work out, because nothing in the code says it.
 *
 * <p>The seeder fills the database. The revenue board reads it. The board does not reference
 * the seeder — it references the repository — so as far as the container is concerned the two
 * are unrelated and either may be built first. Three configurations, one difference each.
 */
public final class InvisibleOrder {

    static final List<String> BUILT = new ArrayList<>();

    private InvisibleOrder() { }

    public static final class Seeder {
        public Seeder(Database db) throws Exception {
            db.createAndSeed();
            BUILT.add("seeder");
        }
    }

    public static final class RevenueBoard {
        private final int revenue;
        public RevenueBoard(CustomerRepository repo) throws Exception {
            this.revenue = repo.monthRevenue();
            BUILT.add("revenueBoard");
        }
        public int revenue() { return revenue; }
    }

    /**
     * One in-memory database PER CASE. Measured the hard way: with a single shared URL the
     * three cases share one H2 instance, case [1] seeds it, and case [2] reads a table that
     * is already there — so the break silently did not break. A demo that shares state
     * between its own cases is not three captures, it is one.
     */
    static String jdbc(String which) {
        return "jdbc:h2:mem:tiffinbox-order-" + which + ";DB_CLOSE_DELAY=-1";
    }

    /** [1] seeder declared FIRST. Nothing says it must be. */
    @Configuration
    public static class SeederFirst {
        @Bean Database database() { return new Database(jdbc("one")); }
        @Bean Seeder seeder(Database db) throws Exception { return new Seeder(db); }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean RevenueBoard revenueBoard(CustomerRepository r) throws Exception { return new RevenueBoard(r); }
    }

    /** [2] the SAME file with one method moved. Nothing else is different. */
    @Configuration
    public static class BoardFirst {
        @Bean Database database() { return new Database(jdbc("two")); }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean RevenueBoard revenueBoard(CustomerRepository r) throws Exception { return new RevenueBoard(r); }
        @Bean Seeder seeder(Database db) throws Exception { return new Seeder(db); }
    }

    /** [3] the same file as [2], with the requirement written down. */
    @Configuration
    public static class BoardFirstButSaid {
        @Bean Database database() { return new Database(jdbc("three")); }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean @DependsOn("seeder")
        RevenueBoard revenueBoard(CustomerRepository r) throws Exception { return new RevenueBoard(r); }
        @Bean Seeder seeder(Database db) throws Exception { return new Seeder(db); }
    }

    public static void main(String[] args) {
        run("[1] seeder declared first, nothing written down", SeederFirst.class);
        run("[2] ONE method moved down the file, nothing else", BoardFirst.class);
        run("[3] the same file, plus @DependsOn(\"seeder\")   ", BoardFirstButSaid.class);
    }

    static void run(String tag, Class<?> config) {
        BUILT.clear();
        System.out.println();
        System.out.println(tag);
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(config)) {
            System.out.printf("  built in this order    %s%n", BUILT);
            System.out.printf("  month revenue the board read   %d%n",
                    ctx.getBean(RevenueBoard.class).revenue());
            System.out.printf("  dependsOn recorded on revenueBoard  %s%n",
                    java.util.Arrays.toString(
                            ctx.getBeanFactory().getBeanDefinition("revenueBoard").getDependsOn()));
        } catch (RuntimeException e) {
            Throwable root = e;
            while (root.getCause() != null) {
                root = root.getCause();
            }
            System.out.printf("  built in this order    %s%n", BUILT);
            System.out.printf("  refresh                REFUSED%n");
            System.out.printf("  root of the chain      %s%n", root.getClass().getName());
            System.out.printf("  its first line         %s%n",
                    root.getMessage() == null ? "(none)" : root.getMessage().split("\n")[0]);
        }
    }
}
