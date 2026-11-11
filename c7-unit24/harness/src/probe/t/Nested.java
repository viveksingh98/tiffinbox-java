package probe.t;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.AbstractPlatformTransactionManager;

/** Prints the transaction manager's nestedTransactionAllowed as built; -Dnested=true (the LABELLED run B) sets it, and prints it again. */
@Component
public class Nested implements BeanPostProcessor {
    @Override
    public Object postProcessAfterInitialization(Object bean, String name) {
        if (bean instanceof AbstractPlatformTransactionManager tm) {
            H.p("transaction manager " + name + " · " + tm.getClass().getName() + " · nestedTransactionAllowed as built: " + tm.isNestedTransactionAllowed());
            if (Boolean.getBoolean("nested")) {
                tm.setNestedTransactionAllowed(true);
                H.p("LABELLED -Dnested=true: transaction manager " + name + " · nestedTransactionAllowed set: " + tm.isNestedTransactionAllowed());
            }
        }
        return bean;
    }
}
