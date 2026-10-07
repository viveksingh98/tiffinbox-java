package probe.cycle;

/** The cure: the cook asks the shift how many slips the rail holds, not the rail - and gets it through its constructor. */
public class Cook {

    private final Shift shift;

    public Cook(Shift shift) {
        this.shift = shift;
    }

    public int slipsWaiting() {
        return shift.slots();
    }
}
