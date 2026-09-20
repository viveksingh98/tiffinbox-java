package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The two hooks whose names differ by one word and whose PHASES differ entirely.
 *
 * <p>One is handed the definitions, before a single object exists. The other is handed each
 * object, as it is created. Everything either of them can do follows from that.
 */
public final class TwoHooks {

    /** What happened, in the order it happened, recorded by the beans themselves. */
    static final List<String> LOG = new ArrayList<>();
    static boolean printing;

    private TwoHooks() { }

    static void log(String what) {
        LOG.add(what);
        if (printing) {
            System.out.printf("  %2d  %s%n", LOG.size(), what);
        }
    }

    /** HOOK ONE. It is handed the bean factory. It edits DESCRIPTIONS. */
    public static class EditsTheDescriptions implements BeanFactoryPostProcessor {
        @Override
        public void postProcessBeanFactory(ConfigurableListableBeanFactory bf) throws BeansException {
            // DERIVED over a NAMED filter, and it is the whole claim of this phase: how many
            // objects of the kind this hook is about exist at this moment. Zero is the answer,
            // and it is the difference between the two hooks.
            //
            // AND IT IS PRINTED OVER WHAT IT WAS COUNTED OVER. A bare "0" reads the same whether
            // the filter matched two names or none at all, and this one number is what the whole
            // unit rests on - so the denominator travels with it. Rename PriceList, move it to
            // another package, or reorder the definitions and the line reads "0 of 0 defined",
            // which is a broken filter saying so rather than a zero that looks like the lesson.
            String[] defined = bf.getBeanNamesForType(PriceList.class, true, false);
            int live = 0;
            for (String n : defined) {
                if (bf.containsSingleton(n)) {
                    live++;
                }
            }
            log("BeanFactoryPostProcessor runs   PriceList objects that exist right now: " + live
                    + " of " + defined.length + " defined"
                    + "   (filter: getBeanNamesForType(PriceList), allowEagerInit=false)");
            BeanDefinition kitchen = bf.getBeanDefinition("kitchenPrices");
            log("  it reads a description        scope=\"" + kitchen.getScope()
                    + "\" lazy=" + kitchen.isLazyInit());
            kitchen.setLazyInit(true);
            bf.getBeanDefinition("eveningPrices").setPrimary(true);
            log("  it EDITS two descriptions     kitchenPrices lazy -> true, "
                    + "eveningPrices primary -> true");
        }
    }

    /** HOOK TWO. It is handed each object. It edits INSTANCES. */
    public static class SeesEveryObject implements BeanPostProcessor {
        static int seen;

        @Override
        public Object postProcessBeforeInitialization(Object bean, String name) {
            seen++;
            if (bean instanceof PriceList) {
                log("BeanPostProcessor sees        " + name + " : " + bean.getClass().getSimpleName());
            }
            return bean;
        }

        @Override
        public Object postProcessAfterInitialization(Object bean, String name) {
            if (bean instanceof PriceList pl && !(bean instanceof FrozenPriceList)) {
                log("  it hands back a DIFFERENT object for " + name);
                return new FrozenPriceList(pl);
            }
            return bean;
        }
    }

    @Configuration
    public static class Config {
        @Bean static EditsTheDescriptions editsTheDescriptions() { return new EditsTheDescriptions(); }

        @Bean static SeesEveryObject seesEveryObject() { return new SeesEveryObject(); }

        @Bean PriceList kitchenPrices() {
            log("  @Bean kitchenPrices() body runs");
            return new PriceList().set("thali", 12000).set("half-thali", 7000);
        }

        @Bean PriceList eveningPrices() {
            log("  @Bean eveningPrices() body runs");
            return new PriceList().set("thali", 14000);
        }
    }
}
