package com.tiffinbox;

import org.springframework.beans.factory.BeanNameAware;

/**
 * The kitchen opens itself. It works, the context starts, and nothing is logged.
 *
 * <p>The opening step records one thing while it runs: whether the container had got as far as
 * telling this object its own name. That single boolean is the receipt.
 */
public class Kitchen implements BeanNameAware {

    static String nameWhenOpened = "(the kitchen never opened)";

    private String beanName;

    public Kitchen() {
        openTheKitchen();
    }

    @Override public void setBeanName(String name) {
        this.beanName = name;
    }

    void openTheKitchen() {
        nameWhenOpened = (beanName == null ? "(not set yet)" : beanName);
    }

    public boolean knewItsName() {
        return !nameWhenOpened.startsWith("(");
    }
}
