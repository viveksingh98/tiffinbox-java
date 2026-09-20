package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/** The two phases, in the order they happened, printed by the things they happened to. */
public final class WhichHookDoINeed {

    private WhichHookDoINeed() { }

    public static void main(String[] args) {
        TwoHooks.printing = true;
        System.out.println("refresh() begins");
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TwoHooks.Config.class)) {
            System.out.println();
            System.out.println("after refresh");
            var bf = ctx.getBeanFactory();
            System.out.printf("  kitchenPrices, lazy in the description   %s   built yet: %s%n",
                    bf.getBeanDefinition("kitchenPrices").isLazyInit(),
                    bf.containsSingleton("kitchenPrices"));
            System.out.printf("  eveningPrices, primary in the description %s%n",
                    bf.getBeanDefinition("eveningPrices").isPrimary());
            PriceList evening = ctx.getBean("eveningPrices", PriceList.class);
            System.out.printf("  the class your name points at            %s%n",
                    evening.getClass().getName());
            System.out.printf("  it is still a %s                  %s%n",
                    PriceList.class.getSimpleName(), evening instanceof PriceList);
            try {
                evening.set("thali", 1);
                System.out.println("  writing to it                           allowed");
            } catch (UnsupportedOperationException e) {
                System.out.printf("  writing to it                           %s: %s%n",
                        e.getClass().getSimpleName(), e.getMessage());
            }
            System.out.println();
            System.out.printf("objects the BeanPostProcessor was handed    %d%n",
                    TwoHooks.SeesEveryObject.seen);
            System.out.printf("events recorded before any PriceList existed %d%n", beforeAnyObject());
            System.out.printf("events recorded in total                   %d%n", TwoHooks.LOG.size());
        }
    }

    /** DERIVED: everything logged up to and including the description-editing phase. */
    static int beforeAnyObject() {
        int n = 0;
        for (String s : TwoHooks.LOG) {
            n++;
            if (s.startsWith("  it EDITS")) {
                return n;
            }
        }
        return n;
    }
}
