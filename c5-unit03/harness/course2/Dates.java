package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.cfg.PackageVersion;

import java.time.LocalDate;

/**
 * Course 2's closing card: "a record with a LocalDate fails on the very first write … add Module
 * jackson-datatype-jsr310". Here is that first write, with no extra module on the class path. receipts.sh compiles
 * this file twice — as written, against Jackson 2, and with only the package names moved, against Jackson 3.
 */
public final class Dates {

    record Pause(String name, LocalDate from) { }

    public static void main(String[] args) {
        String outcome;
        try {
            outcome = new ObjectMapper().writeValueAsString(new Pause("Ravi", LocalDate.of(2026, 9, 27)));
        } catch (Exception e) {
            outcome = e.getClass().getSimpleName();
        }
        System.out.println("Jackson " + PackageVersion.VERSION + "  a LocalDate, no extra module -> " + outcome);
    }
}
