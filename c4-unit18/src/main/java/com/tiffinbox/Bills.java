package com.tiffinbox;

import java.util.Locale;
import org.springframework.context.MessageSource;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;

/**
 * One bill, for two customers who read different languages.
 *
 * <p>THE LOCALE IS PASSED EXPLICITLY, EVERY TIME. getMessage has an overload that does not take
 * one, and it uses LocaleContextHolder — which falls back to the JVM default. A default locale is
 * an input you did not declare, and this unit's break is what that costs.
 *
 * <p>340 is TiffinBox's bill total, carried in from unit 10's cure capture rather than invented, so
 * the number on screen is one whose arithmetic you have already seen.
 *
 * <p>Usage: {@code Bills [--no-system-fallback] [--code-as-default]}
 */
public final class Bills {

    static final int TOTAL = 340;

    private Bills() { }

    @Configuration
    static class Cfg {

        static boolean noSystemFallback;
        static boolean codeAsDefault;

        @Bean
        MessageSource messageSource() {
            ResourceBundleMessageSource ms = new ResourceBundleMessageSource();
            ms.setBasename("bills");
            ms.setDefaultEncoding("UTF-8");
            // Shipped default is TRUE. The break turns it off.
            ms.setFallbackToSystemLocale(!noSystemFallback);
            // The closing trade. It replaces a thrown exception with THE KEY ITSELF.
            ms.setUseCodeAsDefaultMessage(codeAsDefault);
            return ms;
        }
    }

    public static void main(String[] args) {
        for (String a : args) {
            switch (a) {
                case "--no-system-fallback" -> Cfg.noSystemFallback = true;
                case "--code-as-default" -> Cfg.codeAsDefault = true;
                default -> {
                    System.err.println("Bills: unknown argument " + a
                            + " -- usage: Bills [--no-system-fallback] [--code-as-default]");
                    System.exit(2);
                }
            }
        }
        System.out.println("JVM default locale   = " + Locale.getDefault());
        System.out.println("fallbackToSystemLocale = " + !Cfg.noSystemFallback);
        System.out.println();

        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            MessageSource ms = ctx.getBean(MessageSource.class);
            Object[] args2 = {"Ravi", TOTAL};

            // Two customers, two languages, one key.
            for (Locale l : new Locale[]{Locale.ENGLISH, Locale.ITALIAN}) {
                System.out.printf("  bill.total   %-3s -> %s%n", l, ms.getMessage("bill.total", args2, l));
            }
            // A language with no bundle at all. THIS is the line the break moves.
            Locale de = Locale.forLanguageTag("de");
            System.out.printf("  bill.total   %-3s -> %s   <- no bills_de.properties exists%n",
                    de, ms.getMessage("bill.total", args2, de));

            System.out.println();
            // A key present only in the BASE bundle: the chain falls back and nothing says so.
            for (Locale l : new Locale[]{Locale.ENGLISH, Locale.ITALIAN}) {
                System.out.printf("  bill.footer  %-3s -> %s%n", l, ms.getMessage("bill.footer", null, l));
            }

            System.out.println();
            // A key present nowhere.
            try {
                String got = ms.getMessage("bill.missing", null, Locale.ITALIAN);
                if (!Cfg.codeAsDefault) {
                    System.out.flush();
                    System.err.println("Bills: bill.missing resolved without --code-as-default. It "
                            + "is supposed to exist in no bundle at all, so this capture shows "
                            + "nothing about the chain running out.");
                    System.exit(2);
                }
                System.out.println("  bill.missing     -> \"" + got
                        + "\"   <- the KEY, printed on a customer's bill");
            } catch (NoSuchMessageException e) {
                if (Cfg.codeAsDefault) {
                    System.out.flush();
                    System.err.println("Bills: --code-as-default was set and it still threw. The "
                            + "trade this capture is about did not happen.");
                    System.exit(2);
                }
                System.out.println("  bill.missing     -> " + e.getClass().getSimpleName()
                        + ": " + e.getMessage());
            }
        }
    }
}
