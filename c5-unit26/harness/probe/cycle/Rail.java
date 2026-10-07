package probe.cycle;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * The harness's, never TiffinBox's: the rail that holds the slips, and asks the cook how many hands take them off. Cook needs
 * Rail and Rail needs Cook, both through setters - the shape Course 4 started on plain Spring's defaults.
 */
public class Rail {

    private Cook cook;

    @Autowired
    public void setCook(Cook cook) {
        this.cook = cook;
    }

    Cook cook() {
        return cook;
    }

    public int slots() {
        return 12;
    }

    public int hands() {
        return cook == null ? 0 : 3;
    }
}
