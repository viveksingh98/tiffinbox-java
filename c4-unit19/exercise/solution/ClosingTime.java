package com.tiffinbox;

import java.lang.reflect.Proxy;

/** Solution. Copy over src/main/java/com/tiffinbox/ClosingTime.java to run it. */
public class ClosingTime {
    public static void main(String[] args) {
        Rail real = new KitchenRail();
        int hour = args.length > 0 ? Integer.parseInt(args[0]) : 23;

        Rail guarded = (Rail) Proxy.newProxyInstance(Rail.class.getClassLoader(),
                new Class<?>[]{Rail.class},
                (p, method, a) -> hour >= 22 ? "closed" : method.invoke(real, a));

        System.out.println("at " + hour + ":00 -> " + guarded.place("Ravi"));
        // The check that can FAIL: call the real rail directly. It must still cook at any hour.
        System.out.println("the real rail, called directly -> " + real.place("Ravi") + "   (must still cook)");
    }
}
