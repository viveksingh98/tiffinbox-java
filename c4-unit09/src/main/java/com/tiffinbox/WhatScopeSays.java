package com.tiffinbox;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/**
 * Two questions this unit has to answer before it can be believed.
 *
 * <p>ONE. The definition printer and the report disagree on screen: one says the scope is
 * "(default)" and the other says "singleton". Both are right, and here is why.
 *
 * <p>TWO. The configuration subclass was drawn earlier with one arrow labelled "already have
 * one". That drawing is true for a singleton and FALSE for a prototype, and this is the run
 * that says so.
 */
public final class WhatScopeSays {

    private WhatScopeSays() { }

    @Configuration
    public static class Config {
        @Bean DeliveryRun oneForEver() { return new DeliveryRun(); }

        @Bean @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
        DeliveryRun onePerTrip() { return new DeliveryRun(); }

        /** Calls its OWN @Bean methods twice each — the case the subclass exists for. */
        @Bean String twoCallsEach() {
            boolean singletonSame = oneForEver() == oneForEver();
            boolean prototypeSame = onePerTrip() == onePerTrip();
            return "singleton method called twice -> same object " + singletonSame
                    + "  |  prototype method called twice -> same object " + prototypeSame;
        }
    }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Config.class)) {
            var bf = ctx.getBeanFactory();
            System.out.println("what the DEFINITION says, and what the CONTAINER answers");
            System.out.printf("  %-12s getScope()=%-12s isSingleton()=%-6s isPrototype()=%s%n",
                    "oneForEver", "\"" + bf.getBeanDefinition("oneForEver").getScope() + "\"",
                    bf.getBeanDefinition("oneForEver").isSingleton(),
                    bf.getBeanDefinition("oneForEver").isPrototype());
            System.out.printf("  %-12s getScope()=%-12s isSingleton()=%-6s isPrototype()=%s%n",
                    "onePerTrip", "\"" + bf.getBeanDefinition("onePerTrip").getScope() + "\"",
                    bf.getBeanDefinition("onePerTrip").isSingleton(),
                    bf.getBeanDefinition("onePerTrip").isPrototype());
            System.out.println();
            System.out.println("the configuration subclass, asked the same question twice");
            System.out.println("  " + ctx.getBean("twoCallsEach"));
            System.out.printf("  the class holding those methods   %s%n",
                    ctx.getBean(Config.class).getClass().getName());
            System.out.println();
            System.out.printf("DeliveryRun objects constructed by this context   %d%n",
                    DeliveryRun.built());
        }
    }
}
