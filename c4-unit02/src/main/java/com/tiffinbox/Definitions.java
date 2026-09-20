package com.tiffinbox;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * What the container holds BEFORE it makes anything: a BeanDefinition. A recipe card, not a
 * cake. Four fields off the registry, then the object the recipe produces, then the same four
 * fields read off an eight-line XML file from 2010.
 *
 * <p>They are the same shape. That is the whole beat: two spellings converge on one thing, and
 * the thing is what this course is about. The XML appears here and nowhere else in the course,
 * and you are never asked to write one.
 */
public final class Definitions {

    private Definitions() { }

    private static void card(ConfigurableListableBeanFactory bf, String name) {
        BeanDefinition bd = bf.getBeanDefinition(name);
        System.out.printf("  %-20s class=%-34s scope=%-10s factoryMethod=%-20s lazy=%s%n",
                name,
                bd.getBeanClassName() == null ? "(null - a @Bean method makes it)" : bd.getBeanClassName(),
                bd.getScope().isEmpty() ? "(default)" : bd.getScope(),
                bd.getFactoryMethodName() == null ? "-" : bd.getFactoryMethodName(),
                bd.isLazyInit());
    }

    public static void main(String[] args) throws Exception {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TiffinBoxConfig.class)) {
            ConfigurableListableBeanFactory bf = ctx.getBeanFactory();

            System.out.println("THE RECIPE  (annotated context, definitions only - nothing built yet)");
            card(bf, "database");
            card(bf, "customerRepository");

            System.out.println("THE CAKE    (the objects those two recipes produce)");
            System.out.printf("  %-20s %s%n", "database", ctx.getBean("database").getClass().getName());
            System.out.printf("  %-20s %s%n", "customerRepository",
                    ctx.getBean("customerRepository").getClass().getName());

            System.out.println("TWO WAYS TO ASK  (and the container answers with the same object)");
            Object byName = ctx.getBean("customerRepository");
            CustomerRepository byType = ctx.getBean(CustomerRepository.class);
            System.out.println("  byName == byType                " + (byName == byType));

            System.out.println("THE NAME NOBODY GAVE IT");
            System.out.println("  the @Bean method is called      customerRepository()");
            System.out.println("  the bean is called              "
                    + ctx.getBeanNamesForType(CustomerRepository.class)[0]
                    + "   <- the method name, and nothing else decided it");
        }

        System.out.println("THE SAME FOUR FIELDS, OFF EIGHT LINES OF XML FROM 2010");
        try (ClassPathXmlApplicationContext xml =
                     new ClassPathXmlApplicationContext("legacy/applicationContext.xml")) {
            ConfigurableListableBeanFactory bf = xml.getBeanFactory();
            card(bf, "database");
            card(bf, "customerRepository");
            System.out.println("  same shape. Different spelling. The container cannot tell you which "
                    + "file it came from,");
            System.out.println("  because by this point there is no file - there is a definition.");
        }
    }
}
