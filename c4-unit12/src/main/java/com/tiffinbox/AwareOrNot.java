package com.tiffinbox;

import org.springframework.beans.factory.BeanNameAware;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The same job done two ways, and the difference is not style — it is whether the object can
 * exist outside a container at all.
 */
public final class AwareOrNot {

    private AwareOrNot() { }

    /** Way one: ask the container for what you need, at run time. */
    public static class ReachesForTheContext implements ApplicationContextAware, BeanNameAware {
        private ApplicationContext ctx;
        private String myName = "(not set)";
        @Override public void setApplicationContext(ApplicationContext c) { this.ctx = c; }
        @Override public void setBeanName(String n) { this.myName = n; }
        public String describe() {
            return myName + " -> " + ctx.getBean(Checks.Power.class).name();
        }
    }

    /** Way two: be handed what you need, at construction. */
    public static class IsHandedWhatItNeeds {
        private final StartupCheck check;
        public IsHandedWhatItNeeds(StartupCheck check) { this.check = check; }
        public String describe() { return "handed -> " + check.name(); }
    }

    @Configuration
    public static class Config {
        @Bean Checks.Power power() { return new Checks.Power(); }
        @Bean ReachesForTheContext reachesForTheContext() { return new ReachesForTheContext(); }
        @Bean IsHandedWhatItNeeds isHandedWhatItNeeds(StartupCheck c) {
            return new IsHandedWhatItNeeds(c);
        }
    }

    public static void main(String[] args) {
        System.out.println("inside a container");
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println("  ApplicationContextAware + BeanNameAware   "
                    + ctx.getBean(ReachesForTheContext.class).describe());
            System.out.println("  a constructor parameter                   "
                    + ctx.getBean(IsHandedWhatItNeeds.class).describe());
        }
        System.out.println();
        System.out.println("the same two objects, constructed by hand — which is what a test does");
        System.out.println("  new IsHandedWhatItNeeds(new Power())      "
                + new IsHandedWhatItNeeds(new Checks.Power()).describe());
        try {
            System.out.println("  new ReachesForTheContext().describe()     "
                    + new ReachesForTheContext().describe());
        } catch (RuntimeException e) {
            System.out.println("  new ReachesForTheContext().describe()     "
                    + e.getClass().getName());
        }
        System.out.println();
        System.out.printf("interfaces the container-reaching class had to implement  %d%n",
                ReachesForTheContext.class.getInterfaces().length);
        System.out.printf("interfaces the constructor version had to implement       %d%n",
                IsHandedWhatItNeeds.class.getInterfaces().length);
    }
}
