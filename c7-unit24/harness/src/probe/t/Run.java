package probe.t;

import com.tiffinbox.Database;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.annotation.Propagation;

import java.util.Arrays;
import java.util.List;

/**
 * One scenario per JVM (-Ds=grid | alone | nested). A cell: the shipped Database's createAndSeed() first (the four seeded rows again),
 * then, between ">>> cell METHOD · MODE" and "<<< cell METHOD · MODE": outer-fails and inner-fails call Outer24.run(METHOD, MODE) through
 * its proxy; alone calls the inner method through Outer24's dispatch with no transaction around it (and fails after its save). What the
 * call threw is printed as its chain; the second connection reads the rows AFTER the call ("after:" - S4.1); the cell line closes it:
 * the attribute read off the method (AnnotationTransactionAttributeSource, S4.15), the mode, and - unless the inner call was refused,
 * when the line says "refused <class>" and no rows - the rows of Asha (the outer's save) and Dev (the inner's), and how the outer ended.
 */
@Component
public class Run implements CommandLineRunner {
    static final List<String> METHODS = List.of("required", "requiresNew", "nested", "supports", "notSupported", "mandatory", "never");
    private final ApplicationContext ctx;
    private final Outer24 outer;
    private final Database database;

    Run(ApplicationContext ctx, Outer24 outer, Database database) { this.ctx = ctx; this.outer = outer; this.database = database; }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        H.p("database: H2 " + org.h2.engine.Constants.VERSION + " | url " + H.url);
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        ctx.getBeansOfType(PlatformTransactionManager.class).forEach((n, b) -> H.p("transaction manager bean: " + n + " · " + b.getClass().getName()));
        H.p("spring.profiles.active as this context read it: " + ctx.getEnvironment().getProperty("spring.profiles.active", "(none)"));
        H.p("Propagation.values().length: " + Propagation.values().length + " " + Arrays.toString(Propagation.values()));
        switch (s) {
            case "grid" -> { for (String m : METHODS) for (String mode : List.of("outer-fails", "inner-fails", "alone")) cell(m, mode); }
            case "alone" -> { for (String m : METHODS) cell(m, "alone"); }
            case "nested" -> { for (String mode : List.of("outer-fails", "inner-fails", "alone")) cell("nested", mode); }
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    void cell(String m, String mode) throws Exception {
        var attr = new AnnotationTransactionAttributeSource().getTransactionAttribute(Inner24.class.getMethod(m, boolean.class), Inner24.class);
        database.createAndSeed();
        String label = "cell " + m + " · " + mode;
        H.p(">>> " + label);
        H.outcome = "not called";
        String how;
        try {
            if (mode.equals("alone")) outer.call(m, true); else outer.run(m, mode);
            how = "outer returned";
        } catch (RuntimeException e) {
            H.chain("threw", e);
            how = (mode.equals("alone") ? "threw " : "outer threw ") + e.getClass().getSimpleName();
        }
        H.p("after: the second connection reads " + H.rows());
        String got = H.outcome.startsWith("refused") ? H.outcome
                   : mode.equals("alone") ? "Dev " + H.ka("Dev")
                   : "Asha " + H.ka("Asha") + " · Dev " + H.ka("Dev") + " · " + how;
        H.p("cell " + m + " · attribute " + attr + " · " + mode + " · " + got);
        H.p("<<< " + label);
    }
}
