package com.tiffinbox;

import module java.base;

public class ModuleImports {

    public static void main(String[] args) {
        List<String> customers = new ArrayList<>(List.of("Ravi", "Meera", "Sunil"));
        LocalDate start = LocalDate.of(2026, 9, 1);
        IO.println(customers + " " + start);
    }
}
