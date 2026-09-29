package goodbye;

import jakarta.annotation.PreDestroy;

/**
 * One bean that says goodbye, and only when its context is closed: the container calls a @PreDestroy method from
 * close(), never on its own. Deliberately OUTSIDE com.tiffinbox, so TiffinBoxApp's @ComponentScan("com.tiffinbox")
 * never finds it and WhatBootAdded's "your definitions" stay six; WhoCloses registers it by name.
 */
public class Goodbye {
    @PreDestroy
    void bye() {
        System.out.println("goodbye: @PreDestroy ran");
    }
}
