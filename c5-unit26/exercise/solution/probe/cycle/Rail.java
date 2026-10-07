package probe.cycle;

/** The cure: the rail asks the shift how many hands take the slips off, not the cook - Cook and Rail need neither each other. */
public class Rail {

    private final Shift shift;

    public Rail(Shift shift) {
        this.shift = shift;
    }

    public int slots() {
        return shift.slots();
    }

    public int hands() {
        return shift.hands();
    }
}
