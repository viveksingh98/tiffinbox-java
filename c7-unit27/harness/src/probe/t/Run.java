package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import jakarta.persistence.LockModeType;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * One scenario per JVM (-Ds=version | race | merge | modes | seededit), each on the shipped Database's seed (Ravi, Meera, Sunil,
 * Priya), re-run before each part. Every edit is Edit27's, through its proxy; every read that judges an outcome is the second
 * connection's (DriverManager, the same URL), after the call returned or threw (S4.1). The race: two threads, A and B, ordered by two
 * latches - A loads Ravi, then B loads Ravi, adds 5 and commits, then A adds 1 and commits (S4.6, S4.18) - three rounds.
 */
@Component
public class Run implements CommandLineRunner {
    private final Database database;
    private final CustomerEntityRepository repo;
    private final Edit27 edit;

    Run(Database database, CustomerEntityRepository repo, Edit27 edit) {
        this.database = database;
        this.repo = repo;
        this.edit = edit;
    }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        H.p("database: H2 " + org.h2.engine.Constants.VERSION + " | url " + H.url);
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        H.p("CustomerEntity's version field: " + H.vdesc());
        switch (s) {
            case "version" -> version();
            case "race" -> race();
            case "merge" -> merge();
            case "modes" -> modes();
            case "seededit" -> seededit();
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    void version() throws Exception {
        database.createAndSeed();
        H.p(">>> a new customer: Kavya, saved through CustomerEntityRepository");
        CustomerEntity k = repo.save(new CustomerEntity("Kavya", 2, 110, MealType.VEG));
        H.p("save returned Kavya · id " + k.getId() + H.ver(k));
        H.p("<<< a new customer");
        H.p("after: the second connection reads " + H.row("Kavya"));
        H.p(">>> an edit: Kavya's mealsPerDay plus 1, in one transaction");
        edit.edit(k.getId(), 1, null, null);
        H.p("<<< an edit");
        H.p("after: the second connection reads " + H.row("Kavya"));
        H.p(">>> read back: findById");
        CustomerEntity r = repo.findById(k.getId()).orElseThrow();
        H.p("findById returned Kavya · mealsPerDay " + r.getMealsPerDay() + H.ver(r));
        H.p("<<< read back");
    }

    void race() throws Exception {
        for (int round = 1; round <= 3; round++) {
            database.createAndSeed();
            H.p(">>> round " + round + " · the second connection reads " + H.row("Ravi"));
            var aLoaded = new CountDownLatch(1);
            var bCommitted = new CountDownLatch(1);
            String[] out = new String[2];
            Thread a = new Thread(() -> {
                try {
                    out[0] = "A committed, mealsPerDay " + edit.edit(1L, 1, aLoaded, bCommitted);
                } catch (Exception e) {
                    H.chain("A threw", e);
                    out[0] = "A threw " + e.getClass().getName();
                }
            }, "A");
            Thread b = new Thread(() -> {
                try {
                    if (!aLoaded.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("A never loaded");
                    out[1] = "B committed, mealsPerDay " + edit.edit(1L, 5, null, null);
                } catch (Exception e) {
                    H.chain("B threw", e);
                    out[1] = "B threw " + e.getClass().getName();
                } finally {
                    bCommitted.countDown();
                }
            }, "B");
            a.start();
            b.start();
            a.join();
            b.join();
            H.p("<<< round " + round);
            H.p("round " + round + " · " + out[1] + " · " + out[0] + " · after both: the second connection reads " + H.row("Ravi"));
        }
    }

    void merge() throws Exception {
        database.createAndSeed();
        CustomerEntity stale = repo.findById(1L).orElseThrow();
        H.p("findById returned a copy of Ravi · mealsPerDay " + stale.getMealsPerDay() + H.ver(stale) + " · the copy is detached: its call's transaction committed");
        H.p(">>> another transaction edits Ravi: mealsPerDay plus 1");
        edit.edit(1L, 1, null, null);
        H.p("<<< another transaction");
        H.p("after: the second connection reads " + H.row("Ravi"));
        stale.setMealsPerDay(9);
        H.p(">>> save(stale): the copy's mealsPerDay set to 9" + H.ver(stale) + ", then CustomerEntityRepository.save");
        try {
            repo.save(stale);
            H.p("save returned");
        } catch (RuntimeException e) {
            H.chain("save threw", e);
        }
        H.p("<<< save(stale)");
        H.p("after: the second connection reads " + H.row("Ravi"));
    }

    void modes() throws Exception {
        for (LockModeType m : List.of(LockModeType.OPTIMISTIC, LockModeType.OPTIMISTIC_FORCE_INCREMENT)) {
            database.createAndSeed();
            H.p(">>> " + m + " · Ravi loaded with it, nothing changed");
            edit.lock(1L, m);
            H.p("<<< " + m);
            H.p("after: the second connection reads " + H.row("Ravi"));
        }
    }

    void seededit() throws Exception {
        database.createAndSeed();
        H.p("before: the second connection reads " + H.row("Ravi"));
        H.p(">>> the first edit of a seeded customer: Ravi's mealsPerDay plus 1");
        try {
            edit.edit(1L, 1, null, null);
            H.p("the edit returned");
        } catch (RuntimeException e) {
            H.chain("the edit threw", e);
        }
        H.p("<<< the first edit");
        H.p("after: the second connection reads " + H.row("Ravi"));
    }
}
