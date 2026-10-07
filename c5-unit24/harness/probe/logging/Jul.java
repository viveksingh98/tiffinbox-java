package probe.logging;

/**
 * The course's harness, never TiffinBox's: a plain main - no Boot, no Spring - that logs two of TiffinBox's own messages through
 * the same System.Logger("tiffinbox"): a route line at DEBUG and the orders cooked at INFO. Given a java.util.logging
 * configuration file on the command line (-Djava.util.logging.config.file=...) and nothing to replace it, it shows what that
 * file does: its console handler writes to standard error, in the file's own format. The control for the counts a run under
 * Boot reads as 0.
 */
public final class Jul {

    private Jul() {
    }

    public static void main(String[] args) {
        System.Logger log = System.getLogger("tiffinbox");
        log.log(System.Logger.Level.DEBUG, "route {0} {1} -> {2}()", "GET", "/customers", "customers");
        log.log(System.Logger.Level.INFO, "orders cooked:  {0,number,#}", 120);
    }
}
