package probe;

/**
 * The course's holder, not TiffinBox's: one static field that keeps an object from one start of the context to the next - if
 * this class itself survives the restart. receipts.sh puts it in a folder (A: DevTools' restart loader defines it again at each
 * restart) or in a jar (B: the application class loader defines it once).
 */
public final class Holder {
    public static volatile Object held;
    public static volatile int from;

    private Holder() {
    }
}
