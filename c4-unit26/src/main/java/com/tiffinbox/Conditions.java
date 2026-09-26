package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.event.EventListener;

/**
 * THE BREAK. Four spellings of "only orders over 500". The first is the documentation's first example - and
 * it names the parameter, `e`. Without the -parameters compiler flag (Maven's default) the name is NOT
 * available to reflection. It IS in the class file's debug table (LocalVariableTable) - but Spring stopped
 * reading that table in 6.1 (receipts.sh counts the class that did, in 6.0.23 and 6.1.0). So #e is null and
 * the condition THROWS on every publish, matching or not. Spring Boot turns -parameters on; this course has
 * no Boot. (Corrected 2026-09-26 after the section's RED review: an earlier line said the name was not in
 * the class file at all.)
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

    /** Reads the compiled ByName.on for a debug-table entry named `name` in slot 1 - with Spring's own ASM. */
    static boolean debugTableHas(String name) throws Exception {
        boolean[] found = {false};
        try (var in = Conditions.class.getResourceAsStream("Conditions$ByName.class")) {
            new org.springframework.asm.ClassReader(in).accept(new org.springframework.asm.ClassVisitor(org.springframework.asm.SpringAsmInfo.ASM_VERSION) {
                @Override public org.springframework.asm.MethodVisitor visitMethod(int acc, String n, String d, String sig, String[] ex) {
                    if (!n.equals("on")) return null;
                    return new org.springframework.asm.MethodVisitor(org.springframework.asm.SpringAsmInfo.ASM_VERSION) {
                        @Override public void visitLocalVariable(String v, String desc, String sg, org.springframework.asm.Label a,
                                                                 org.springframework.asm.Label b, int slot) {
                            if (v.equals(name) && slot == 1) found[0] = true;
                        }
                    };
                }
            }, 0);
        }
        return found[0];
    }
    /** The class that used to read parameter names from the debug table. */
    static boolean readerPresent() {
        try { Class.forName("org.springframework.core.LocalVariableTableParameterNameDiscoverer"); return true; }
        catch (ClassNotFoundException e) { return false; }
    }

    public static void main(String[] args) throws Exception {
        boolean named = Conditions.class.getDeclaredClasses()[0].getMethod("on", OrderPlaced.class).getParameters()[0].isNamePresent();
        System.out.println("  parameter names for reflection (-parameters)? " + named);
        System.out.println("  the name e in the class file's debug table?   " + debugTableHas("e"));
        System.out.println("  Spring 7's reader of that debug table present? " + readerPresent());
        for (Class<?> c : new Class<?>[]{ByName.class, ByA0.class, ByArgs.class, ByEvent.class}) { run(c, 900); run(c, 340); }
    }
}
