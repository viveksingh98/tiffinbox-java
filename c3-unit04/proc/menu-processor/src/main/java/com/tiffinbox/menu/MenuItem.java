package com.tiffinbox.menu;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** One dish on the TiffinBox menu. SOURCE retention: it never reaches the class file. */
@Retention(RetentionPolicy.SOURCE)
@Target(ElementType.TYPE)
public @interface MenuItem {
    String name();
    int price();
}
