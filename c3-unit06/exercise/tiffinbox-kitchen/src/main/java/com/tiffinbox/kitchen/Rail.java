package com.tiffinbox.kitchen;

import java.util.List;

/** The order rail: what the kitchen is cooking, in the order it was asked for. */
public final class Rail {

    public static List<String> today() {
        return List.of("VEG", "VEG", "NON_VEG", "VEGAN");
    }

    public static int portions(String plan) {
        return (int) today().stream().filter(plan::equals).count();
    }
}
