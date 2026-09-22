package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * One argument, two spellings of one bean name, and nothing else different.
 *
 * <p>NOTHING IS CAUGHT HERE ON PURPOSE. A catch block would turn the interesting number — the
 * process exit code — into zero, and this unit's whole point is which failures are loud.
 *
 * <p>Usage: {@code TheName right|wrong}
 */
public final class TheName {

    private TheName() { }

    public static void main(String[] args) {
        if (args.length != 1 || !(args[0].equals("right") || args[0].equals("wrong"))) {
            System.err.println("TheName: usage: TheName right|wrong");
            System.exit(2);
        }
        boolean right = args[0].equals("right");
        Class<?> cfg = right ? TiffinBoxConfig.RightName.class : TiffinBoxConfig.WrongName.class;
        System.out.println("config=" + cfg.getSimpleName()
                + "   the conversion service bean is called "
                + (right ? "conversionService" : "myConversionService"));
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(cfg)) {
            // The bean EXISTS in both runs, and this line proves it in the failing run too --
            // which is only possible because Kitchen is @Lazy, so refresh has already finished.
            System.out.println("conversion service beans in this context: "
                    + java.util.Arrays.toString(ctx.getBeanNamesForType(
                            org.springframework.core.convert.ConversionService.class)));
            System.out.println(ctx.getBean(Kitchen.class));
        }
    }
}
