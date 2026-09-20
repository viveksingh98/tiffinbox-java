package com.tiffinbox.kitchen;

import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

/** Registered at startup. NOT loaded at startup, and the static initialiser proves which. */
@Lazy
@Component
public class ReportBuilder {
    static { System.out.println("  CLASS LOADED  ReportBuilder"); }

    public String report() { return "a report"; }
}
