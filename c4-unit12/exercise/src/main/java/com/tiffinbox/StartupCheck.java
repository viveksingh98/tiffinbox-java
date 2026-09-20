package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;

/** One thing TiffinBox refuses to open without. Three of them, and they are not interchangeable. */
public interface StartupCheck {

    /** Every check records when it was CONSTRUCTED, which is a different list from the one below. */
    List<String> BUILT = new ArrayList<>();

    String name();

    default String run() { return name() + " ok"; }

    static void built(String who) { BUILT.add(who); }
}
