package probe.t;

import com.tiffinbox.Database;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.interceptor.TransactionAttributeSource;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

/**
 * One scenario per JVM (-Ds=rules | twowrites; the events scenario is probe.t.ev's). A row: the shipped Database's createAndSeed()
 * first (the four seeded rows again), then, between ">>> row LABEL" and "<<< row LABEL": the method called by name through its
 * bean's proxy, what it threw printed as its chain, the second connection's read AFTER the call ("after:" - S4.1), and the row line:
 * the attribute this context's own TransactionAttributeSource reads off the method (the bean Spring's interceptor uses), the
 * customer KEPT or gone, how the call ended.
 */
@Component
public class Run implements CommandLineRunner {
    record Row(String label, String bean, String method, String name) {}

    static final List<Row> RULES = List.of(
        new Row("checked exception", "rb26", "checked", "Asha"),
        new Row("checked, rollbackFor = Exception.class", "rb26", "checkedRollbackFor", "Dev"),
        new Row("RuntimeException", "rb26", "runtime", "Nina"),
        new Row("RuntimeException, noRollbackFor = Boom.class", "rb26", "runtimeNoRollbackFor", "Omar"),
        new Row("an Error", "rb26", "error", "Tara"),
        new Row("RuntimeException caught inside", "rb26", "caught", "Zoe"),
        new Row("setRollbackOnly(), no exception", "rb26", "rollbackOnly", "Ivan"),
        new Row("JTA's annotation, checked", "jta26", "checked", "Mia"),
        new Row("JTA's annotation, RuntimeException", "jta26", "runtime", "Ella"),
        new Row("JTA's annotation, checked, rollbackOn = Exception.class", "jta26", "checkedRollbackOn", "Lena"));
    static final List<Row> TWO = List.of(
        new Row("two writes, a checked exception between them", "rb26", "twoWrites", "Kavya"),
        new Row("two writes, rollbackFor = Exception.class", "rb26", "twoWritesRollbackFor", "Kira"));

    private final ApplicationContext ctx;
    private final Database database;

    Run(ApplicationContext ctx, Database database) { this.ctx = ctx; this.database = database; }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        if (s.equals("events")) return;
        H.p("database: H2 " + org.h2.engine.Constants.VERSION + " | url " + H.url);
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        ctx.getBeansOfType(PlatformTransactionManager.class).forEach((n, b) -> H.p("transaction manager bean: " + n + " · " + b.getClass().getName()));
        H.p("spring.profiles.active as this context read it: " + ctx.getEnvironment().getProperty("spring.profiles.active", "(none)"));
        ctx.getBeansOfType(TransactionAttributeSource.class).forEach((n, b) -> H.p("transaction attribute source bean: " + n + " · " + b.getClass().getName()));
        switch (s) {
            case "rules" -> { for (Row r : RULES) row(r, false); }
            case "twowrites" -> { for (Row r : TWO) row(r, true); }
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    void row(Row r, boolean pauses) throws Exception {
        Object bean = ctx.getBean(r.bean());
        Class<?> target = org.springframework.aop.support.AopUtils.getTargetClass(bean);
        Method m = target.getMethod(r.method(), String.class);
        var attr = ctx.getBean(TransactionAttributeSource.class).getTransactionAttribute(m, target);
        database.createAndSeed();
        H.p(">>> row " + r.label());
        String how;
        try {
            m.invoke(bean, r.name());
            how = "returned";
        } catch (InvocationTargetException e) {
            H.chain("threw", e.getCause());
            how = "threw " + e.getCause().getClass().getSimpleName();
        }
        H.p("after: the second connection reads " + H.rows());
        H.p("row " + r.label() + " · " + target.getSimpleName() + "." + r.method() + " · attribute " + attr + " · " + r.name() + " "
            + H.ka(r.name()) + (pauses ? " · her pauses " + H.pauses(r.name()) : "") + " · " + how);
        H.p("<<< row " + r.label());
    }
}
