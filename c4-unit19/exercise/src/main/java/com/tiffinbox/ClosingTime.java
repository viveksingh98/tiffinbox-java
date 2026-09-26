package com.tiffinbox;

/**
 * YOUR JOB: the kitchen closes at 22:00. After that, place() must answer "closed" — WITHOUT
 * editing KitchenRail, which must not learn that closing time exists.
 *
 * Write an InvocationHandler, build a proxy with Proxy.newProxyInstance, and print both answers.
 */
public class ClosingTime {
    public static void main(String[] args) {
        Rail real = new KitchenRail();
        int hour = args.length > 0 ? Integer.parseInt(args[0]) : 23;

        // TODO: build `Rail guarded` as a proxy in front of `real`.
        //       If hour >= 22, answer "closed" and DO NOT call the real rail.
        Rail guarded = real;   // replace this line

        System.out.println("at " + hour + ":00 -> " + guarded.place("Ravi"));
        System.out.println("KitchenRail mentions closing time? "
                + java.util.Arrays.stream(KitchenRail.class.getDeclaredMethods())
                      .anyMatch(m -> m.getName().toLowerCase().contains("clos")));
    }
}
