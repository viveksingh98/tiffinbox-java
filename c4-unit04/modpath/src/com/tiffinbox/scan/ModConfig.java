package com.tiffinbox.scan;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan(basePackages = "com.tiffinbox.menu")
public class ModConfig {
    public static void main(String[] a) {
        try (var c = new AnnotationConfigApplicationContext(ModConfig.class)) {
            System.out.println("module of this class : " + ModConfig.class.getModule().getName());
            System.out.println("named module?        : " + ModConfig.class.getModule().isNamed());
            System.out.println("beans registered     : " + c.getBeanDefinitionCount());
            System.out.println("jdbcMenuRepository   : " + c.containsBean("jdbcMenuRepository"));
        }
    }
}
