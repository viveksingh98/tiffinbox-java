package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/** Two beans fit the same slot. What the container does, and the three ways out. */
public final class ThreeWaysOut {
    private ThreeWaysOut() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Rails.Config.class)) {
            Rails.RailMonitor mon = ctx.getBean(Rails.RailMonitor.class);
            System.out.println("beans of type OrderQueue        "
                    + ctx.getBeanNamesForType(OrderQueue.class).length);
            System.out.println("@Qualifier(\"kitchenRail\")        billingService got "
                    + (ctx.getBean(Rails.BillingService.class) != null ? "the rail it named" : "nothing"));
            System.out.println("@Qualifier(\"deliveryRail\")       deliveryService got "
                    + (ctx.getBean(Rails.DeliveryService.class) != null ? "the rail it named" : "nothing"));
            System.out.println("List<OrderQueue>.size()         " + mon.railCount());
            System.out.println("Map<String, OrderQueue> keys    " + mon.names());
            System.out.println("and the identity check          kitchen == delivery  "
                    + (ctx.getBean("kitchenRail") == ctx.getBean("deliveryRail")));
        }
    }
}
