package com.tiffinbox;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanClassLoaderAware;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.SmartInitializingSingleton;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.ApplicationStartupAware;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.context.EnvironmentAware;
import org.springframework.context.MessageSource;
import org.springframework.context.MessageSourceAware;
import org.springframework.context.ResourceLoaderAware;
import org.springframework.context.EmbeddedValueResolverAware;
import org.springframework.core.env.Environment;
import org.springframework.core.metrics.ApplicationStartup;
import org.springframework.core.io.ResourceLoader;
import org.springframework.util.StringValueResolver;

/**
 * The TiffinBox kitchen, wired up as an INSTRUMENT: it implements every callback the
 * container offers and does nothing else. It is not a design to copy — no real bean
 * implements this many interfaces. It exists so the order can be read off one capture
 * instead of described.
 */
public class Kitchen implements BeanNameAware, BeanClassLoaderAware, BeanFactoryAware,
        EnvironmentAware, EmbeddedValueResolverAware, ResourceLoaderAware,
        ApplicationEventPublisherAware, MessageSourceAware, ApplicationStartupAware,
        ApplicationContextAware,
        InitializingBean, SmartInitializingSingleton, DisposableBean {

    private final CustomerRepository repo;

    /** 1. The container calls this. Nothing else has happened yet. */
    public Kitchen(CustomerRepository repo) {
        this.repo = repo;
        Trace.step("constructor                                  (your code, with its dependency)");
    }

    @Override public void setBeanName(String name) {
        Trace.step("BeanNameAware.setBeanName                    -> \"" + name + "\"");
    }

    @Override public void setBeanClassLoader(ClassLoader cl) {
        Trace.step("BeanClassLoaderAware.setBeanClassLoader");
    }

    @Override public void setBeanFactory(BeanFactory bf) throws BeansException {
        Trace.step("BeanFactoryAware.setBeanFactory");
    }

    @Override public void setEnvironment(Environment e) {
        Trace.step("EnvironmentAware.setEnvironment");
    }

    @Override public void setEmbeddedValueResolver(StringValueResolver r) {
        Trace.step("EmbeddedValueResolverAware.setEmbeddedValueResolver");
    }

    @Override public void setResourceLoader(ResourceLoader rl) {
        Trace.step("ResourceLoaderAware.setResourceLoader");
    }

    @Override public void setApplicationEventPublisher(ApplicationEventPublisher p) {
        Trace.step("ApplicationEventPublisherAware.setApplicationEventPublisher");
    }

    @Override public void setMessageSource(MessageSource ms) {
        Trace.step("MessageSourceAware.setMessageSource");
    }

    @Override public void setApplicationStartup(ApplicationStartup s) {
        Trace.step("ApplicationStartupAware.setApplicationStartup");
    }

    @Override public void setApplicationContext(ApplicationContext ctx) throws BeansException {
        Trace.step("ApplicationContextAware.setApplicationContext");
    }

    @PostConstruct
    public void openTheKitchen() {
        Trace.step("@PostConstruct openTheKitchen()              (jakarta.annotation)");
    }

    @Override public void afterPropertiesSet() {
        Trace.step("InitializingBean.afterPropertiesSet          (a Spring interface)");
    }

    /** Named in the description, not in this file. */
    public void lightTheStoves() {
        Trace.step("@Bean(initMethod) lightTheStoves()           (named in the description)");
    }

    @Override public void afterSingletonsInstantiated() {
        Trace.step("SmartInitializingSingleton.afterSingletons…  (every OTHER singleton is built)");
    }

    // ------------------------------------------------------------------ shutting down ----

    @PreDestroy
    public void lastOrders() {
        Trace.step("@PreDestroy lastOrders()                     (jakarta.annotation)");
    }

    @Override public void destroy() {
        Trace.step("DisposableBean.destroy                       (a Spring interface)");
    }

    public void lockUp() {
        Trace.step("@Bean(destroyMethod) lockUp()                (named in the description)");
    }

    public int customers() throws Exception {
        return repo.findAll().size();
    }
}
