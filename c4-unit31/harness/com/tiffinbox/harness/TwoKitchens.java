package com.tiffinbox.harness;

import com.tiffinbox.OrderQueue;
import com.tiffinbox.web.TiffinBoxApp;
import java.util.IdentityHashMap;
import java.util.Map;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * THE BREAK, examined. receipts.sh runs this three times - on the rewired anchor (A), on the one-new
 * break (B), and on the anchor again (A') - and asks the container what it can see: its own kitchen,
 * and whether the server cooks with it. Objects are named by IDENTITY, in the order first seen: the
 * same object gets the same number, a different object a new one.
 */
public final class TwoKitchens {
    private TwoKitchens() { }
    private static final Map<Object, Integer> IDS = new IdentityHashMap<>();
    private static String id(Object o) { return "kitchen #" + IDS.computeIfAbsent(o, k -> IDS.size() + 1); }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18444");
        try (var ctx = new AnnotationConfigApplicationContext(TiffinBoxApp.class)) {
            OrderQueue bean = ctx.getBean(OrderQueue.class);
            Object server = ctx.getBean("tiffinBoxServer");
            var field = server.getClass().getDeclaredField("kitchen");
            field.setAccessible(true);
            OrderQueue used = (OrderQueue) field.get(server);
            System.out.println("  kitchens in the context             : " + ctx.getBeansOfType(OrderQueue.class).size());
            System.out.println("  the container's kitchen             : " + id(bean));
            System.out.println("  the kitchen the server cooks with   : " + id(used));
            System.out.println("  orders cooked - the server's kitchen: " + used.cooked() + ", the container's: " + bean.cooked());
        }
    }
}
