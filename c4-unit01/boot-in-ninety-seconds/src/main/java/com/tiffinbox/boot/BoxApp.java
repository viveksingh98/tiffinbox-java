package com.tiffinbox.boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * The destination. Four lines of application code, and a container full of things nobody in
 * this file asked for.
 *
 * <p>This is the ONLY Spring Boot code in Course 4. It is orientation, never proof: the
 * reason it cannot be the material is that with a starter on the class path you cannot tell
 * whether a behaviour came from the container, from a starter's transitive dependency, or
 * from an auto-configuration that fired. Every other demo in this course is a plain
 * AnnotationConfigApplicationContext, so when something happens, the container did it.
 */
@SpringBootApplication
public class BoxApp {
    public static void main(String[] args) {
        ConfigurableApplicationContext ctx = SpringApplication.run(BoxApp.class, args);
        // The one honest measurement to take off this program: how many beans arrived that
        // this file never mentioned. DERIVED by this run, every run.
        System.out.println("bean definitions in a Boot context nobody in this file asked for: "
                + ctx.getBeanFactory().getBeanDefinitionCount());
        ctx.close();
    }
}
