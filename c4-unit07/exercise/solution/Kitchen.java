package com.tiffinbox;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.BeanNameAware;

/**
 * THE ANSWER. The opening step is the same code; it has simply stopped running inside the
 * constructor.
 *
 * <p>A constructor runs at the one moment when the container has done nothing to the object
 * yet — no name, no context, no injected setter, no post-processor. Anything that needs the
 * finished object has to wait for a callback, and @PostConstruct is the one that runs once the
 * container has finished handing this object everything it is going to hand it.
 */
public class Kitchen implements BeanNameAware {

    static String nameWhenOpened = "(the kitchen never opened)";

    private String beanName;

    public Kitchen() {
    }

    @Override public void setBeanName(String name) {
        this.beanName = name;
    }

    @PostConstruct
    void openTheKitchen() {
        nameWhenOpened = (beanName == null ? "(not set yet)" : beanName);
    }

    public boolean knewItsName() {
        return !nameWhenOpened.startsWith("(");
    }
}
