import java.sql.Connection;

/// The whole stack, running: the pool, the repository, the interface above it.
public class RepoDemo {
    public static void main(String[] args) throws Exception {
        try (Connection c = Db.dataSource().getConnection()) { Db.reset(c); }
        var repo = new JdbcCustomerRepository(Db.dataSource());

        IO.println("-- CRUD ------------------------------------------------");
        IO.println("findAll():");
        repo.findAll().forEach(c -> IO.println("  " + c));

        IO.println("findById(3L):  " + repo.findById(3L).orElseThrow());
        IO.println("findById(99L): " + repo.findById(99L));

        repo.save(new Customer(5, "Kiran", "kiran@tiffinbox.test", MealType.NON_VEG, true));
        IO.println("after save(Kiran), count: " + repo.findAll().size());
        repo.save(new Customer(5, "Kiran", "kiran@tiffinbox.test", MealType.VEG, true));
        IO.println("after save(same id, VEG): " + repo.findById(5L).orElseThrow());

        IO.println("-- REVENUE (a query the interface does not have) --------");
        for (Customer c : repo.findAll())
            IO.println("  %-6s %-9s %6d".formatted(c.name(), c.mealType(), repo.revenueOf(c.id())));
        IO.println("  Kiran without COALESCE: " + repo.revenueWithoutCoalesce(5));

        IO.println("-- CRUD continued --------------------------------------");
        IO.println("deleteById(5L): " + repo.deleteById(5L));
        IO.println("deleteById(5L): " + repo.deleteById(5L));
        IO.println("count now:      " + repo.findAll().size());

        IO.println("-- BREAK IT ON PURPOSE ---------------------------------");
        Db.exec("ALTER TABLE customers ALTER COLUMN meal_type RENAME TO diet");
        IO.println("migration shipped: meal_type renamed to diet. Java unchanged.");
        try {
            repo.findAll();
        } catch (IllegalStateException e) {
            var sql = (java.sql.SQLException) e.getCause();
            IO.println("  translated: " + e.getMessage());
            IO.println("  caused by:  " + sql.getClass().getSimpleName()
                     + ", SQLState " + sql.getSQLState());
            IO.println("  says:       " + sql.getMessage().split(";")[0]);
        }
        try {
            throw new IllegalStateException("findAll failed");   // the same throw, cause dropped
        } catch (IllegalStateException e) {
            IO.println("  drop the cause and all you get:");
            IO.println("  translated: " + e.getMessage());
            IO.println("  caused by:  " + e.getCause());
        }
        Db.close();
    }
}
