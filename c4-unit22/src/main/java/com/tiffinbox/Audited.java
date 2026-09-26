package com.tiffinbox;

import java.lang.annotation.*;

/** Our own marker. A pointcut can select exactly the methods that carry it. */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Audited { }
