package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.event.EventListener;

/**
 * THE BREAK. Four spellings of "only orders over 500". The first is the one the documentation uses - and
 * it names the parameter, `e`. Without the -parameters compiler flag (Maven's default) that name is not
 * in the class file, so #e is null and the condition THROWS on every publish, matching or not.
 * Spring Boot turns -parameters on for you; this course has no Boot.
 */
public final class Conditions {
    private Conditions() { }
    static String hit;
    public static class ByName  { @EventListener(condition = "#e.total > 500")                   public void on(OrderPlaced e) { hit = "ran"; } }
    public static class ByA0    { @EventListener(condition = "#a0.total > 500")                  public void on(OrderPlaced e) { hit = "ran"; } }
    public static class ByArgs  { @EventListener(condition = "#root.args[0].total > 500")        public void on(OrderPlaced e) { hit = "ran"; } }
    public static class ByEvent { @EventListener(condition = "#root.event.payload.total > 500")  public void on(OrderPlaced e) { hit = "ran"; } }

    static void run(Class<?> listener, int total) {
        hit = "did not run";
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.registerBean(listener); ctx.refresh();
            ctx.publishEvent(new OrderPlaced("Asha", total));
            System.out.printf("  %-8s total %-4d -> %s%n", listener.getSimpleName(), total, hit);
        } catch (Exception ex) {
            System.out.printf("  %-8s total %-4d -> %s: %s%n", listener.getSimpleName(), total,
                    ex.getClass().getSimpleName(), ex.getMessage().split("\n")[0]);
        }
    }

    public static void main(String[] args) throws Exception {
        boolean named = Conditions.class.getDeclaredClasses()[0].getMethod("on", OrderPlaced.class).getParameters()[0].isNamePresent();
        System.out.println("  parameter names in the class file (-parameters)? " + named);
        for (Class<?> c : new Class<?>[]{ByName.class, ByA0.class, ByArgs.class, ByEvent.class}) { run(c, 900); run(c, 340); }
    }
}
