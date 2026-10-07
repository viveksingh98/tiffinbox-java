package probe.cycle;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * The harness's, never TiffinBox's: Course 4's setter cycle, brought to Boot. A cook takes slips off the rail, and asks the
 * rail how many slips it holds. Joined to TiffinBox by --spring.main.sources, from outside com.tiffinbox.
 */
public class Cook {

    private Rail rail;

    @Autowired
    public void setRail(Rail rail) {
        this.rail = rail;
    }

    Rail rail() {
        return rail;
    }

    public int slipsWaiting() {
        return rail.slots();
    }
}
