package probe.t;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.aop.framework.Advised;
import org.springframework.aop.support.AopUtils;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.interceptor.TransactionAttributeSource;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * One scenario per JVM (-Ds=bean | call | trap | fixb | visibility | jdbc; -Dv=B|A for trap). Each call sits between two markers,
 * ">>> label" and "<<< label"; JpaTransactionManager's DEBUG lines and the transaction interceptor's TRACE lines between them are the
 * manager's witness (S4.1), the method prints its own TransactionSynchronizationManager line, and the second connection reads the rows
 * AFTER the call returned or threw ("after:" - S4.1's third witness, never a count inside the transaction).
 */
@Component
public class Run implements CommandLineRunner {
    private final ApplicationContext ctx;

    Run(ApplicationContext ctx) { this.ctx = ctx; }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        H.p("database: H2 " + org.h2.engine.Constants.VERSION + " | url " + H.url);
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        var svc = ctx.getBean(Svc23.class);
        var caller = ctx.getBean(Caller23.class);
        switch (s) {
            case "bean" -> bean();
            case "call" -> step("svc.saveOk(Kavya)", () -> svc.saveOk("Kavya"));
            case "trap" -> {
                if ("B".equals(System.getProperty("v"))) step("svc.outer(Asha) -> this.inner(Asha)", () -> svc.outer("Asha"));
                else step("svc.outerTx(Dev) -> this.inner(Dev)", () -> svc.outerTx("Dev"));
            }
            case "fixb" -> step("caller.viaProxy(Nina) -> svc.inner(Nina), through the proxy", () -> caller.viaProxy("Nina"));
            case "visibility" -> {
                attributes();
                step("protected: caller.callProtected(Omar)", () -> caller.callProtected("Omar"));
                step("package-private: caller.callPackage(Lena)", () -> caller.callPackage("Lena"));
                step("private: Svc23.callPrivateOn(the proxy, Tara) -> proxy.privInner(Tara)", () -> caller.callPrivate("Tara"));
            }
            case "jdbc" -> step("svc.saveOk(Kavya), H2's JDBC trace on", () -> svc.saveOk("Kavya"));
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    void step(String label, Runnable body) {
        H.p(">>> " + label);
        try {
            body.run();
            H.p("returned");
        } catch (RuntimeException e) {
            H.chain("threw", e);
        }
        H.p("after: the second connection reads " + H.rows());
        H.p("<<< " + label);
    }

    static String bean(Object o) {
        var l = new ArrayList<String>();
        if (o instanceof Advised a) for (var adv : a.getAdvisors()) l.add(adv.getAdvice().getClass().getName());
        return "class " + o.getClass().getName() + " · AopUtils.isCglibProxy " + AopUtils.isCglibProxy(o) + " · isJdkDynamicProxy "
               + AopUtils.isJdkDynamicProxy(o) + " · target " + AopUtils.getTargetClass(o).getName() + " · advices " + l.size() + " " + l;
    }

    void bean() {
        H.p("bean svc23: " + bean(ctx.getBean(Svc23.class)));
        var billing = ctx.getBean(Billing.class);
        H.p("bean billing (interface-typed: Billing <- BillingImpl): " + bean(billing) + " · interfaces "
            + Arrays.stream(billing.getClass().getInterfaces()).map(Class::getName).toList());
        H.p("bean customerEntityRepository (Spring Data's own): " + bean(ctx.getBean(CustomerEntityRepository.class)));
        ctx.getBeansOfType(PlatformTransactionManager.class).forEach((n, b) -> H.p("transaction manager bean: " + n + " · " + b.getClass().getName()));
        var tas = ctx.getBean(TransactionAttributeSource.class);
        H.p("transaction attribute source: " + Arrays.toString(ctx.getBeanNamesForType(TransactionAttributeSource.class)) + " · " + tas.getClass().getName());
        H.p("spring.aop.proxy-target-class as this context read it: " + ctx.getEnvironment().getProperty("spring.aop.proxy-target-class", "(not set: Boot's default)"));
        H.p("on the class path - org.aspectj.weaver.Advice: " + present("org.aspectj.weaver.Advice")
            + " · org.springframework.transaction.aspectj.AnnotationTransactionAspect: " + present("org.springframework.transaction.aspectj.AnnotationTransactionAspect"));
    }

    static boolean present(String c) {
        try { Class.forName(c, false, Run.class.getClassLoader()); return true; } catch (ClassNotFoundException e) { return false; }
    }

    void attributes() throws Exception {
        var tas = ctx.getBean(TransactionAttributeSource.class);
        for (String m : List.of("inner", "protInner", "pkgInner", "privInner")) {
            Method mm = Svc23.class.getDeclaredMethod(m, String.class);
            H.p("attribute for Svc23." + m + " (" + (mm.getModifiers() == 0 ? "package-private" : Modifier.toString(mm.getModifiers())) + "): "
                + tas.getTransactionAttribute(mm, Svc23.class));
        }
    }
}
