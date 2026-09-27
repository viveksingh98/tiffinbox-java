package com.tiffinbox.harness;

import com.tiffinbox.OrderQueue;
import com.tiffinbox.web.TiffinBoxApp;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * THE BREAK, examined: the server built with one hand-written `new OrderQueue(COOKS)`. The curl output does
 * not change. This asks the container what it can see: its own kitchen, and whether the server uses it.
 */
public final class TwoKitchens {
    private TwoKitchens() { }
    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18444");
        try (var ctx = new AnnotationConfigApplicationContext(TiffinBoxApp.class)) {
            Object server = ctx.getBean("tiffinBoxServer");
            var field = server.getClass().getDeclaredField("kitchen");
            field.setAccessible(true);
            OrderQueue used = (OrderQueue) field.get(server);
            OrderQueue bean = ctx.getBean(OrderQueue.class);
            System.out.println("kitchens in the context          : " + ctx.getBeansOfType(OrderQueue.class).size());
            System.out.println("the server cooks with that one?  : " + (used == bean));
            System.out.println("orders cooked - the server's kitchen: " + used.cooked() + ", the container's: " + bean.cooked());
        }
    }
}
