package com.tiffinbox.bench;

import com.tiffinbox.Customer;

import java.util.List;

/**
 * Three ways to build the same receipt block, so that a benchmark can compare them and a
 * test can prove they are the same thing.
 *
 * <p>That second half is not optional. Two benchmarks that produce different output are not
 * a comparison, they are two measurements of two programs - and nothing in a benchmark
 * harness checks it. {@code ReceiptsAgreeTest} asserts all three return the identical
 * string before any number on a slide is worth reading.
 */
public final class Receipts {

    private Receipts() {}

    public static String concat(List<Customer> roster) {
        String out = "";
        for (Customer c : roster) {
            out = out + c.name() + " x" + c.mealsPerDay() + " = " + c.monthlyBill() + "\n";
        }
        return out;
    }

    public static String builder(List<Customer> roster) {
        var sb = new StringBuilder();
        for (Customer c : roster) {
            sb.append(c.name()).append(" x").append(c.mealsPerDay())
              .append(" = ").append(c.monthlyBill()).append('\n');
        }
        return sb.toString();
    }

    public static String stream(List<Customer> roster) {
        return roster.stream()
                .map(c -> c.name() + " x" + c.mealsPerDay() + " = " + c.monthlyBill())
                .reduce(new StringBuilder(), (sb, s) -> sb.append(s).append('\n'), StringBuilder::append)
                .toString();
    }

    /** The six-customer roster every test in this unit uses. */
    public static final List<Customer> ROSTER = List.of(
            new Customer("Arun", 2, 120, "VEG"),
            new Customer("Bela", 1, 200, "VEGAN"),
            new Customer("Chandran", 3, 150, "NON_VEG"),
            new Customer("Divya", 2, 180, "VEG"),
            new Customer("Ekta", 1, 260, "VEGAN"),
            new Customer("Farid", 4, 110, "NON_VEG"));

    /**
     * The same six names, repeated, to a requested size.
     *
     * <p>A benchmark with one input size does not measure an algorithm, it measures an
     * algorithm at one input size - and for these three that is the difference between two
     * opposite answers. {@code ReceiptBench} therefore takes the size as a JMH parameter
     * rather than picking one.
     */
    public static List<Customer> rosterOf(int size) {
        var out = new java.util.ArrayList<Customer>(size);
        for (int i = 0; i < size; i++) {
            out.add(ROSTER.get(i % ROSTER.size()));
        }
        return List.copyOf(out);
    }
}
