package com.tiffinbox;

// EXERCISE 44 - "Document the Pause" - START HERE.
// This file compiles and runs as it stands. Two jobs:
//   (a) make the four TODOs correct;
//   (b) document every public member until `javadoc -d docs src/com/tiffinbox/Pause.java`
//       prints NOT ONE warning. Right now it prints several - that is the starting line.
// Turn each `//` comment below into a real `/** ... */` doc comment as you go.
// The worked solution is ../src/com/tiffinbox/Pause.java - open it last.
public class Pause {

    // TODO 1: the longest pause Asha allows in one month, as a public static final int, = 14.
    public static final int MAX_DAYS = 0;

    private final String customer;
    private final int from;
    private final int to;

    // TODO 2: validate before storing.
    //   to before from        -> throw IllegalArgumentException("pause ends before it starts: 20 to 14")
    //                            (the two numbers are `from` then `to`)
    //   longer than MAX_DAYS  -> throw IllegalArgumentException too
    public Pause(String customer, int from, int to) {
        this.customer = customer;
        this.from = from;
        this.to = to;
    }

    // TODO 3: both ends count, so day 14 to day 20 is 7 days, not 6.
    public int days() {
        return 0;
    }

    // TODO 4: one line for Asha's report - see the acceptance output in README.md.
    public String describe() {
        return "?";
    }
}
